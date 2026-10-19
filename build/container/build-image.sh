#!/usr/bin/env bash
# Runs inside the privileged amd64 CachyOS builder container.
# Inputs:  /src = the kflux project (read-only): build/, overlay/, README.md,
#          .cache/ssh/id_ed25519.pub; env ROOT_SIZE, KEEP_ROOTFS.
# Output:  /out/kflux.qcow2 and /out/OVMF_VARS.fd are left to the host script.
set -euo pipefail

W=/work
R=$W/rootfs
ESP_MIB=512
# Fixed identifiers keep the image reproducible and the boot entry stable.
DISK_GUID=6b666c75-7800-4000-8000-000000000001
ESP_PARTUUID=6b666c75-7800-4000-8000-0000000000e5
ROOT_PARTUUID=6b666c75-7800-4000-8000-0000000000f5
ROOT_FSUUID=6b666c75-7800-4000-8000-0000000000a5

log() { printf '\033[1;32m[builder]\033[0m %s\n' "$*"; }

# --- builder tooling ---------------------------------------------------------
# pacman's download sandbox and free-space check both fail inside containers.
sed -i 's/^#\?DisableSandbox.*/DisableSandbox/; s/^CheckSpace/#CheckSpace/' /etc/pacman.conf
grep -q '^DisableSandbox' /etc/pacman.conf || sed -i '/^\[options\]/a DisableSandbox' /etc/pacman.conf
log "installing builder tools"
pacman -Sy --noconfirm --needed arch-install-scripts dosfstools mtools e2fsprogs git \
  util-linux qemu-img >/dev/null

# Target pacman.conf: the builder's, without the docker image's NoExtract
# (which strips man pages, locales and docs) and without the container hacks.
sed -e '/^NoExtract/d' -e '/^DisableSandbox/d' -e 's/^#CheckSpace/CheckSpace/' \
  /etc/pacman.conf > $W/pacman.target.conf
cp $W/pacman.target.conf $W/pacman.build.conf
sed -i '/^\[options\]/a DisableSandbox' $W/pacman.build.conf
sed -i 's/^CheckSpace/#CheckSpace/' $W/pacman.build.conf

# --- rootfs ------------------------------------------------------------------
log "fresh rootfs at $R"
rm -rf "$R" && mkdir -p "$R"

# Seed initramfs config before the kernel's install hook runs, so the image is
# built once, generic (no autodetect: the build host is not the target VM).
install -Dm644 /src/build/container/mkinitcpio-kflux.conf "$R/etc/mkinitcpio.conf.d/kflux.conf"
install -Dm644 /src/build/container/linux-cachyos.preset "$R/etc/mkinitcpio.d/linux-cachyos.preset"
printf 'KEYMAP=us\n' | install -Dm644 /dev/stdin "$R/etc/vconsole.conf"

mapfile -t PKGS < <(grep -vE '^\s*(#|$)' /src/build/packages.txt)
log "pacstrap ${#PKGS[@]} packages"
pacstrap -C $W/pacman.build.conf -c -K "$R" "${PKGS[@]}" >/dev/null 2>$W/pacstrap.err || {
  tail -40 $W/pacstrap.err; exit 1; }
grep -iE 'error|warning' $W/pacstrap.err | grep -viE 'skipping|not found in|unsupported' | tail -20 || true

