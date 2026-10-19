#!/usr/bin/env bash
# Save a PNG of the running VM's screen via QMP: build/screenshot.sh [out.png]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$ROOT/screenshots/kflux-$(date +%Y%m%d-%H%M%S).png}"
mkdir -p "$(dirname "$OUT")"
python3 - "$ROOT/vm/qmp.sock" "$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT")" <<'EOF'
import json, socket, sys
s = socket.socket(socket.AF_UNIX); s.connect(sys.argv[1]); f = s.makefile("rw")
def cmd(c, **a):
    f.write(json.dumps({"execute": c, "arguments": a} if a else {"execute": c}) + "\n"); f.flush()
    while True:
        r = json.loads(f.readline())
        if "return" in r or "error" in r:
            return r
json.loads(f.readline())
cmd("qmp_capabilities")
r = cmd("screendump", filename=sys.argv[2], format="png")
if "error" in r:
    sys.exit(r["error"]["desc"])
EOF
echo "$OUT"
