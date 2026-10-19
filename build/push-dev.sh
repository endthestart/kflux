#!/usr/bin/env bash
# Dev loop: copy overlay/usr into the running VM and reconfigure the session.
#   build/push-dev.sh [--reset]   --reset re-seeds ~/.config/kflux from skel
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PORT="${KFLUX_SSH_PORT:-2232}"
HOST="${KFLUX_SSH_HOST:-127.0.0.1}"
SSH=(ssh -i "$ROOT/.cache/ssh/id_ed25519" -p "$PORT" -o StrictHostKeyChecking=no
     -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR "flux@$HOST")
COPYFILE_DISABLE=1 tar -C "$ROOT/overlay" --no-xattrs --exclude __pycache__ -cf - usr |
  "${SSH[@]}" 'cat > /tmp/kflux-usr.tar'
"${SSH[@]}" 'echo flux | sudo -S -p "" sh -c "tar -C / --no-same-owner -xf /tmp/kflux-usr.tar 2>/dev/null; chmod 755 /usr/bin/kflux /usr/bin/kflux-session /usr/bin/fluxland-kflux-session"; rm -f /tmp/kflux-usr.tar'
reset=""
[[ "${1:-}" == "--reset" ]] && reset="kflux init --force --no-reload;"
"${SSH[@]}" "export XDG_RUNTIME_DIR=/run/user/1000 WAYLAND_DISPLAY=wayland-0 LABWC_PID=\$(pgrep -x labwc); $reset kflux reconfigure; kflux warnings"
