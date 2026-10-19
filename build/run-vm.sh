#!/usr/bin/env bash
# Boot the kflux PoC image under QEMU (x86_64 TCG emulation on Apple Silicon).
#   build/run-vm.sh             window (Cocoa)
#   build/run-vm.sh --headless  no window; VNC on 127.0.0.1:5921
# SSH: ssh -i .cache/ssh/id_ed25519 -p 2232 flux@127.0.0.1
# Screenshot: build/screenshot.sh [file.png]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VM="$ROOT/vm"
SHARE="$(brew --prefix qemu 2>/dev/null)/share/qemu"
[[ -d "$SHARE" ]] || SHARE=/opt/homebrew/share/qemu
CPUS="${KFLUX_CPUS:-4}"     # budget: at most 4 vCPUs
MEM="${KFLUX_MEM:-4G}"      # budget: at most 6 GiB
RES="${KFLUX_RES:-1280x800}"
SSH_PORT="${KFLUX_SSH_PORT:-2232}"
VNC_DISPLAY="${KFLUX_VNC_DISPLAY:-21}"   # 5900 + 21

[[ -f "$VM/kflux.qcow2" ]] || { echo "no image: run build/build.sh first" >&2; exit 1; }
[[ -f "$VM/OVMF_VARS.fd" ]] || cp "$SHARE/edk2-i386-vars.fd" "$VM/OVMF_VARS.fd"

display=(-display cocoa,show-cursor=on)
if [[ "${1:-}" == "--headless" ]]; then
  display=(-display none -vnc "127.0.0.1:$VNC_DISPLAY")
fi

rm -f "$VM/qmp.sock"
exec qemu-system-x86_64 \
  -name kflux \
  -machine q35 -accel tcg,thread=multi,tb-size=1024 -cpu max \
  -smp "$CPUS" -m "$MEM" \
  -drive if=pflash,format=raw,readonly=on,file="$SHARE/edk2-x86_64-code.fd" \
  -drive if=pflash,format=raw,file="$VM/OVMF_VARS.fd" \
  -drive file="$VM/kflux.qcow2",if=virtio,format=qcow2,cache=writeback,discard=unmap \
  -device virtio-vga,xres="${RES%x*}",yres="${RES#*x}" \
  -device virtio-tablet-pci -device virtio-keyboard-pci \
  -device virtio-rng-pci \
  -nic user,model=virtio-net-pci,hostfwd=tcp:127.0.0.1:$SSH_PORT-:22 \
  -audiodev none,id=snd0 -device ich9-intel-hda -device hda-output,audiodev=snd0 \
  -qmp unix:"$VM/qmp.sock",server=on,wait=off \
  -serial file:"$VM/serial.log" \
  "${display[@]}"
