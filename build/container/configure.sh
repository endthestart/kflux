#!/usr/bin/env bash
# Runs inside the target rootfs (arch-chroot) during the image build.
set -euo pipefail

ESP_PARTUUID=6b666c75-7800-4000-8000-0000000000e5
ROOT_PARTUUID=6b666c75-7800-4000-8000-0000000000f5

# --- base system -------------------------------------------------------------
echo kflux > /etc/hostname
cat > /etc/hosts <<EOF
127.0.0.1 localhost
::1       localhost
127.0.1.1 kflux.localdomain kflux
EOF
sed -i 's/^#\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
locale-gen >/dev/null
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime

cat > /etc/fstab <<EOF
PARTUUID=$ROOT_PARTUUID  /      ext4  rw,relatime  0 1
PARTUUID=$ESP_PARTUUID   /boot  vfat  rw,relatime,fmask=0077,dmask=0077  0 2
EOF

# First boot gets a fresh machine-id.
: > /etc/machine-id

# --- user --------------------------------------------------------------------
# PoC credentials: flux/flux (documented in README). Root stays locked.
useradd -m -u 1000 -G wheel,video,input,audio -s /bin/bash flux 2>/dev/null || true
echo 'flux:flux' | chpasswd
passwd -l root >/dev/null
echo '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/10-wheel
chmod 440 /etc/sudoers.d/10-wheel
chown -R flux:flux /home/flux
chmod 700 /home/flux/.ssh

# sshd: key-only, for debugging the VM from the host (port-forwarded to 2222).
cat > /etc/ssh/sshd_config.d/10-kflux.conf <<EOF
PasswordAuthentication no
PermitRootLogin no
EOF

# --- services ----------------------------------------------------------------
systemctl enable NetworkManager sshd greetd systemd-timesyncd >/dev/null 2>&1
# VMware guests (build/run-vmware.sh); no-op elsewhere.
systemctl enable vmtoolsd >/dev/null 2>&1 || true

# Branding: CachyOS repos and kernel, kflux desktop.
cat > /etc/os-release <<'OSR'
NAME="kflux"
PRETTY_NAME="kflux (CachyOS based)"
ID=kflux
ID_LIKE="cachyos arch"
BUILD_ID=rolling
VERSION_ID=poc-2026.10
HOME_URL="https://cachyos.org/"
LOGO=cachyos
OSR
printf 'kflux (CachyOS based) \\r (\\l)\n\n' > /etc/issue
systemctl set-default graphical.target >/dev/null 2>&1
# greetd's greeter user needs video access for tuigreet on the VT.
usermod -aG video greeter 2>/dev/null || true

# KDE app menus outside Plasma ("Open With" in Dolphin) need an applications.menu.
# archlinux-xdg-menu provides arch-applications.menu; kflux-session sets the prefix.

# --- kflux user config -------------------------------------------------------
# Seed ~/.config/kflux from the system defaults and render all generated
# configs (labwc, waybar, mako, swaylock, KDE colours) once at build time.
su - flux -c 'kflux init --no-reload' >/dev/null
echo "kflux configured"
