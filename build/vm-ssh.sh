#!/usr/bin/env bash
# ssh into the running kflux VM as flux; with --wl, run the command inside
# the Wayland session's environment.
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PORT="${KFLUX_SSH_PORT:-2232}"; HOST="${KFLUX_SSH_HOST:-127.0.0.1}"
pre=""
if [[ "${1:-}" == "--wl" ]]; then
  shift
  pre='export XDG_RUNTIME_DIR=/run/user/1000 WAYLAND_DISPLAY=wayland-0 XDG_CURRENT_DESKTOP=kflux:KDE KDE_SESSION_VERSION=6 QT_QPA_PLATFORMTHEME=kde QT_QPA_PLATFORM=wayland XDG_MENU_PREFIX=arch- LABWC_PID=$(pgrep -x labwc); systemd-detect-virt -q && export QT_QUICK_BACKEND=software LIBGL_ALWAYS_SOFTWARE=1; '
fi
exec ssh -i "$ROOT/.cache/ssh/id_ed25519" -p "$PORT" -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR ${KFLUX_SSH_JUMP:+-J "$KFLUX_SSH_JUMP"} \
  "flux@$HOST" "$pre$*"
