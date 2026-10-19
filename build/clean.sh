#!/usr/bin/env bash
# Reclaim disk used by kflux builds.
#   build/clean.sh          drop the builder work volume (keeps package cache and image)
#   build/clean.sh --all    also drop the package cache, the VM image and the Colima profile
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROFILE="${KFLUX_COLIMA_PROFILE:-kflux}"
CTX="colima-${PROFILE}"

if colima status "$PROFILE" >/dev/null 2>&1; then
  docker --context "$CTX" volume rm -f kflux-work >/dev/null && echo "removed volume kflux-work"
  if [[ "${1:-}" == "--all" ]]; then
    docker --context "$CTX" volume rm -f kflux-pkgcache >/dev/null && echo "removed volume kflux-pkgcache"
  fi
fi
if [[ "${1:-}" == "--all" ]]; then
  rm -f "$ROOT/vm/kflux.qcow2" "$ROOT/vm/OVMF_VARS.fd" "$ROOT/vm/serial.log"
  colima delete "$PROFILE" --force 2>/dev/null && echo "deleted Colima profile $PROFILE" || true
fi
