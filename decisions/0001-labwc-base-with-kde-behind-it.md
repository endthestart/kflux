# 0001: labwc as the base, KDE apps and services behind it

Date: 2026-10-18. Status: accepted for the proof of concept.

## Question

Make Fluxbox's simplicity and configurability available with KDE's
functionality. This is a hobby project, so the fun or educational route
is allowed to win. The candidates:

1. **Plasma, configured and themed** to look and act like Fluxbox.
2. **labwc as the window manager**, with KDE's apps and services running on it.
3. **A fork of KDE**: KWin and/or the Plasma shell, changed to behave like Fluxbox.

The research turned up a fourth candidate:

4. **[fluxland](https://github.com/ecliptik/fluxland)**, an existing Wayland
   Fluxbox clone with KDE apps on top.

## Decision

Option 2 for the proof of concept. kflux is labwc plus Waybar, driven by
Fluxbox-format text files and unmodified Fluxbox styles:

- the files are `init`, `keys`, `apps`, `menu`, `windowmenu` and a `slitlist`
- a small translator, `kflux`, renders them into labwc, Waybar, mako, swaylock and KDE colour configs
- KDE's apps and services run on top
- Plasma stays installed as a fallback session

Option 3 has the most fun in it, but most of that fun doesn't need a fork. The
one feature that does is window tabs. kflux records tabs as the obvious phase-2
fork project, time-boxed and built on a separate Intel machine (see the last
section), rather than the base for the first proof of concept.

## Why

**What's missing is Fluxbox's configuration model, and Plasma can't
provide it.** Plasma users already have Plasma. What they lack is a desktop
whose whole behaviour sits in a few short text files: right-click the desktop
for a menu you wrote, switch the entire look from that menu, and paste in a
keys file from 2006. On Plasma, the equivalent state lives in
`plasma-org.kde.plasma.desktop-appletsrc`, `kwinrc`, `kglobalshortcutsrc`,
Aurorae SVGs and a colour scheme. All of those are written by GUIs and are not
meant for hand editing. Option 1 could copy the look but not the model.

**labwc's model is already Fluxbox's model.** It uses the same lineage of
config: Openbox-style `rc.xml`, `menu.xml` and `themerc`. Checked against the
0.20.2 man pages:

- root and client menus on the desktop, with pipe menus
- conditional actions (`If`, `ForEach`)
- window rules with actions (the apps file maps onto these)
- shade, omnipresent (stick), always-on-top and always-on-bottom (layers)
- virtual desktops with names, and a window-switcher OSD
- edge resistance and snapping

It also speaks the protocols a Fluxbox-style toolbar needs: layer-shell,
wlr and ext foreign-toplevel, ext-workspace, output management, screencopy,
session lock and virtual keyboard. Most Fluxbox keys translate one-to-one.

**Most of KDE survives off Plasma.** These run on labwc:

- Dolphin, Konsole, Kate and KRunner, which replaces fbrun
- System Settings and its standalone modules (network, audio, colours, icons, fonts)
- KDE Connect and its tray indicator
- the polkit agent and KWallet
- the KDE file dialogs, through xdg-desktop-portal-kde
- Breeze and KDE colour schemes, through plasma-integration

kflux generates a KDE colour scheme from each Fluxbox style, so KDE apps
recolour live when the style changes.

**The package cost of option 2 is low.** xdg-desktop-portal-kde, plasma-nm
and plasma-pa already depend on plasma-workspace, which pulls in KWin. Adding
`plasma-desktop` for a full fallback Plasma session costs another 34 MiB of
downloads. The extra cost of option 2 is in config glue, not packages.

**Why not the fork, yet.** Most of what a fork would add can be done with
KDE's plugin points, which need no fork:

- a KDecoration plugin that draws Fluxbox styles natively, in C++
- a Plasma desktop containment whose right-click menu is read from a Fluxbox menu file, in QML
- a Plasma shell package, the same mechanism Plasma Mobile and Bigscreen use, holding a toolbar and slit layout
- KWin scripts

Only tabs need KWin itself changed. KWin lost tabbing in the KWin 5
decoration rework and never got it back
([bug 327630](https://bugs.kde.org/show_bug.cgi?id=327630)). A fork also costs
far more than the other two options; see the table below. None of it would
boot to a configured desktop in one evening.

**Why not fluxland, yet.** fluxland is MIT-licensed and built on wlroots. It
already has the things labwc lacks: tabs, keymodes, chained keys, a toolbar,
a slit and native Fluxbox styles. Against that:

- it pins wlroots 0.18, which Arch and CachyOS no longer ship (only 0.20)
- its last push was 2026-03-04
- it has no releases, packages or other users to speak of (17 stars)
- its README says it was "100% vibe coded using Claude Code", about 35,000 lines of C

Adopting it means porting it to wlroots 0.20 first, then owning a large
compositor no one else maintains. That is phase-2 material, not a base for
in one evening. It is also the cheapest route to tabs, because they are already
written.

## What each option costs and keeps

| | 1: Plasma themed | 2: labwc + KDE (chosen) | 3: Fork KWin / Plasma shell |
|---|---|---|---|
| KDE apps (Dolphin, Konsole, Kate, KDE Connect) | all | all | all |
| System Settings | all modules | standalone modules; display settings need KWin, so wdisplays | all modules |
| Notifications, widgets, Overview, effects | yes | mako only; no widgets or effects | yes |
| Text-file config like Fluxbox | no (GUI-written ini files) | yes: Fluxbox's own formats | only if you write the parser into KWin and plasmashell |
| Root menu from a text file | no | yes | yes (custom containment; no fork needed) |
| Fluxbox styles | needs converters to Aurorae, Plasma theme and colour scheme | yes: the 27 shipped styles work unmodified | a native decoration plugin (no fork needed) |
| Toolbar and slit | Plasma panel, close; no slit | Waybar toolbar and dockapp-tile slit, styled from the style | custom shell package |
| Tabs and window grouping | no | no (not in labwc) | **yes, if you write it**: the one thing only a fork gives |
| Resource use | heavier | light | heavier |
| Build cost | none | none (distro packages plus a Python script) | KWin and plasma-workspace from source against KDE Frameworks; slow at 2 vCPUs |
| Maintenance | low | medium: track labwc and Waybar config changes | high: rebase on every Plasma release (every four months, plus bugfix releases); a forked KWin must match plasma-workspace's version exactly, so CachyOS's prompt Plasma updates break it unless you pin |
| Fun and learning | low | medium: a translator across three config worlds | highest: KWin's Wayland internals; tabs could be upstreamed, and users have asked for years |

## Evidence from the proof of concept (2026-10-19)

On a fresh boot of the CachyOS-based image, `build/verify.sh` passes 26 of 26
checks. KDE pieces confirmed working on labwc:

- Dolphin, Konsole, Kate and KRunner
- System Settings' network, audio and colours modules (the network module shows the live wired connection)
- KDE Connect's daemon, the polkit-kde agent, NetworkManager and PipeWire
- the KDE and wlr portal backends
- mako notifications

Switching style from the root menu recolours the window theme, toolbar, slit,
wallpaper, notifications and running KDE apps live. All 27 shipped Fluxbox
styles render. Fluxbox 1.3.7's stock keys file translates with warnings only
for its tab bindings and raw keycodes.

## Costs and risks accepted (option 2)

- **No tabs.** Tabs were Fluxbox's signature feature, and neither the chosen
  base nor Plasma has them. See phase 2.
- **Partial styles.** labwc titlebars support Solid, Vertical and
  SplitVertical gradients, with no bevels, handles or grips. kflux
  approximates the other gradient types and draws bevels into its generated
  SVG buttons. Where a style ships XPM buttons, kflux converts them to PNG.
  The toolbar and slit render full Fluxbox textures through GTK CSS.
- **Unsupported Fluxbox config.** Keymodes, chained keys, ToggleCmd, SetAlpha
  and toolbar auto-hide are not translated. `kflux warnings` lists anything
  dropped.
- **Iconbar shows all workspaces.** Wayland's foreign-toplevel protocol carries
  no workspace, so the iconbar can't limit itself to the current one.
- **Glue maintenance.** kflux is about 2,000 lines of standard-library Python.
  labwc's config is stable and versioned, but it is a dependency to track.

## Phase 2: the fun fork (proposed, not started)

Tabs are the feature worth forking for. There are three places to get them:

- **KWin.** This is the bigger and more educational job, and it benefits every
  Plasma user if upstreamed. A spike would add a minimal "group windows into
  one frame, switch with a tab strip" behind a KWin option. It would be built
  on an Intel Mac (2 vCPUs, 8 GiB, under 60 GB) in a CachyOS VM with KDE's
  build tooling. Then kflux's fallback Plasma session would get Fluxbox keys
  for NextTab and PrevTab.
- **labwc.** This is smaller: a C codebase with an Openbox lineage. kflux's
  own session would get tabs directly. The cost is carrying a patch on labwc.

- **fluxland.** Port it from wlroots 0.18 to 0.20 and run it as a second
  session beside kflux. Its tabs already exist, so the work is API churn, not
  window-management design. Done; see the next section.

Recommendation: start with the fluxland port, because it is the quickest path
to real Fluxbox tabs on this stack and gives a side-by-side comparison with
kflux. Then time-box a KWin tabs spike as the fun and upstreamable project.

## Phase 2: fluxland as a second session (2026-10-19)

fluxland 1.1.0 (upstream commit `32d1009`) now builds against wlroots 0.20.2
and ships in the image as a second session, **fluxland (kflux)**, next to
kflux. The port is one patch,
[third_party/patches/fluxland-wlroots-0.20.patch](../third_party/patches/fluxland-wlroots-0.20.patch):
20 files, +120/−59, with a header that lists every change.
[packaging/arch/fluxland-kflux/PKGBUILD](../packaging/arch/fluxland-kflux/PKGBUILD)
builds it, both for the image and as an AUR-ready package.

**The compile-time churn was small.** Six API changes from the wlroots 0.19
and 0.20 release notes broke the build:

- `wlr_xdg_surface_get_geometry()` was removed
- `wlr_presentation_create()` gained a version argument
- the tablet argument order was swapped
- the Xwayland maximize flags are now per axis
- two input-method signals were renamed
- one drm-lease field was removed

Upstream's meson setup also fails on a clean clone, because it references an
`include/` directory that was never committed.

**The real cost was two wlroots behaviour changes that compile cleanly and
abort at runtime:**

- wlroots now asserts that no configure is sent to a toplevel before its
  first commit, or after an unmap resets it. fluxland set the xdg-decoration
  mode too early, so the first Konsole, Dolphin or foot window crashed the
  compositor. Closing a window crashed it again, when focus moved on.
- wlroots now asserts that no listeners remain on a global when it is
  destroyed. fluxland aborted on every exit.

fluxland's C unit tests didn't catch either, because they stub wlroots.
Nine of them stub the 0.18 API and no longer build (two more fail for reasons
unrelated to the port), so the package skips the unit tests.
What caught these crashes was booting the image, then running fluxland's own
pytest UI suite inside the VM: 82 passed and 73 failed before the fixes,
155 passed with 0 failures after them. The 18 skips are apps that aren't
installed and three upstream "not in headless mode" cases.

**Fluxbox features that were broken in fluxland itself** (also fixed in the
patch):

- Dragging a window onto another to tab it only worked when the target was
  stacked above the dragged window: the hit test found the dragged window,
  which follows the pointer. Upstream's tests only call `StartTabbing` over
  IPC, so no drop was ever tested.
- A dropped tab was hidden but kept keyboard focus.
- `toolbar.tools` only accepted spaces, not Fluxbox's comma-separated list.
  On a Fluxbox init file the toolbar showed only the clock.
- Dockapps in the slit also appeared in the icon bar.

**How the session uses the kflux files.** fluxland reads Fluxbox's formats
natively. At each login, `fluxland-kflux-session` regenerates
`~/.config/fluxland` from `~/.config/kflux`:

- `init`, `keys`, `menu` and `apps` come over as they are, except:
  - `xterm` and `fbrun` become `kflux.terminal` and `kflux.runner`, as the translator does
  - layer names become numbers
  - the `kflux.*` extras are dropped
- the keys file gains the Fluxbox 1.3.7 defaults it leaves out because labwc
  can't use them: Ctrl-drag to tab, Mod4+Tab between tabs, titlebar drag and grips
- the startup file runs the same KDE helpers as kflux, but not Waybar, swaybg
  or conky

The session environment is shared with `kflux-session` through
`/usr/lib/kflux/session-env`.

**Verified on the image** (QEMU TCG, 4 vCPU). Screenshots are in
`screenshots/fluxland-*.png`.

| Check | Result |
|---|---|
| tuigreet lists "fluxland (kflux)" and logging in starts it | works |
| Ctrl-drag Konsole's titlebar onto Dolphin's: one frame, two tabs | works |
| switch tabs by clicking a tab, or with Mod4+Tab | works |
| toolbar: workspace switcher, icon bar, clock (`kflux-Carbon` style) | works |
| slit with two foot dockapps (clock, load) | works |
| kflux keys, menu and apps load; `fluxland -c` reports no errors | works (2 unknown-key warnings) |
| root menu lists all 27 stock Fluxbox styles; bloe loads with its XPM buttons | works |
| Dolphin and Konsole run, with KDE colours and the polkit, KDE Connect and nm-applet helpers | works |
| exit returns to tuigreet with no core dump | works |
| `build/verify.sh` on the kflux session, same image | 26 of 26 |

**Gaps, compared with kflux on labwc:**

- No pipe menus, so the root menu loses kflux's Applications menu.
- `[stylesdir]` lists styles unsorted.
- `titlebar.left` and `titlebar.right` from init are ignored.
- A style picked from the menu is not saved, and it changes only fluxland.
  The KDE colours, mako and swaylock still follow `kflux style`.
- The slit holds Wayland windows only, so kflux's Waybar tiles (cpu, mem, net,
  volume) have no equivalent. With kflux's RightBottom placement, the slit
  covers the right end of the toolbar, including the tray. Fluxbox also
  places the slit on the full screen, so this may be faithful.
- No conky. Xwayland apps weren't tested.

### Should fluxland replace labwc as kflux's base? Not yet

**For it:** it has everything labwc lacks. Tabs, keymodes, chained keys, the
toolbar, the slit and Fluxbox styles are all native. The labwc and Waybar half
of the kflux translator would mostly go away.

**Against it:**

- Getting to a usable session took six fixes beyond the API port. Two were
  crashes on first use that only a real session exposed. Four were in core
  Fluxbox features, and tabbing by mouse didn't work at all.
- Its unit tests test stubs, not wlroots.
- Every wlroots release (about two a year) means another port like this one,
  with no upstream maintainer to share it. labwc is maintained and has users.
- [0002](0002-kwin-tabs-as-a-script.md) has since shown tabs as a KWin script
  that keeps all of KDE.

**Recommendation:** keep labwc as kflux's default session and keep fluxland as
the opt-in tabs session. Use it daily for a while. If it holds up, test what
this pass didn't cover before switching the default: Xwayland apps,
multi-monitor and suspend/resume. Then shrink the translator to the parts
fluxland doesn't do (KDE colours, mako, swaylock, wallpaper). Offering the
patch upstream to ecliptik/fluxland is the maintainer's call. Between the two tab
routes, fluxland is the more faithful Fluxbox and KWin with fluxtabs is the
better-maintained base. That choice is the open question for 1.0.

## Revisit if

- Plasma widgets, Overview or notification history come to matter more than
  the text-file model (switch to option 1: the fallback session is already
  installed);
- the fluxland session survives daily use, including Xwayland apps,
  multi-monitor and suspend (then consider it as the base; see above);
- a tabs spike lands in KWin (then option 1 plus kflux-generated configs gets
  much closer);
- labwc development stalls.