# --- fluxland: the second session --------------------------------------------
# packaging/arch/fluxland-kflux/PKGBUILD, fed local tarballs: fluxland at the
# PKGBUILD's pinned commit from third_party/fluxland, and the kflux files it
# needs (the port patch and the session). The package is cached in /work by
# the hash of its inputs.
build_fluxland() {
  local pkg=/src/packaging/arch/fluxland-kflux
  local files=(third_party/patches overlay/usr/bin/fluxland-kflux-session
               overlay/usr/share/wayland-sessions/fluxland-kflux.desktop)
  local commit kver key out B
  read -r commit kver < <(. "$pkg/PKGBUILD"; echo "$_commit $_kfluxver")
  key=$( { cat "$pkg/PKGBUILD"; tar -C /src -cf - "${files[@]}"; } | sha256sum | cut -c1-12)
  out=$W/pkgs/fluxland-$key
  if ! compgen -G "$out/fluxland-kflux-[0-9]*.pkg.tar.zst" >/dev/null; then
    log "building fluxland package ($key)"
    pacman -S --noconfirm --needed base-devel meson ninja wayland-protocols wlroots0.20 \
      pango cairo libinput libxkbcommon libdrm pixman xcb-util-wm systemd-libs \
      libpipewire gdk-pixbuf2 xorg-xwayland >/dev/null
    id builder >/dev/null 2>&1 || useradd -m builder
    B=$W/fluxland-build && rm -rf $B && mkdir -p $B
    cp "$pkg/PKGBUILD" $B/
    git -c safe.directory='*' -C /src/third_party/fluxland archive --format=tar.gz \
      --prefix="fluxland-$commit/" -o $B/fluxland.tar.gz "$commit"
    tar -C /src -czf $B/kflux.tar.gz --transform "s,^,kflux-$kver/," "${files[@]}"
    chown -R builder $B
    su builder -c "cd $B && FLUXLAND_SRC=file://$B/fluxland.tar.gz KFLUX_SRC=file://$B/kflux.tar.gz \
      makepkg --nodeps --noconfirm" >$W/fluxland-build.log 2>&1 || {
      tail -40 $W/fluxland-build.log; exit 1; }
    mkdir -p "$out" && cp $B/fluxland-kflux-[0-9]*.pkg.tar.zst "$out/"
    rm -rf $B
  fi
  # The image installs kflux from the overlay, not as a package.
  log "installing fluxland package"
  pacstrap -C $W/pacman.build.conf -U "$R" --assume-installed kflux \
    "$out"/fluxland-kflux-[0-9]*.pkg.tar.zst >/dev/null
}
build_fluxland

# --- labwc-kflux: labwc with Fluxbox tabs ------------------------------------
# packaging/arch/labwc-kflux/PKGBUILD (decisions/0004), fed the labwc release
# tarball (the PKGBUILD's pinned sum; .cache/ copy if present) and the tabs
# patch. Replaces labwc, which build/packages.txt leaves out. Cached in /work
# by the hash of its inputs.
build_labwc() {
  local pkg=/src/packaging/arch/labwc-kflux
  local files=(third_party/patches/labwc-tabs.patch)
  local ver kver key out B
  read -r ver kver < <(. "$pkg/PKGBUILD"; echo "$pkgver $_kfluxver")
  key=$( { cat "$pkg/PKGBUILD"; tar -C /src -cf - "${files[@]}"; } | sha256sum | cut -c1-12)
  out=$W/pkgs/labwc-$key
  if ! compgen -G "$out/labwc-kflux-[0-9]*.pkg.tar.zst" >/dev/null; then
    log "building labwc-kflux package ($key)"
    pacman -S --noconfirm --needed base-devel meson scdoc wayland-protocols xorg-xwayland \
      wlroots0.20 cairo glib2 libinput libpng librsvg libsfdo libxcb libxkbcommon libxml2 \
      pango pixman seatd wayland ttf-dejavu >/dev/null
    id builder >/dev/null 2>&1 || useradd -m builder
    B=$W/labwc-build && rm -rf $B && mkdir -p $B
    cp "$pkg/PKGBUILD" $B/
    local labwc_src=""
    if [[ -f /src/.cache/labwc-$ver.tar.gz ]]; then
      cp /src/.cache/labwc-$ver.tar.gz $B/labwc.tar.gz
      labwc_src="LABWC_SRC=file://$B/labwc.tar.gz"
    fi
    tar -C /src -czf $B/kflux.tar.gz --transform "s,^,kflux-$kver/," "${files[@]}"
    chown -R builder $B
    su builder -c "cd $B && $labwc_src KFLUX_SRC=file://$B/kflux.tar.gz \
      makepkg --nodeps --noconfirm" >$W/labwc-build.log 2>&1 || {
      tail -40 $W/labwc-build.log; exit 1; }
    mkdir -p "$out" && cp $B/labwc-kflux-[0-9]*.pkg.tar.zst "$out/"
    rm -rf $B
  fi
  log "installing labwc-kflux package"
  pacstrap -C $W/pacman.build.conf -U "$R" "$out"/labwc-kflux-[0-9]*.pkg.tar.zst >/dev/null
}
build_labwc

