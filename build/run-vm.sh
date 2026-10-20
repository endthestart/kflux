#!/usr/bin/env bash
# Boot the kflux image under QEMU: KVM on Linux, HVF on Intel Macs, TCG elsewhere.
#   build/run-vm.sh             window (Cocoa on macOS, GTK on Linux)
#   build/run-vm.sh --headless  no window; VNC on 127.0.0.1:5921
# SSH: ssh -i .cache/ssh/id_ed25519 -p 2232 flux@127.0.0.1
# Screenshot: build/screenshot.sh [file.png]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VM="$ROOT/vm"
# UEFI firmware (OVMF/edk2): Homebrew's QEMU on macOS, distro packages on Linux.
# Override with KFLUX_OVMF_CODE and KFLUX_OVMF_VARS.
OVMF_CODE="${KFLUX_OVMF_CODE:-}"; OVMF_VARS_TEMPLATE="${KFLUX_OVMF_VARS:-}"
if [[ -z "$OVMF_CODE" ]]; then
  for pair in \
    "$(brew --prefix qemu 2>/dev/null)/share/qemu/edk2-x86_64-code.fd:$(brew --prefix qemu 2>/dev/null)/share/qemu/edk2-i386-vars.fd" \
    "/opt/homebrew/share/qemu/edk2-x86_64-code.fd:/opt/homebrew/share/qemu/edk2-i386-vars.fd" \
    "/usr/share/edk2/x64/OVMF_CODE.4m.fd:/usr/share/edk2/x64/OVMF_VARS.4m.fd" \
    "/usr/share/OVMF/OVMF_CODE_4M.fd:/usr/share/OVMF/OVMF_VARS_4M.fd" \
    "/usr/share/edk2/ovmf/OVMF_CODE.fd:/usr/share/edk2/ovmf/OVMF_VARS.fd"; do
    if [[ -f "${pair%%:*}" ]]; then OVMF_CODE="${pair%%:*}"; OVMF_VARS_TEMPLATE="${pair#*:}"; break; fi
  done
fi
[[ -f "$OVMF_CODE" ]] || { echo "no OVMF firmware found: install edk2-ovmf or set KFLUX_OVMF_CODE" >&2; exit 1; }

# Acceleration: KVM on Linux, HVF on Intel Macs, else software emulation.
if [[ -w /dev/kvm ]]; then
  accel=(-accel kvm -cpu host)
elif [[ "$(uname -s)" == Darwin && "$(uname -m)" == x86_64 ]]; then
  accel=(-accel hvf -cpu host)
else
  accel=(-accel tcg,thread=multi,tb-size=1024 -cpu max)
fi
CPUS="${KFLUX_CPUS:-4}"     # budget: at most 4 vCPUs
MEM="${KFLUX_MEM:-4G}"      # budget: at most 6 GiB
RES="${KFLUX_RES:-1280x800}"
SSH_PORT="${KFLUX_SSH_PORT:-2232}"
VNC_DISPLAY="${KFLUX_VNC_DISPLAY:-21}"   # 5900 + 21

[[ -f "$VM/kflux.qcow2" ]] || { echo "no image: run build/build.sh first" >&2; exit 1; }
[[ -f "$VM/OVMF_VARS.fd" ]] || cp "$OVMF_VARS_TEMPLATE" "$VM/OVMF_VARS.fd"

if [[ "$(uname -s)" == Darwin ]]; then display=(-display cocoa,show-cursor=on); else display=(-display gtk); fi
if [[ "${1:-}" == "--headless" ]]; then
  display=(-display none -vnc "127.0.0.1:$VNC_DISPLAY")
fi

rm -f "$VM/qmp.sock"
exec qemu-system-x86_64 \
  -name kflux \
  -machine q35 "${accel[@]}" \
  -smp "$CPUS" -m "$MEM" \
  -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
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
