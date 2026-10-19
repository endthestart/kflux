# Fluxbox, then and now: research for kflux

Date: 2026-10-18. Detailed reports with every citation:
[raw/01-fluxbox-features.md](raw/01-fluxbox-features.md) (features and file formats, checked against the 1.3.7 source)
and [raw/02-fluxbox-culture.md](raw/02-fluxbox-culture.md) (styles, screenshots, dotfiles, licences).
labwc, Waybar and CachyOS facts below come from the shipped 0.20.2 / 0.15.0 man pages and package metadata, read directly in a CachyOS container.

## 1. What Fluxbox was

Fluxbox is a Blackbox-derived X11 stacking window manager. Its last release
was 1.3.7 on 2015-02-08. Master has had about 226 small commits since then,
with no release ([fluxbox news](https://fluxbox.org/news/), [git](https://github.com/fluxbox/fluxbox)).
It is MIT licensed ([COPYING](https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/COPYING)).
Arch still packages a git snapshot, 1.3.7+221, which ships 27 styles.

Its appeal was a whole desktop held in a few short text files under `~/.fluxbox/`:

| File | What it holds |
|---|---|
| `init` | X-resource lines: toolbar, slit, workspaces, focus model, placement, titlebar buttons, style ([man](https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/doc/asciidoc/fluxbox.txt)) |
| `keys` | One line per binding: `Mod1 F2 :Exec fbrun`, `OnDesktop Mouse3 :RootMenu`, with contexts, chords, keymodes, `MacroCmd`/`ToggleCmd`/`If` ([man](https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/doc/asciidoc/fluxbox-keys.txt)) |
| `apps` | Per-window rules: workspace, size, position with anchor, layer, sticky, shaded, decorations, auto-grouping into tabs, `[startup]` ([man](https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/doc/asciidoc/fluxbox-apps.txt)) |
| `menu` | The root menu: `[exec] (Label) {cmd} <icon>`, `[submenu]`, `[stylesdir]`, `[workspaces]`, `[config]`, `[include]` ([man](https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/doc/asciidoc/fluxbox-menu.txt)) |
| `windowmenu` | The titlebar right-click menu: `[shade] [stick] [sendto] [layer] [alpha] [close]` |
| `startup` | Shell script ending `exec fluxbox` |
| styles | Resource files (`toolbar.clock: Raised Gradient Diagonal Bevel1`, `.color`, `.colorTo`, `.textColor`, fonts with shadow/halo) switched live from the menu ([man](https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/doc/asciidoc/fluxbox-style.txt)) |

Signature features:

- **Toolbar**: workspace name with prev/next arrows, an iconbar (task list) with seven modes, systray and clock. It sits at one of 12 edge or corner positions, on the Dock layer, at a width percentage.
- **Slit**: a dock for WindowMaker dockapps (wmclock, wmcpuload, gkrellm and similar).
- **Tabs**: Ctrl-drag a titlebar onto another window to group them, with tabs in the titlebar or outside it. This was the feature people remembered most.
- **Seven layers**, Menu 0 to Desktop 12, plus sticky windows and shading by double-clicking the titlebar.
- **Desktop mouse**: right-click opens the root menu, middle-click the workspace menu, and the wheel switches workspaces.
- **Styles**: textures in eight gradient types with bevels and interlacing, all switchable live from the root menu.

The defaults that shipped with it (1.3.7):

- **Keys**: Alt+F1 opens a terminal, Alt+F2 runs fbrun, Alt+Tab cycles windows, Ctrl+F1–F12 switch workspaces, Super+F*n* sends a window to a workspace, Alt+drag moves and Alt+right-drag resizes.
- **Style**: `bloe`, not Emerge.
- **Root menu**: none ships; `fluxbox-generate_menu` builds it.

## 2. What peak-era desktops looked like

- **Popularity.** Fluxbox topped a LinuxQuestions "Window Manager of the Year" poll with 214 of 753 votes ([capture](https://web.archive.org/web/20180805214457/http://www.linuxquestions.org/questions/showthread.php?s=&threadid=116368)). Half of Pling's 197 "Fluxbox Themes" date from 2007–2009 ([OCS API](https://api.pling.com/ocs/v1/content/data?search=fluxbox&pagesize=100&format=json)).
- **The recipe.** Screenshot threads from 2005–2008 repeat the same desktop ([Arch, May 2005](https://bbs.archlinux.org/viewtopic.php?pid=86645), [Arch, Dec 2005](https://bbs.archlinux.org/viewtopic.php?pid=126494), [FreeBSD, 2008](https://forums.freebsd.org/threads/screenshots.412/)):
  - a plain, dark, bevelled style
  - torsmo or conky stats in a bottom corner
  - a pseudo-transparent aterm or urxvt
  - gkrellm or dockapps down one edge
  - iDesk icons
  - Artwiz bitmap fonts (snap, glisp, lime)
- **Signature styles that map cleanly to labwc** (vertical-gradient titlebars): Flux, Artwiz, MerleyKay and Meta. Results, Outcomes, Nyz and Twice use bevelled diagonals; labwc can only approximate them in titlebars, though the Waybar toolbar renders them in full.
- **Licences** ([details](raw/02-fluxbox-culture.md#4-licensing)):
  - Fluxbox's code and tree are MIT. Of its 27 styles, tenner's 11 (arch, bloe, bora_*, carp, green_tea, ostrich, zimek_*) carry CC BY-SA 3.0 headers. The other 16 carry no licence text, so keep their author lines.
  - kflux uses the styles unmodified from CachyOS's `fluxbox` package and converts them on the user's machine, so it redistributes no derivatives.
  - Terminus (OFL) stands in for the Artwiz fonts. Those are GPL-2 and not packaged, and the styles' X core fonts (lucida) are unavailable on Wayland.
  - Most Pling items and many GitHub dotfile repos declare no licence. kflux avoids them.
- **Prior art on Wayland.** [ecliptik/fluxland](https://github.com/ecliptik/fluxland) (MIT, 17 stars, last push 2026-03-04) is a wlroots Fluxbox clone. It has tabs, keymodes, a toolbar and a slit, and reads Fluxbox styles. Its README says it was "100% vibe coded using Claude Code". It pins wlroots 0.18, which Arch and CachyOS no longer ship (only 0.20), and it has no releases or packages. See the decision record.
- **Converters.** Openbox's `themeupdate.py` (GPL-2) converts Fluxbox styles to Openbox 3, and ob-2-fb goes the other way. No converter from Fluxbox styles to GTK, Qt or KDE colours was found, so kflux's is new.

## 3. The modern landscape (October 2026)

- **Fluxbox** is X11-only. Plasma 6.8 (2026-10-14) dropped its X11 session and 6.7 is the last series with one ([Phoronix](https://www.phoronix.com/news/KDE-Plasma-68-Wayland-Exclusive), [linuxiac](https://linuxiac.com/?p=221075)). Running Fluxbox would mean leaving KDE's direction of travel.
- **labwc 0.20** (2026-05-25; Arch/CachyOS ship 0.20.2) is an Openbox-style stacking Wayland compositor built on wlroots 0.20 ([Phoronix](https://phoronix.com/news/Labwc-0.20-Compositor)). From its man pages:
  - **Config**: `rc.xml`, `menu.xml` (pipe menus, accelerators), `themerc` plus `themerc-override`, `autostart`, `environment`.
  - **Actions**: ShowMenu (root, client, send-to, window list), If/ForEach, GoToDesktop/SendToDesktop, Shade, ToggleOmnipresent, ToggleAlwaysOnTop/Bottom, ToggleDecorations, ToggleShowDesktop, snapping and regions.
  - **Window rules** that run actions.
  - **Protocols**: layer-shell, wlr/ext foreign-toplevel, ext-workspace, wlr output-management and power, screencopy, session-lock, idle-notifier, virtual-keyboard.
  - **Renderer**: pixman (software) is supported, which matters in a VM.
  - **Gaps against Fluxbox**: no tabs or grouping, and no chained keys or keymodes. Themes have only Solid, Vertical and SplitVertical gradients, with no bevels or handles. There is no built-in toolbar or slit.
- **Waybar 0.15** gives labwc a Fluxbox toolbar. `ext/workspaces` with `active-only` shows just the current workspace name. It also has `wlr/taskbar` for the iconbar, `tray`, `clock`, custom modules for the arrows and buttons, and GTK CSS, which can express every Fluxbox gradient and bevel. **sfwbar** (beta) is the alternative, with its own pager and scanner widgets.
- **KDE outside Plasma**: KDE apps, standalone System Settings modules, KDE Connect, polkit-kde, KWallet and portal-kde all run on wlroots compositors. What needs plasmashell or KWin: Plasma applets (network, audio, notifications), KScreen display settings, and portal-kde screencast. kflux uses wlr portals, nm-applet, mako and wdisplays for those. In CachyOS's repos, portal-kde, plasma-nm and plasma-pa already pull in plasma-workspace and KWin.
- **CachyOS**: the official `cachyos/cachyos` Docker image (x86_64) works as a pacstrap builder. Its repos split into generic `cachyos` and the CPU-optimised `-v3`/`-v4`/`-znver4`. The generic repo runs on any x86_64, including QEMU TCG. `labwc` and `waybar` come from Arch `extra`; `sfwbar`, `linux-cachyos` 7.2 and `cachyos-settings` come from the `cachyos` repo. Fluxbox itself is in `extra`, though the installer doesn't offer it.

## 4. Fluxbox → kflux mapping

| Fluxbox | kflux (labwc + Waybar + KDE) |
|---|---|
| `init` | `~/.config/kflux/init`, same resource names; `kflux` renders labwc `rc.xml` and Waybar configs |
| `keys` | same syntax; translated to labwc keybinds and mousebinds (xterm becomes Konsole, fbrun becomes KRunner) |
| `apps` | same syntax; translated to labwc `windowRules`; `[startup]` honoured |
| `menu`, `windowmenu` | same syntax, plus a `[pipe]` extension; translated to labwc `menu.xml` |
| styles | unmodified Fluxbox styles: labwc `themerc`, SVG or converted-XPM buttons, Waybar CSS, KDE colour scheme, mako, swaylock, wallpaper |
| toolbar | Waybar: ◂ workspace-name ▸, iconbar, tray, clock |
| slit + dockapps | a second Waybar with 64×64 bevelled tiles (clock, cpu, mem, net, volume, custom), listed in `slitlist` |
| fbrun | KRunner |
| Reconfigure | `kflux reconfigure` (root menu → kflux → Reload config) |
| tabs, keymodes, chains, ToggleCmd, SetAlpha | not available; `kflux warnings` lists anything dropped |
