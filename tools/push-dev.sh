#!/usr/bin/env bash
# Dev loop: install the working tree into the running VM (make install) and
# reconfigure the session.
#   tools/push-dev.sh [--reset]   --reset re-seeds ~/.config/kflux from skel
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PORT="${KFLUX_SSH_PORT:-2232}"
HOST="${KFLUX_SSH_HOST:-127.0.0.1}"
SSH=(ssh -i "$ROOT/.cache/ssh/id_ed25519" -p "$PORT" -o StrictHostKeyChecking=no
     -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR "flux@$HOST")
STAGE="$(mktemp -d)"; trap 'rm -rf "$STAGE"' EXIT
make -s -C "$ROOT" install DESTDIR="$STAGE" PREFIX=/usr
COPYFILE_DISABLE=1 tar -C "$STAGE" --no-xattrs -cf - usr |
  "${SSH[@]}" 'cat > /tmp/kflux-usr.tar'
"${SSH[@]}" 'echo flux | sudo -S -p "" tar -C / --no-same-owner -xf /tmp/kflux-usr.tar 2>/dev/null; rm -f /tmp/kflux-usr.tar'
reset=""
[[ "${1:-}" == "--reset" ]] && reset="kflux init --force --no-reload;"
"${SSH[@]}" "export XDG_RUNTIME_DIR=/run/user/1000 WAYLAND_DISPLAY=wayland-0 LABWC_PID=\$(pgrep -x labwc); $reset kflux reconfigure; kflux warnings"