cp $W/pacman.target.conf "$R/etc/pacman.conf"
cp /etc/pacman.d/cachyos-mirrorlist "$R/etc/pacman.d/" 2>/dev/null || true

log "applying overlay"
cp -a /src/overlay/. "$R/"
install -Dm600 /src/.cache/ssh/id_ed25519.pub "$R/home/flux/.ssh/authorized_keys"
install -Dm644 /src/README.md "$R/usr/share/doc/kflux/README.md"
chmod 755 "$R/usr/bin/kflux" "$R/usr/bin/kflux-session" "$R/usr/bin/fluxland-kflux-session"

log "configuring system"
cp /src/build/container/configure.sh "$R/root/kflux-configure.sh"
arch-chroot "$R" bash /root/kflux-configure.sh
rm -f "$R/root/kflux-configure.sh"

# --- ESP contents ------------------------------------------------------------
log "staging ESP"
S=$W/esp && rm -rf $S && mkdir -p $S/EFI/BOOT $S/EFI/systemd $S/loader/entries
cp "$R"/boot/vmlinuz-linux-cachyos "$R"/boot/initramfs-linux-cachyos.img $S/
cp "$R/usr/lib/systemd/boot/efi/systemd-bootx64.efi" $S/EFI/BOOT/BOOTX64.EFI
cp "$R/usr/lib/systemd/boot/efi/systemd-bootx64.efi" $S/EFI/systemd/
cat > $S/loader/loader.conf <<EOF
default kflux.conf
timeout 2
console-mode keep
editor no
EOF
cat > $S/loader/entries/kflux.conf <<EOF
title   kflux (CachyOS)
linux   /vmlinuz-linux-cachyos
initrd  /initramfs-linux-cachyos.img
options root=PARTUUID=$ROOT_PARTUUID rw quiet loglevel=3 console=tty1 console=ttyS0,115200
EOF
# The ESP is mounted at /boot in the running system; leave the mountpoint empty.
rm -rf "$R"/boot/*

# --- filesystem images (no loop devices needed) ------------------------------
log "making filesystems"
rm -f $W/esp.img $W/root.img $W/disk.img
mkfs.fat -C -F 32 -n KFLUXESP -i 6b666c75 $W/esp.img $((ESP_MIB * 1024)) >/dev/null
mcopy -s -i $W/esp.img $S/* ::/
mkfs.ext4 -q -L kflux-root -U $ROOT_FSUUID -E root_owner=0:0 -d "$R" $W/root.img "$ROOT_SIZE"

log "assembling GPT disk"
ESP_SECT=$((ESP_MIB * 2048))
ROOT_BYTES=$(stat -c %s $W/root.img)
ROOT_SECT=$((ROOT_BYTES / 512))
ROOT_START=$((2048 + ESP_SECT))
TOTAL=$(( (ROOT_START + ROOT_SECT + 2048) * 512 ))
truncate -s $TOTAL $W/disk.img
sfdisk -q $W/disk.img <<EOF
label: gpt
label-id: $DISK_GUID
unit: sectors
first-lba: 2048
start=2048, size=$ESP_SECT, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B, uuid=$ESP_PARTUUID, name="ESP"
start=$ROOT_START, size=$ROOT_SECT, type=4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709, uuid=$ROOT_PARTUUID, name="kflux-root"
EOF
dd if=$W/esp.img of=$W/disk.img bs=1M seek=1 conv=notrunc,sparse status=none
dd if=$W/root.img of=$W/disk.img bs=1M seek=$((ROOT_START / 2048)) conv=notrunc,sparse status=none

log "converting to qcow2"
rm -f /out/kflux.qcow2.tmp
qemu-img convert -f raw -O qcow2 -o cluster_size=2M $W/disk.img /out/kflux.qcow2.tmp
mv -f /out/kflux.qcow2.tmp /out/kflux.qcow2

rm -f $W/esp.img $W/root.img $W/disk.img
rm -rf $S
[[ "${KEEP_ROOTFS:-0}" == 1 ]] || rm -rf "$R"
log "image ready"
