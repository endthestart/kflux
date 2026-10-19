#!/usr/bin/env bash
# Check a freshly booted kflux VM: session pieces, KDE functionality, portals.
# Prints PASS/FAIL lines; exit status is the number of failures.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
"$ROOT/build/vm-ssh.sh" --wl 'bash -s' <<'EOF'
fails=0
ok()   { printf "PASS  %s\n" "$*"; }
bad()  { printf "FAIL  %s\n" "$*"; fails=$((fails+1)); }
chk()  { local what="$1"; shift; if "$@" >/dev/null 2>&1; then ok "$what"; else bad "$what"; fi; }

echo "== system"
. /etc/os-release; echo "      $PRETTY_NAME, kernel $(uname -r), $(systemd-detect-virt)"
chk "graphical.target reached"      systemctl is-active graphical.target
chk "greetd autologin session"      pgrep -x labwc
chk "labwc with tabs (labwc-kflux)"  pacman -Q labwc-kflux
chk "tab bindings translated"       grep -q 'name="NextTab"' ~/.config/labwc/rc.xml
echo "== kflux session"
chk "toolbar (waybar)"              pgrep -f 'waybar -c .*/toolbar.json'
chk "slit (waybar)"                 pgrep -f 'waybar -c .*/slit.json'
chk "wallpaper (swaybg)"            pgrep -x swaybg
chk "notifications (mako)"          pgrep -x mako
chk "conky corner (Xwayland)"       pgrep -x conky
chk "translation warnings empty"    test ! -s ~/.cache/kflux/warnings.txt
chk "rc.xml generated"              test -s ~/.config/labwc/rc.xml
chk "theme generated"               test -s ~/.local/share/themes/kflux-current/labwc/themerc
echo "== KDE behind it"
chk "KDE colour scheme applied"     grep -q '^ColorScheme=kflux-' ~/.config/kdeglobals
chk "polkit-kde agent"              pgrep -f polkit-kde-authentication-agent-1
chk "KDE Connect daemon"            pgrep -x kdeconnectd
chk "nm-applet tray"                pgrep -x nm-applet
chk "NetworkManager online"         nmcli -t -f STATE general
chk "PipeWire audio"                pgrep -x pipewire
chk "portal: kde backend"           busctl --user status org.freedesktop.impl.portal.desktop.kde
chk "portal: wlr backend"           busctl --user status org.freedesktop.impl.portal.desktop.wlr
chk "notify-send delivered"         notify-send -a kflux "kflux" "Notifications work (mako)"
for app in "dolphin" "konsole" "kate" "systemsettings kcm_pulseaudio" \
           "systemsettings kcm_networkmanagement" "systemsettings kcm_colors" "krunner"; do
  setsid -f $app >/tmp/verify-${app// /_}.log 2>&1
  sleep 14
  bin=${app%% *}
  if pgrep -x "$bin" >/dev/null; then ok "app starts and stays up: $app"; else bad "app: $app ($(tail -1 /tmp/verify-${app// /_}.log))"; fi
  pkill -x "$bin"; sleep 1
done
echo "== $fails failure(s)"
exit $fails
EOF
