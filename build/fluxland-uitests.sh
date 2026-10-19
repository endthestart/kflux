#!/usr/bin/env bash
# Run fluxland's own pytest UI suite inside the running kflux VM, against a
# nested headless fluxland (it needs a real PTY for foot, which the amd64
# builder container under emulation lacks). Installs the test deps on first use.
# Two adaptations to the VM's copy of the tests, not to fluxland: foot gets
# 20 s instead of 2 s to map under TCG emulation, and its title is locked,
# because CachyOS's bash prompt retitles the terminal and the harness finds
# windows by title.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
COPYFILE_DISABLE=1 tar -C "$ROOT/third_party/fluxland/tests" --no-xattrs -cf - ui |
  "$ROOT/build/vm-ssh.sh" 'rm -rf /tmp/fluxland-ui && mkdir -p /tmp/fluxland-ui && tar -C /tmp/fluxland-ui -xf - &&
  sed -i -e "s/timeout=2\\.0):/timeout=20.0):/" \
    -e "s/Exec foot --title/Exec foot -o locked-title=yes --title/" /tmp/fluxland-ui/ui/conftest.py'
"$ROOT/build/vm-ssh.sh" 'pacman -Q python-pytest python-pytest-timeout python-pillow >/dev/null 2>&1 ||
  echo flux | sudo -S -p "" pacman -S --noconfirm --needed python-pytest python-pytest-timeout python-pillow >/dev/null'
"$ROOT/build/vm-ssh.sh" "cd /tmp/fluxland-ui/ui && rm -rf /tmp/fluxland-test && env -u WAYLAND_DISPLAY \
  FLUXLAND_TEST_HEADLESS=1 python3 -m pytest -q -p no:cacheprovider --timeout=120 ${*:-} 2>&1 | tail -40"
