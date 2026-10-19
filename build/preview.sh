#!/usr/bin/env bash
# Quick look without the VM: run labwc headless in the builder container with
# the kflux overlay, open a couple of windows and the root menu, grab a PNG.
#   build/preview.sh [style-name] [out.png]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CTX="colima-${KFLUX_COLIMA_PROFILE:-kflux}"
STYLE="${1:-}"
OUT="${2:-$ROOT/screenshots/preview-${STYLE:-default}.png}"
mkdir -p "$ROOT/screenshots"

docker --context "$CTX" run --rm --platform linux/amd64 \
  -v kflux-pkgcache:/var/cache/pacman/pkg \
  -v "$ROOT:/src:ro" -v "$ROOT/screenshots:/out" \
  -e STYLE="$STYLE" -e OUTNAME="$(basename "$OUT")" \
  cachyos/cachyos:latest bash -c '
set -e
sed -i "s/^#\?DisableSandbox.*/DisableSandbox/; s/^CheckSpace/#CheckSpace/" /etc/pacman.conf
grep -q "^DisableSandbox" /etc/pacman.conf || sed -i "/^\[options\]/a DisableSandbox" /etc/pacman.conf
pacman -Sy --noconfirm --needed labwc waybar swaybg grim foot wtype wlr-randr python fluxbox \
  ttf-dejavu ttf-terminus-nerd noto-fonts breeze-icons mako >/dev/null 2>&1
cp -a /src/overlay/usr/. /usr/
useradd -m flux; mkdir -p /run/user/1000; chown flux /run/user/1000; chmod 700 /run/user/1000
su flux -c "
export XDG_RUNTIME_DIR=/run/user/1000 WLR_BACKENDS=headless WLR_RENDERER=pixman WLR_HEADLESS_OUTPUTS=1 WLR_LIBINPUT_NO_DEVICES=1
kflux init --no-reload >/dev/null
[ -n \"$STYLE\" ] && kflux style \"$STYLE\" >/dev/null
labwc >/tmp/labwc.log 2>&1 &
for i in \$(seq 60); do ls \$XDG_RUNTIME_DIR/wayland-* >/dev/null 2>&1 && break; sleep 1; done
export WAYLAND_DISPLAY=\$(basename \$(ls \$XDG_RUNTIME_DIR/wayland-? | head -1))
wlr-randr --output HEADLESS-1 --custom-mode 1280x800 || true
sleep 2; kflux apply >/dev/null 2>&1 || true
sleep 25
foot --title \"~ : foot\" -e sh -c \"kflux warnings; echo; cat ~/.config/kflux/keys | head -30; sleep 600\" &
sleep 6
foot --title \"init\" -e sh -c \"cat ~/.config/kflux/init; sleep 600\" &
sleep 10
grim /out/\$OUTNAME
grep -iE \"error|warn|fail\" /tmp/labwc.log | head -20 || true
tail -5 ~/.cache/kflux/toolbar.log 2>/dev/null || true
"'
echo "$OUT"
