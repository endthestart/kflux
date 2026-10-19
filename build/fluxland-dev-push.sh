#!/usr/bin/env bash
# Dev loop for the fluxland port. Work in third_party/fluxland with the port
# patch applied to the working tree:
#   git -C third_party/fluxland apply ../patches/fluxland-wlroots-0.20.patch
# This rebuilds fluxland in the kflux-fluxland-dev container (created on first
# use, build dir /build), installs the binary into the running VM, and exits a
# running fluxland session so tuigreet can start it again. When done, keep the
# header of the patch file and replace its diff with `git diff`, then
# `git checkout .` so the clone stays at the pinned upstream commit.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CTX=colima-kflux
C=kflux-fluxland-dev
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

if ! docker --context $CTX inspect $C >/dev/null 2>&1; then
  docker --context $CTX run -d --name $C --platform linux/amd64 \
    -v kflux-pkgcache:/var/cache/pacman/pkg -v "$ROOT/third_party:/tp" \
    cachyos/cachyos:latest sleep infinity >/dev/null
  docker --context $CTX exec $C bash -c '
    sed -i "s/^#\?DisableSandbox.*/DisableSandbox/; s/^CheckSpace/#CheckSpace/" /etc/pacman.conf
    grep -q "^DisableSandbox" /etc/pacman.conf || sed -i "/^\[options\]/a DisableSandbox" /etc/pacman.conf
    pacman -Sy --noconfirm --needed base-devel meson ninja git wlroots0.20 wayland-protocols \
      pango cairo libinput libxkbcommon libdrm pixman xcb-util-wm xorg-xwayland systemd-libs \
      libpipewire gdk-pixbuf2 >/dev/null
    meson setup /build /tp/fluxland --buildtype=release >/dev/null'
fi
docker --context $CTX start $C >/dev/null
docker --context $CTX exec $C bash -c \
  'cd /build && { ninja fluxland || ninja fluxland; } 2>&1 | grep -E " error|Linking" || true; test -x /build/fluxland'
docker --context $CTX cp $C:/build/fluxland "$TMP/fluxland"
"$ROOT/build/vm-ssh.sh" 'cat > /tmp/fluxland && echo flux | sudo -S -p "" install -m755 /tmp/fluxland /usr/bin/fluxland 2>/dev/null; rm -f /tmp/fluxland
  s=/run/user/1000/fluxland.wayland-0.sock; [ -S $s ] && fluxland-ctl -s $s action Exit >/dev/null || true' < "$TMP/fluxland"
