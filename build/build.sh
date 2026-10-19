#!/usr/bin/env bash
# Build the kflux proof-of-concept disk image (vm/kflux.qcow2) on macOS.
#
# The x86_64 rootfs is assembled inside an amd64 CachyOS container running on
# the dedicated "kflux" Colima profile (Apple Silicon + Rosetta), then turned
# into a bootable GPT/UEFI disk without loop devices. See README.md.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROFILE="${KFLUX_COLIMA_PROFILE:-kflux}"
CTX="colima-${PROFILE}"
IMAGE="${KFLUX_BASE_IMAGE:-cachyos/cachyos:latest}"
ROOT_SIZE="${KFLUX_ROOT_SIZE:-14G}"

log() { printf '\033[1;34m[kflux]\033[0m %s\n' "$*"; }

ensure_colima() {
  if ! colima status "$PROFILE" >/dev/null 2>&1; then
    log "starting Colima profile '$PROFILE' (4 vCPU, 4 GiB, Rosetta)"
    # Starting a profile switches the global docker context; restore it after.
    local prev; prev="$(docker context show 2>/dev/null || echo default)"
    colima start "$PROFILE" --vm-type vz --vz-rosetta --arch aarch64 \
      --cpu 4 --memory 4 --disk 30 --runtime docker
    docker context use "$prev" >/dev/null
  fi
}

ensure_ssh_key() {
  mkdir -p "$ROOT/.cache/ssh"
  [[ -f "$ROOT/.cache/ssh/id_ed25519" ]] ||
    ssh-keygen -q -t ed25519 -N '' -C kflux-poc -f "$ROOT/.cache/ssh/id_ed25519"
}

main() {
  ensure_colima
  ensure_ssh_key
  mkdir -p "$ROOT/vm"
  log "building rootfs and disk image in $IMAGE (this takes a while)"
  docker --context "$CTX" run --rm --privileged --platform linux/amd64 \
    -v kflux-pkgcache:/var/cache/pacman/pkg \
    -v kflux-work:/work \
    -v "$ROOT:/src:ro" \
    -v "$ROOT/vm:/out" \
    -e ROOT_SIZE="$ROOT_SIZE" \
    -e KEEP_ROOTFS="${KEEP_ROOTFS:-0}" \
    "$IMAGE" bash /src/build/container/build-image.sh
  log "done: $ROOT/vm/kflux.qcow2"
  du -h "$ROOT/vm/kflux.qcow2"
  if [[ "${KFLUX_STOP_COLIMA:-1}" == 1 ]]; then
    log "stopping Colima profile '$PROFILE'"
    colima stop "$PROFILE"
  fi
}

main "$@"
