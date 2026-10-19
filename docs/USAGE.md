# Using kflux

kflux is a Fluxbox-style desktop. labwc manages the windows, Waybar draws the
toolbar and slit, and KDE's apps and services do the rest. You configure it the
Fluxbox way: a few short text files.

## First login

Pick **kflux** at your login screen; on CachyOS that's SDDM's session menu. The
first login creates `~/.config/kflux/` from the defaults and shows a welcome
notification.

- **Right-click the desktop** for the root menu. **Super+Space** opens it from anywhere.
- **Middle-click the desktop** for the window list; **scroll** to switch workspaces.
- **Alt+F1** opens a terminal (Konsole); **Alt+F2** runs a program (KRunner).
- **Alt+Tab** cycles windows. **Ctrl+F1–F4** go to workspaces 1–4.
- **Alt+drag** moves a window; **Alt+right-drag** resizes it.
- **Double-click a titlebar** to shade it (roll it up). **Right-click it** for the window menu.

## The files

All in `~/.config/kflux/`, in Fluxbox's own syntax. After editing one, choose
**kflux → Reload config** from the root menu, or run `kflux reconfigure`.

| File | What it controls | Format reference |
|---|---|---|
| `init` | toolbar, slit, workspaces and their names, focus model, titlebar buttons, style; plus `kflux.*` extras (terminal, editor, conky, lock timeout, keyboard layout, wallpaper) | fluxbox(1), RESOURCES |
| `keys` | keyboard and mouse bindings | fluxbox-keys(5) |
| `apps` | per-window rules (workspace, size, position, layer, sticky, decorations) and `[startup]` programs | fluxbox-apps(5) |
| `menu` | the root menu; `[pipe] (Label) {command}` adds a dynamic submenu | fluxbox-menu(5) |
| `windowmenu` | the titlebar right-click menu | fluxbox-menu(5) |
| `slitlist` | tiles in the slit: `clock cpu mem net volume disk`, or `custom: LABEL : command` | — |
| `startup` | shell commands run once at login | — |

Old Fluxbox files mostly work as they are. Copy your `~/.fluxbox/keys` or
`menu` over and run `kflux warnings` to see what didn't translate. Typical
casualties are tabs, keymodes, chained keys and raw keycodes.

## Changing the look

**kflux → System Styles** lists the classic Fluxbox styles (from the `fluxbox`
package). Picking one restyles everything live:

- window titlebars and buttons
- toolbar and slit
- menus and notifications
- the lock screen and wallpaper
- running KDE apps, through a generated KDE colour scheme

Your own styles go in `~/.config/kflux/styles/`. From a shell:

```bash
kflux styles
```

```bash
kflux style Artwiz
```

## Changing key bindings

**kflux → Configure → Key bindings** switches between presets:

| Preset | What it is |
|---|---|
| `kflux` | the Fluxbox defaults plus Super shortcuts (default) |
| `fluxbox` | Fluxbox 1.3.7's stock keys file, verbatim |

Picking a preset replaces `~/.config/kflux/keys`. The first time, your own file
is saved as `keys.bak`. From a shell:

```bash
kflux keys fluxbox
```

Your own presets go in `~/.config/kflux/keys.d/`.

## KDE behind it

| Need | Where |
|---|---|
| System settings | root menu → KDE → System Settings (or Network, Audio, Colours) |
| Network | tray icon, or KDE → Network |
| Volume | the VOL tile in the slit: scroll to change, click for KDE's audio settings |
| Phone | KDE Connect (tray) |
| Displays | KDE → Displays (wdisplays; KDE's display settings need KWin) |
| Run anything | Alt+F2 (KRunner) |

## Tabs

Windows can share one frame as tabs, as in Fluxbox (this needs the
`labwc-kflux` package; `kflux doctor` says whether you have it):

| Do | How |
|---|---|
| Tab a window into another | Ctrl-drag its titlebar onto the other window's titlebar |
| Tab the window underneath into this one | Super+G |
| Switch tabs | click a tab, or Super+Tab / Super+Shift+Tab |
| Take a tab out | Ctrl-drag it off the titlebar, or Super+Shift+G |
| Always open two apps as tabs | a `[group]` block in `~/.config/kflux/apps` (example in the file) |

A group moves, resizes, maximizes, minimizes and changes workspace as one
window, and shows up once in the taskbar and in Alt+Tab. The keys file takes
Fluxbox's `NextTab`, `PrevTab`, `Tab N`, `MoveTabLeft`, `MoveTabRight`,
`DetachClient`, `ActivateTab` and `StartTabbing`, plus kflux's
`GroupWithWindowBelow`.

## When something's off

```bash
kflux doctor
```

It checks dependencies, your config files, the running helpers and the
session environment.

```bash
kflux warnings
```

It lists config lines that couldn't be translated.

Logs are in `~/.cache/kflux/`: labwc.log, toolbar.log, slit.log and autostart.log.
