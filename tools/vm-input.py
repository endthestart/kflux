#!/usr/bin/env python3
"""Drive the kflux VM's pointer/keyboard over QMP (for demos and screenshots).

  vm-input.py click X Y [left|right|middle]   absolute click (screen pixels)
  vm-input.py move X Y
  vm-input.py keys ctrl alt f1 ...           press a key chord (QEMU qcode names)
  vm-input.py drag X1 Y1 X2 Y2 [ctrl ...]    left-drag, holding the given modifiers
"""
import json
import os
import socket
import sys
import time

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
W, H = (int(v) for v in os.environ.get("KFLUX_RES", "1280x800").split("x"))


def qmp():
    s = socket.socket(socket.AF_UNIX)
    s.connect(os.environ.get("KFLUX_QMP", os.path.join(ROOT, "vm", "qmp.sock")))
    f = s.makefile("rw")
    json.loads(f.readline())

    def cmd(c, **a):
        f.write(json.dumps({"execute": c, "arguments": a} if a else {"execute": c}) + "\n")
        f.flush()
        while True:
            r = json.loads(f.readline())
            if "return" in r or "error" in r:
                return r
    cmd("qmp_capabilities")
    return cmd


def abs_events(x, y):
    return [{"type": "abs", "data": {"axis": "x", "value": int(x * 32767 / (W - 1))}},
            {"type": "abs", "data": {"axis": "y", "value": int(y * 32767 / (H - 1))}}]


def main():
    cmd = qmp()
    op = sys.argv[1]
    if op in ("move", "click"):
        x, y = int(sys.argv[2]), int(sys.argv[3])
        cmd("input-send-event", events=abs_events(x, y))
        if op == "click":
            b = sys.argv[4] if len(sys.argv) > 4 else "left"
            time.sleep(0.15)
            cmd("input-send-event", events=[{"type": "btn", "data": {"down": True, "button": b}}])
            time.sleep(0.12)
            cmd("input-send-event", events=[{"type": "btn", "data": {"down": False, "button": b}}])
    elif op == "drag":
        x1, y1, x2, y2 = (int(v) for v in sys.argv[2:6])
        mods = [{"type": "key", "data": {"down": d, "key": {"type": "qcode", "data": m}}}
                for m in sys.argv[6:] for d in (True,)]
        cmd("input-send-event", events=abs_events(x1, y1))
        time.sleep(0.15)
        if mods:
            cmd("input-send-event", events=mods)
            time.sleep(0.1)
        cmd("input-send-event", events=[{"type": "btn", "data": {"down": True, "button": "left"}}])
        time.sleep(0.2)
        steps = 12
        for i in range(1, steps + 1):
            cmd("input-send-event", events=abs_events(x1 + (x2 - x1) * i // steps,
                                                      y1 + (y2 - y1) * i // steps))
            time.sleep(0.08)
        time.sleep(0.2)
        cmd("input-send-event", events=[{"type": "btn", "data": {"down": False, "button": "left"}}])
        if mods:
            time.sleep(0.1)
            for m in mods:
                m["data"]["down"] = False
            cmd("input-send-event", events=mods)
    elif op == "keys":
        keys = [{"type": "qcode", "data": k} for k in sys.argv[2:]]
        cmd("send-key", keys=keys)


if __name__ == "__main__":
    main()
