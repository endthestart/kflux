#!/usr/bin/env bash
# Run the kflux image natively (x86_64) on another Mac (Intel) under VMware
# Fusion, over ssh. The VM uses 2 vCPU / 8 GiB, no 3D (build/vmware/kflux.vmx),
# and keeps its files in ~/kflux on that host.
#   KFLUX_VMWARE_HOST=myhost build/run-vmware.sh start | stop | ip | ssh [cmd] | shot [out.png]
# `start` refuses if other running VMs would push the host past
# KFLUX_VM_BUDGET vCPUs (default 4). VMs named in KFLUX_BUDGET_EXEMPT
# (a regex of .vmx basenames) don't count. It also refuses while any Colima
# profile listed in KFLUX_BLOCKING_COLIMA (space-separated) runs on the host.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOST="${KFLUX_VMWARE_HOST:?set KFLUX_VMWARE_HOST to the ssh host running VMware Fusion}"
DIR="kflux"                                  # ~/kflux on that host
VMRUN='"/Applications/VMware Fusion.app/Contents/Public/vmrun" -T fusion'
VMX="\$HOME/$DIR/kflux.vmwarevm/kflux.vmx"
rsh() { ssh "$HOST" "bash -lc $(printf %q "$1")" </dev/null; }

guard() {
  local p
  for p in ${KFLUX_BLOCKING_COLIMA:-}; do
    if rsh "colima list 2>/dev/null | grep -q '^$p *Running'"; then
      echo "Colima profile $p is running on $HOST: not starting kflux" >&2; exit 1
    fi
  done
  local others exempt="${KFLUX_BUDGET_EXEMPT:-^$}" budget="${KFLUX_VM_BUDGET:-4}"
  others=$(rsh "$VMRUN list | tail -n +2 | grep -v '$DIR/' | grep -vE '/($exempt)\\.vmx\$' | while read -r v; do grep -i '^numvcpus' \"\$v\" | tr -dc 0-9; echo; done | paste -sd+ - | bc" 2>/dev/null || echo 0)
  if (( ${others:-0} + 2 > budget )); then
    echo "other VMs on $HOST already use ${others} vCPUs; kflux would exceed $budget in total" >&2; exit 1
  fi
}

case "${1:-start}" in
  start)
    guard
    [[ -f "$ROOT/vm/kflux.qcow2" ]] || { echo "build first" >&2; exit 1; }
    if ! rsh "test -f ~/$DIR/kflux.vmwarevm/kflux.vmdk"; then
      tmp="$ROOT/vm/kflux.vmdk"
      qemu-img convert -p -f qcow2 -O vmdk -o subformat=monolithicSparse "$ROOT/vm/kflux.qcow2" "$tmp"
      rsh "mkdir -p ~/$DIR/kflux.vmwarevm"
      rsync -a --progress "$tmp" "$HOST:$DIR/kflux.vmwarevm/kflux.vmdk"
      rm -f "$tmp"
    fi
    scp -q "$ROOT/build/vmware/kflux.vmx" "$HOST:$DIR/kflux.vmwarevm/kflux.vmx"
    rsh "$VMRUN start $VMX nogui"
    echo "started; ip: $("$0" ip)"
    ;;
  stop) rsh "$VMRUN stop $VMX soft || $VMRUN stop $VMX hard" ;;
  ip)   rsh "$VMRUN getGuestIPAddress $VMX -wait" ;;
  ssh)  shift; ip=$("$0" ip); KFLUX_SSH_JUMP="$HOST" KFLUX_SSH_HOST="$ip" KFLUX_SSH_PORT=22 \
          "$ROOT/build/vm-ssh.sh" --wl "${@:-true}" ;;
  shot) out="${2:-$ROOT/screenshots/vmware-$(date +%Y%m%d-%H%M%S).png}"; mkdir -p "$(dirname "$out")"
        "$0" ssh 'rm -f /tmp/shot.png; if pgrep -x kwin_wayland >/dev/null; then export WAYLAND_DISPLAY=$(basename $(ls /run/user/1000/wayland-? | head -1)); spectacle -b -n -f -o /tmp/shot.png >/dev/null 2>&1; else grim /tmp/shot.png; fi; base64 -w0 /tmp/shot.png' | base64 -d > "$out"; echo "$out" ;;
  *) echo "usage: $0 start|stop|ip|ssh|shot" >&2; exit 2 ;;
esac
