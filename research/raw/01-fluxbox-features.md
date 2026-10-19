# Fluxbox 1.3.7: features and configuration formats

Researched 2026-10-18. Baseline is the 1.3.7 release tag `Release-1_3_7` (commit dated 2015-02-08). Anything marked **[post-1.3.7]** exists only on master, not in the tag.

## Method and status

- Man pages: the tag's `doc/asciidoc/*.txt` sources ([man-fb], [man-keys], [man-apps], [man-menu], [man-style], [man-patterns], [man-remote], [man-fbrun], [man-fbsetbg], [man-fbsetroot], [man-startfb]).
- Behaviour: the tag's `src/`, extracted with `git archive` and grepped. Defaults below come from the constructors in source, not from the man page. Where manual and code disagree, both are stated (section 0).
- Master: full clone of the repo, HEAD [`6890143d`](https://github.com/fluxbox/fluxbox/commit/6890143d) (2026-10-07). 226 commits after the tag. Post-tag facts are cited by commit.
- History: the repo's [ChangeLog] (version blocks with `YY/MM/DD` stamps, 0.1.4 to 1.3.7) plus release dates from [fluxbox-news].
- Web: fluxbox.org news and features pages (curl), the Arch wiki page [arch] (curl), and fluxbox-wiki.org as captured by the Wayback Machine on 2016-01-11 (curl). WebFetch refused web.archive.org, so those were fetched with curl. git.fluxbox.org does not resolve from this environment, so it was not checked.
- Licence: fluxbox is MIT. [copying] reads "Copyright (c) 2001-2011 The Fluxbox Team" with the standard MIT permission text. The default files reproduced verbatim below are under that licence.

## 0. Surprises

1. **Default toolbar tools.** The 1.3.7 manual says the default includes `prevwindow, nextwindow` ([man-fb] RESOURCES). The code default is `prevworkspace, workspacename, nextworkspace, iconbar, systemtray, clock` ([src-toolbar] lines 211-212, tag).
2. **Titlebar buttons.** The manual gives right-side default `Shade Minimize Maximize Close` and resource path `session.titlebar.{left|right}`. The code defaults the right side to `Minimize Maximize Close` (no Shade) and reads `session.screenN.titlebar.left|right` ([src-window] lines 3425-3436, tag).
3. **Window style family `window.tab.*`.** The 1.3.7 style manual introduction names `window.tab.*` ([man-style]), and the 2016 wiki Tabs page shows `window.tab.label.focus` etc. ([wiki-tabs]). No source file reads any `window.tab` key. The last code reference was removed in commit [`f801b384`](https://github.com/fluxbox/fluxbox/commit/f801b384) (2003-04-25). `data/styles/Makro` still sets those keys, and they do nothing.
4. **Toolbar button size.** The manual lists `toolbar.button.scale`. The code reads `toolbar.button.size` ([src-toolbarTheme] line 37, tag). `toolbar.button.scale` is not read.
5. **Focus model strings.** The default serialises as `ClickFocus`, and the parser accepts `ClickToFocus` ([src-focus] lines 622-642, tag). The tab-focus resource `session.screenN.tabFocusModel` takes `ClickToTabFocus` (default) or `SloppyTabFocus` ([src-focus] lines 649-666). The 1.3.7 manual documents neither the tab-focus resource nor those values. Only the menu labels appear there.
6. **Default style.** `configure.ac` defaults `session.styleFile` to `$prefix/share/fluxbox/styles/bloe` ([src-configure] lines 505-508), not Emerge.
7. **Root menu is generated, not shipped.** `data/menu` is produced at build time by `util/fluxbox-generate_menu` ([data-makemodule]). If the user menu yields no items, fluxbox shows a three-item fallback menu: xterm, Restart, Exit ([src-screen] lines 1276-1285, tag).
8. **Groups file.** `session.groupFile` is documented as deprecated ([man-fb]). The tag does not read it at all ([src-fluxbox] Config struct, lines 243-258).
9. **Arch wiki example is dead.** The Arch page sets `session.screen0.rootCommand: ~/.fehbg` ([arch]). No `rootCommand` resource exists in the tag. The only match is the `[rootcommands]` menu tag. ChangeLog 1.3.0 says "Remove rootcommand from init, as fbsetbg is run automatically nowadays" ([ChangeLog] line 646).
10. **Master documents more than 1.3.7 implements.** Many options in the current master manuals were not in the 1.3.7 manual or code: `session.screenN.struts`, `toolbar/slit.autoRaise`, `iconbar.iconifiedPattern`, `systray.pinLeft|pinRight`, `opaqueResize`, `edgeResizeSnapThreshold`, the `OnSlit` context, `[IgnoreSizeHints]`, `[FocusProtection]`, and several commands. See section 9.
11. **Master doc/code mismatch.** The current master manual documents `ToggleSlitAbove`, but the command is registered as `toggleslitbarabove` ([src-workspacecmd] line 669, master HEAD). `:ToggleSlitAbove` in a keys file will therefore not parse on master.
12. **Opaque resize.** The 1.3.7 code has no resize-opacity resource. `session.screenN.opaqueResize` was added in 2021 (commit [`0279936d`](https://github.com/fluxbox/fluxbox/commit/0279936d)). Its code default is 50 ms for `opaqueResizeDelay`, but the master manual says 40 ([man-fb-master]).
13. **Systray pinning.** `systray.pinLeft|pinRight` came from commit [`7e762f0a`](https://github.com/fluxbox/fluxbox/commit/7e762f0a) (2013-12-14). That commit is not an ancestor of the 1.3.7 tag, so the feature reached master after the release.

---

## 1. Files and paths

Defaults are set in the `Config` struct ([src-fluxbox] lines 243-258, tag).

- `~/.fluxbox/init`: resources. Written by fluxbox on save and restart. Hand edits take effect after Reconfigure ([man-fb] STARTING FLUXBOX and RESOURCES).
- `~/.fluxbox/keys` (`session.keyFile`): key and mouse bindings ([man-keys]).
- `~/.fluxbox/apps` (`session.appsFile`): per-window rules ([man-apps]). Re-read when the next window opens ([man-apps] DESCRIPTION).
- `~/.fluxbox/menu` (`session.menuFile`): root menu ([man-menu]). If missing, the system menu `@pkgdatadir@/menu` is used. If that yields nothing, the internal fallback applies.
- `~/.fluxbox/windowmenu`: window menu. Copied from the system default at startup if absent ([man-menu] FILES).
- `~/.fluxbox/overlay` (`session.styleOverlay`): style overrides applied on top of any style ([man-fb] STYLES).
- `~/.fluxbox/slitlist` (`session.slitlistFile`): dockapp order in the slit ([man-fb] Slitlist File).
- `~/.fluxbox/styles/` (user styles) and `@pkgdatadir@/styles/` (system styles) ([man-style] LOCATION).
- `~/.fluxbox/startup`: shell script run by `startfluxbox` before `exec fluxbox` ([man-startfb]).
- `~/.fluxbox/lastwallpaper`: written by fbsetbg ([fbsetbg-sh]). Format: `option|wallpaper|style|DISPLAY`.
- `~/.fluxbox/fbrun_history`: fbrun history, default ([man-fbrun] `-hf`).
- `~/.fluxbox/menuconfig`, `~/.fluxbox/usermenu`: read by `fluxbox-generate_menu` ([gen], near the top).
- `~/.fluxbox/menu` is regenerated only when you ask, through the Tools menu or the generator.

## 2. `~/.fluxbox/init` resources

### 2.1 Syntax

Each line is an X-resource style pair:

```
session.screen0.toolbar.placement: BottomCenter
session.screen0.toolbar.tools: workspacename, prevworkspace, nextworkspace, iconbar, prevwindow, nextwindow, systemtray, clock
session.screen0.focusModel: ClickToFocus
session.screen0.tab.placement: TopLeft
session.screen0.workspaces: 4
```

- The `screen0` segment becomes `screen1`, `screen2` and so on for multi-head or multi-screen setups ([man-fb] RESOURCES). Defaults below come from constructors in the source files cited with each group.
- Booleans are written `True` or `False`, as in the manual.
- Comments are lines beginning with `!` (see the default file in section 2.5).

### 2.2 Global session resources (1.3.7, [src-fluxbox] lines 243-258)

- `session.ignoreBorder`: false. Lets windows be moved by dragging the border.
- `session.forcePseudoTransparency`: false.
- `session.colorsPerChannel`: 4. Pseudo-colour displays only.
- `session.doubleClickInterval`: 250 ms.
- `session.tabPadding`: 0. Space between tabs.
- `session.tabsAttachArea`: `Window`. Alternative `Titlebar` ([man-fb] session.tabsAttachArea).
- `session.menuSearch`: `itemstart`. Choices `nowhere|itemstart|somewhere` ([src-menusearch]).
- `session.cacheLife`: 5 (minutes). `session.cacheMax`: 200 (KB).
- `session.autoRaiseDelay`: 250 ms.
- `session.styleFile`: compile-time default, bloe ([src-configure] lines 505-508). `session.styleOverlay`, `session.menuFile`, `session.keyFile`, `session.slitlistFile`, `session.appsFile`: defaults in section 1.

### 2.3 Per-screen resources (1.3.7)

Window and focus behaviour ([src-screenres] and [src-focus]):

- `session.screenN.autoRaise`: true. Focused windows raise after `session.autoRaiseDelay`.
- `session.screenN.clickRaises`: true. Clicking anywhere on a window raises it.
- `session.screenN.focusModel`: `ClickToFocus`. Values `MouseFocus`, `StrictMouseFocus`. Serialised default is `ClickFocus`.
- `session.screenN.tabFocusModel`: `ClickToTabFocus`. Values `SloppyTabFocus`. Not in the 1.3.7 manual.
- `session.screenN.focusNewWindows`: true.
- `session.screenN.focusSameHead`: false (Xinerama builds).
- `session.screenN.noFocusWhileTypingDelay`: 0 ms.
- `session.screenN.showwindowposition`: false. Shows a position popup while dragging.
- `session.screenN.defaultDeco`: `NORMAL`. Accepts the same strings as `[Deco]` in apps.
- `session.screenN.windowMenu`: the code default is the installed `windowmenu` file. The manual says `~/.fluxbox/windowmenu` when blank ([man-fb] RESOURCES).
- `session.screenN.allowRemoteActions`: false. Needed for fluxbox-remote ([man-remote] RESOURCES).

Placement and workspaces ([src-placement] and [src-screenres]):

- `session.screenN.windowPlacement`: `RowSmartPlacement`. Values `ColSmartPlacement`, `RowMinOverlapPlacement`, `ColMinOverlapPlacement`, `UnderMousePlacement`, `CascadePlacement`. `AutotabPlacement` is **[post-1.3.7]** (commit [`ea466fa9`](https://github.com/fluxbox/fluxbox/commit/ea466fa9), 2016).
- `session.screenN.rowPlacementDirection`: `LeftToRight` (or `RightToLeft`).
- `session.screenN.colPlacementDirection`: `TopToBottom` (or `BottomToTop`).
- `session.screenN.workspaces`: 4.
- `session.screenN.workspaceNames`: comma-separated list. Read in [src-fluxbox] lines 1120-1135.
- `session.screenN.workspacewarping`: true. Dragging a window past a screen edge changes workspace. Horizontal and vertical splits (`workspacewarpinghorizontal|vertical[offset]`) are **[post-1.3.7]** (2017 commit [`7cb7bfaa`](https://github.com/fluxbox/fluxbox/commit/7cb7bfaa), 2021 batch [`8bc11006`](https://github.com/fluxbox/fluxbox/commit/8bc11006)).

Snapping, maximize and transparency ([src-screenres]):

- `session.screenN.edgeSnapThreshold`: 10 px.
- `session.screenN.edgeResizeSnapThreshold`: **[post-1.3.7]**, default 0 (commit [`1f1d43bd`](https://github.com/fluxbox/fluxbox/commit/1f1d43bd), 2015-09-17).
- `session.screenN.opaqueMove`: true. The code reads this. `opaqueResize` is **[post-1.3.7]**, default false, delay default 50 ms in code vs 40 in the master manual (commit [`0279936d`](https://github.com/fluxbox/fluxbox/commit/0279936d), 2021).
- `session.screenN.fullMaximization`: false.
- `session.screenN.maxIgnoreIncrement`: true. Terminal resize increments are ignored when maximizing.
- `session.screenN.maxDisableMove`, `session.screenN.maxDisableResize`: false.
- `session.screenN.window.focus.alpha`, `session.screenN.window.unfocus.alpha`, `session.screenN.menu.alpha`: 255 each. Range 0-255.
- `session.screenN.menuDelay`: 200 ms. `session.screenN.tooltipDelay`: 500 ms.

Tabs ([src-screenres]):

- `session.screenN.tabs.intitlebar`: true. False places tabs outside the window.
- `session.screenN.tab.placement`: `TopLeft`. Same values as toolbar placement.
- `session.screenN.tab.width`: 64 px.
- `session.screenN.tabs.maxOver`: false.
- `session.screenN.tabs.usePixmap`: true.
- `session.screenN.clientMenu.usePixmap`: true.

Toolbar ([src-toolbar] lines 195-212, tag):

- `session.screenN.toolbar.visible`: true.
- `session.screenN.toolbar.placement`: `BottomCenter`. Values are the 12 edge and corner names in [man-fb] RESOURCES: `BottomLeft BottomCenter BottomRight LeftBottom LeftCenter LeftTop RightBottom RightCenter RightTop TopLeft TopCenter TopRight`.
- `session.screenN.toolbar.layer`: `Dock`. Layer names are in section 7.4.
- `session.screenN.toolbar.height`: 0. Zero means the style controls the height.
- `session.screenN.toolbar.widthPercent`: 100.
- `session.screenN.toolbar.alpha`: 255.
- `session.screenN.toolbar.onhead`: 1.
- `session.screenN.toolbar.autoHide`: false.
- `session.screenN.toolbar.maxOver`: false.
- `session.screenN.toolbar.tools`: `prevworkspace, workspacename, nextworkspace, iconbar, systemtray, clock` (see Surprise 1).
- `session.screenN.strftimeFormat`: `%k:%M` ([src-clock] line 146).
- `session.screenN.toolbar.autoRaise`: **[post-1.3.7]** (commit [`fe8ff872`](https://github.com/fluxbox/fluxbox/commit/fe8ff872), 2016).

Iconbar ([src-iconbar] lines 241-250, tag):

- `session.screenN.iconbar.mode`: `{static groups} (workspace)`. Predefined menu values are listed in section 7.7.
- `session.screenN.iconbar.alignment`: `Relative`. Values `Left`, `Relative`, `Right`. `RelativeSmart` is **[post-1.3.7]** (2021).
- `session.screenN.iconbar.iconWidth`: 128 px. Used for Left and Right alignment.
- `session.screenN.iconbar.iconTextPadding`: 10 px.
- `session.screenN.iconbar.usePixmap`: true.
- `session.screenN.iconbar.iconifiedPattern`: **[post-1.3.7]**, default `( %t )` (commit [`3058861f`](https://github.com/fluxbox/fluxbox/commit/3058861f), 2016).

Slit ([src-slit] lines 234-248, tag):

- `session.screenN.slit.placement`: `RightBottom`. Same values as toolbar.
- `session.screenN.slit.layer`: `Dock`.
- `session.screenN.slit.autoHide`: false.
- `session.screenN.slit.maxOver`: false.
- `session.screenN.slit.alpha`: 255.
- `session.screenN.slit.onhead`: 0.
- `session.screenN.slit.acceptKdeDockapps`: true.
- `session.screenN.slit.autoRaise`: **[post-1.3.7]** (commit [`fe8ff872`](https://github.com/fluxbox/fluxbox/commit/fe8ff872), 2016).
- There is no slit direction resource in 1.3.7. The stacking mode is picked internally (see the `VERTICAL mode` and `HORIZONTAL mode` comments at [src-slit] lines 603-609).

Titlebar ([src-window] lines 3425-3436, tag):

- `session.screenN.titlebar.left`: `Stick`.
- `session.screenN.titlebar.right`: `Minimize Maximize Close` (manual also lists Shade; see Surprise 2).
- Button names: `Close Maximize MenuIcon Minimize Shade Stick LHalf RHalf` ([man-fb] RESOURCES).

Struts, systray and dockapps:

- `session.screenN.struts`: `left, right, top, bottom` pixels. Per-head `struts.<n>` (1-based). **[post-1.3.7]**, commit [`f22435d6`](https://github.com/fluxbox/fluxbox/commit/f22435d6) (2016). The 1.3.7 code honours windows' `_NET_WM_STRUT` ([ChangeLog] line 2715, 0.9.x era) through the Strut class ([src-screen] `availableWorkspaceArea`).
- `session.screenN.systray.pinLeft`, `session.screenN.systray.pinRight`: comma-separated `WM_CLASS` class names. **[post-1.3.7]**, see Surprise 13 and [man-fb-master].
- `session.screenN.iconbar.usePixmap`: see above.

Other:

- `session.screenN.workspaces`, `session.screenN.workspaceNames`: see above.
- `session.screenN.menuDelay`: see above.
- `session.screenN.defaultDeco`: see above.

### 2.4 Post-1.3.7 resources (master only)

- `session.screenN.struts`, `struts.<n>`: commit [`f22435d6`](https://github.com/fluxbox/fluxbox/commit/f22435d6) (2016-08-11).
- `session.screenN.toolbar.autoRaise`, `session.screenN.slit.autoRaise`: commit [`fe8ff872`](https://github.com/fluxbox/fluxbox/commit/fe8ff872) (2016-08-13).
- `session.screenN.iconbar.iconifiedPattern`: commit [`3058861f`](https://github.com/fluxbox/fluxbox/commit/3058861f) (2016-08-13).
- `session.screenN.edgeResizeSnapThreshold`: commit [`1f1d43bd`](https://github.com/fluxbox/fluxbox/commit/1f1d43bd) (2015-09-17).
- `session.screenN.opaqueResize`, `session.screenN.opaqueResizeDelay`: commit [`0279936d`](https://github.com/fluxbox/fluxbox/commit/0279936d) (2021-07-06).
- `session.screenN.workspacewarpinghorizontal|vertical[offset]`: commits [`7cb7bfaa`](https://github.com/fluxbox/fluxbox/commit/7cb7bfaa) (2017-11-19) and [`8bc11006`](https://github.com/fluxbox/fluxbox/commit/8bc11006) (2021-07-06).
- `session.screenN.systray.pinLeft|pinRight`: first commit [`7e762f0a`](https://github.com/fluxbox/fluxbox/commit/7e762f0a) (2013-12-14), on a branch that reached master later.
- `session.screenN.toolbar.button.<name>.label` and `.commands`: documented on master only. The tag's `ButtonTool` has no `label` or `commands` resource ([src-buttontool] at tag).
- `session.screenN.toolbar.button.<name>` tool: the tag contains `ButtonTool.cc` and `GenericTool.cc`, so the tool class exists, but the labelled-button resources came with later commits ([`393ba45f`](https://github.com/fluxbox/fluxbox/commit/393ba45f), 2016-04-05).

### 2.5 Default `init` file (1.3.7, `data/init.in`, verbatim)

Placeholders are expanded at build time, so the installed file differs. `@default_style@` becomes `bloe` by default.

```text
! If you're looking for settings to configure, they won't be saved here until
! you change something in the fluxbox configuration menu.

session.menuFile:	~/.@pkgprefix@fluxbox@pkgsuffix@/menu
session.keyFile: ~/.@pkgprefix@fluxbox@pkgsuffix@/keys
session.styleFile: @default_style@
session.configVersion:	13
```

## 3. Keys file (`~/.fluxbox/keys`)

Source: [man-keys] (tag) and [src-keys] (tag, lines 395-452).

### 3.1 Syntax

```
['modifiers'] 'key' :'command' ['arguments' '...']
```

- The space before `:` is mandatory ([man-keys] DESCRIPTION).
- Commands and modifiers are case-insensitive. Shell arguments are case-sensitive.
- Lines beginning with `#` or `!` are comments.
- Keys: a key name (`a`, `space`) or a numeric keycode (`38`, `0xf3`). Keycodes are used when the keysym has no name. `xev` finds names and codes.

### 3.2 Modifiers and contexts

Modifiers: `Shift`, `Control`, `Mod1` (Alt on PC), `Mod4` (usually the Super/Win key). `xmodmap -pm` lists the rest ([man-keys] MODIFIERS).

Context modifiers, from [src-keys] lines 395-411 at the tag:

- `OnDesktop`: pointer over the root window.
- `OnToolbar`.
- `OnWindow`: pointer over a window.
- `OnWindowBorder`.
- `OnLeftGrip`, `OnRightGrip`: the corner grips.
- `OnTitlebar`.
- `OnTab`.
- `Double`: double-click only.

Not in 1.3.7: `OnSlit` (documented in master, commit [`2678060e`](https://github.com/fluxbox/fluxbox/commit/2678060e), 2016-09-13), and `OnWinButton`, `OnMinButton`, `OnMaxButton` (commit [`4545f4da`](https://github.com/fluxbox/fluxbox/commit/4545f4da), 2016-09-14).

### 3.3 Mouse, click and move

From [src-keys] lines 438-452 at the tag:

- `MouseN`: the button is held down.
- `ClickN`: pressed and released with no movement.
- `MoveN`: the button is held and the bound action fires on every motion.
- Buttons 4 and 5 are the wheel.

Special events from [src-keys] lines 414-430 at the tag:

- `FocusIn`, `FocusOut`: focus gained or lost. Combine with `If` for conditionals.
- `MouseOver`, `MouseOut`: pointer enters or leaves an area.
- `ChangeWorkspace`: fires on workspace change. Binding it to a workspace-changing action will loop.

### 3.4 Chaining

Emacs-style chords are written as `mods1 key1 mods2 key2 :Command`. Example from the manual: `Control c Control x :Quit`. `<ESC>` cancels a partial chord ([man-keys] CHAINING). A 5-second timeout for partial chords is **[post-1.3.7]** (commit [`6ca64223`](https://github.com/fluxbox/fluxbox/commit/6ca64223), 2016-08-31).

### 3.5 Keymodes

Keymodes are named sets of bindings. Only the active one is live ([man-keys] KEYMODES).

```
# enter ResizeMode with Mod4+w, Mod4+r
Mod4 w Mod4 r :KeyMode ResizeMode
ResizeMode: None Up :ResizeVertical -2
ResizeMode: None Down :ResizeVertical +2
ResizeMode: Shift Up :ResizeVertical -10
```

- The mode is entered with `:KeyMode <name>`. The default return key is `Escape`. `:KeyMode default` returns to the default set.
- Introduced in 2006 (commit [`33079d25`](https://github.com/fluxbox/fluxbox/commit/33079d25), 2006-04-12). ChangeLog lists it under 1.0rc ([ChangeLog] line 2112). The wiki says "since revision 4298 and/or version 1.0rc" ([wiki-keymodes]).

### 3.6 Conditions and client patterns

- `Matches 'pattern'`, `Some 'cond'`, `Every 'cond'`, `Not 'cond'`, `And {c1} {c2}`, `Or {c1} {c2}`, `Xor {c1} {c2}`. Used by `If`, `Cond`, `ForEach` and `Map` ([man-keys] Special Commands and Conditions).
- Pattern syntax and property names are in section 4.2 and [man-patterns].

### 3.7 Action reference (1.3.7 manual)

The list below is generated from the tag's manual `COMMANDS` section ([man-keys]). Each entry gives the signature and the first line of the manual's description.


**Mouse Commands**

- `StartMoving` - Start dragging to move the window.
- `StartResizing [corner]` - Start dragging to resize the window as if you had grabbed the window at the specified 'corner'. By default 'corner' is BottomRight, but may be overridden with one of: NearestCorner NearestEdge NearestCornerOrEdge Center...
- `StartTabbing` - Start dragging to add this window to another's tabgroup.
- `ActivateTab` - Activates the tab underneath the mouse.

**Window Commands**

- `Minimize | MinimizeWindow | Iconify` - Minimize the current window, equivalent to the window button.
- `Maximize | MaximizeWindow` - Maximize the current window, equivalent to the window button.
- `MaximizeHorizontal / MaximizeVertical` - Maximize the current window in one direction only, leaving the other dimension unchanged.
- `Fullscreen` - Resize the window's content to fit the whole screen, without any window decoration.
- `Raise / Lower` - Reorder this window to the top or bottom of the window stack, within its current layer. See 'fluxbox(1)' for a discussion of layers.
- `RaiseLayer / LowerLayer [offset]` - Raise the window up to the layer above, or lower it to the layer below. See 'fluxbox(1)' for a discussion of layers.
- `SetLayer layer` - Move the window to the specified layer. 'layer' should be one of AboveDock, Dock, Top, Normal, Bottom, Desktop. See 'fluxbox(1)' for a discussion of layers.
- `Close` - Close the current window, equivalent to the window button.
- `Kill | KillWindow` - Close a window that's not responding to Close, like using xkill(1).
- `Shade | ShadeWindow` - Toggle the shaded state of the current window, equivalent to the window button. A shaded window appears as only the title bar.
- `ShadeOn / ShadeOff` - Set the shaded state of the window to On / Off.
- `Stick | StickWindow` - Toggle the sticky state of the current window, equivalent to the window button. A sticky window is visible on all workspaces.
- `SetDecor decor` - Sets which window decorations will be shown. 'decor' has the same format as the `[Deco]' parameter in the apps file. See 'fluxbox-apps(5)' for more info.
- `ToggleDecor` - Toggles the presence of the window decorations (title bar, window buttons, and resize bar).
- `NextTab / PrevTab` - Cycle to the next / previous tab in the current tab group.
- `Tab number` - Cycle to the given tab in the current tab group, where 1 is the first tab. A negative 'number' counts from the end of the tab group (-1 is the last tab, -2 is the next-to-last, etc.).
- `MoveTabRight / MoveTabLeft` - Reorder the tabs in the current tab group, swapping the current tab with the one to the right / left.
- `DetachClient` - Remove the current tab from the tab group, placing it in its own window.
- `ResizeTo width[%] height[%]` - Resizes the window to the given width and height. If the value is given in percent, then the window size will be based on the current screen's size.
- `Resize delta-width[%] delta-height[%]` - Resizes the window relative to the current width and height. If the value is given in percent, then the window size will be based on the current window's size.
- `ResizeHorizontal delta-width[%] / ResizeVertical delta-height[%]` - Resizes the window in one dimension only. If the value is given in percent, then the window size will be based on the current window's size.
- `MoveTo x[%] y[%] [anchor]` - Moves the window to the given coordinates, given in pixels or relatively to the current screen size if % is specified after the value. If either 'x' or 'y' is set to *, that coordinate will be ignored, and the movement will...
- `Move delta-x delta-y` - Moves the window relative to its current position. Positive numbers refer to right and down, and negative to left and up, respectively.
- `MoveRight d / MoveLeft d / MoveUp d / MoveDown d` - Moves the window relative to its current position by the number of pixels specified in 'd'. If the number is negative, it moves in the opposite direction.
- `TakeToWorkspace workspace / SendToWorkspace workspace` - Sends you along with the current window to the selected workspace. SendToWorkspace just sends the window. The first workspace is number 1, not 0.
- `TakeToNextWorkspace [offset] / TakeToPrevWorkspace [offset]` - Sends you along with the current window to the next or previous workspace. If you set 'offset' to a value greater than the default of 1, it will move you that number of workspaces ahead or behind. If you go beyond the end of...
- `SendToNextWorkspace [offset] / SendToPrevWorkspace [offset]` - Identical to the "TakeTo..." commands, but again this sends only the window, and does not move you away from your current workspace.
- `SetAlpha [alpha [unfocused-alpha]]` - Sets the alpha value of a window. Putting a + or - in front of the value adds or subtracts from the current value. A plain integer sets the value explicitly. no arguments Resets both focused and unfocused settings to default...
- `SetHead number` - Moves the window to the given display head. Only available when fluxbox has been compiled with Xinerama support.
- `SendToNextHead [offset] / SendToPrevHead [offset]` - Sends the current window to the next/previous display head. If you specify an 'offset' greater than 1, it will move the window that many heads. If this takes the window beyond the total number of heads, it will wrap around to...
- `SetXProp PROP=value` - Sets the xproperty 'PROP' of the current window to 'value'. Delete the content of 'PROP' by using 'PROP='.

**Workspace Commands**

- `AddWorkspace / RemoveLastWorkspace` - Adds or removes a workspace from the end of the list of workspaces.
- `NextWorkspace [n] / PrevWorkspace [n] / RightWorkspace [n] / LeftWorkspace [n]` - Switch to the Next / Previous workspace. All versions accept an offset value 'n', which defaults to 1 and refers to the number of workspaces to move at one time. {Next,Prev}Workspace wrap around when going past the last...
- `Workspace number` - Jumps to the given workspace 'number'. The first workspace is 1.
- `NextWindow [{options}] [pattern] / PrevWindow [{options}] [pattern]` - Focuses the next / previous window in the focus list. 'options' is one or more of the following, space delimited: -- static Instead of moving in order of most-recent focus, move in order of when the window was opened (or, the...
- `NextGroup [{options}] [pattern] / PrevGroup [{options}] [pattern]` - Equivalent to NextWindow / PrevWindow above, but with the groups option forced on.
- `GotoWindow number [{options}] [pattern]` - Focuses and activates the window at position 'number' in the focus list. The 'options' and 'pattern' arguments have the same meaning as NextWindow above.
- `Activate [pattern] | Focus [pattern]` - With 'pattern', this is an alias for GoToWindow 1 'pattern'. Without, this behaves like a window command, so that OnWindow events can change the focused window.
- `Attach pattern` - Combines all windows that match the 'pattern' into a single tab group. See CLIENT PATTERNS for more about the 'pattern' arguments.
- `FocusLeft / FocusRight / FocusUp / FocusDown` - Focus to the next window which is located in the direction specified.
- `ArrangeWindows pattern / ArrangeWindowsVertical pattern / ArrangeWindowsHorizontal pattern` - Tries to arrange all windows on the current workspace so that they overlap the least amount possible. ArrangeWindowsVertical prefers vertical splits (windows side by side), whereas ArrangeWindowsHorizontal prefers horizontal...
- `ArrangeWindowsStackLeft pattern / ArrangeWindowsStackRight pattern` - Similar to ArrangeWindows, these commands arrange windows on the current workspace. The currently focussed window is used as the 'main' window, and will fill half the screen, while the other windows are tiled on the other half...
- `ArrangeWindowsStackTop pattern / ArrangeWindowsStackBottom pattern` - Behaves just like ArrangeWindowsStackLeft and ArrangeWindowsStackRight. ArrangeWindowsStackBottom places the main window on the TOP half of the screen, and the tiled windows on the bottom half of the screen....
- `ShowDesktop` - Minimizes all windows on the current workspace. If they are already all minimized, then it restores them.
- `Deiconify mode destination` - Deiconifies windows (or, restores from a minimized state). Where 'mode' may be one of: -- All All icons across all workspaces. AllWorkspace All icons on the current workspace. Last The last icon across all workspaces....
- `SetWorkspaceName name / SetWorkspaceNameDialog` - Sets the name of the current workspace.
- `CloseAllWindows` - Closes all windows on all desktops.

**Menu Commands**

- `RootMenu` - Opens the root menu. See ROOT MENU in fluxbox-menu(5) for details.
- `WorkspaceMenu` - Opens a menu showing all workspaces and windows. See Workspace Menu in fluxbox(1) for details.
- `WindowMenu` - Opens a menu containing actions for the current window. See WINDOW MENU in fluxbox-menu(5) for details.
- `ClientMenu [pattern]` - Opens a menu that contains all windows. If you specify a 'pattern', only matching windows will be in the menu. Selecting a window will jump to that workspace and raise the window. See CLIENT PATTERNS below for more details on...
- `CustomMenu path` - Opens a custom menu file. This 'path' must be a valid menu file in the same format as detailed by the ROOT MENU section of fluxbox-menu(5).
- `HideMenus` - Hide all fluxbox popup menus.

**Window Manager Commands**

- `Restart [path]` - Restarts fluxbox. This does not close any running applications. If the optional 'path' is a path to an executable window manager, that manager is started in place of fluxbox.
- `Quit | Exit` - Exits fluxbox. This will normally cause X to stop as well and terminate all existing applications, returning you to the login manager or console.
- `Reconfig | Reconfigure` - Reloads all fluxbox configuration files including the keys file, apps file, and init file, if they have changed.
- `SetStyle path` - Sets the current style to that given in 'path', which must be the full path to a fluxbox style.
- `ReloadStyle` - Reloads only the current style. Useful after editing a style which is currently in use.
- `ExecCommand args ... | Exec args ... | Execute args ...` - Probably the most-used binding of all. Passes all the arguments to your $SHELL (or /bin/sh if $SHELL is not set). You can use this to launch applications, run shell scripts, etc. Since all arguments are passed verbatim to the...
- `CommandDialog` - Pops up a dialog box that lets you type in any of these commands manually.
- `SetEnv name value | Export name=value` - Sets an environment variable in Fluxbox. It will be passed to any applications spawned by any future ExecCommand commands.
- `SetResourceValue resourcename resourcevalue | SetResourceValueDialog` - Sets a fluxbox resource value, which are normally stored in the init file. See 'fluxbox(1)' for more details on available resources and allowed values.

**Special Commands**

- `MacroCmd {command1} {command2} {command3} ...` - Allows you to execute more than one command with one keybinding. The commands will be executed in series. The { } brackets are literally required, as in the following example:
- `Delay {command} [microseconds]` - Delays running 'command' for the given amount of time. If the same key binding is activated again, the timer will be restarted.
- `ToggleCmd {command1} {command2} ...` - Alternates between the commands. On the first press of the bound key, runs 'command1'. On the next press, runs 'command2'.
- `BindKey keybinding` - Adds the given 'keybinding' (which must be a valid key binding as defined in the DESCRIPTION section above) to your keys file.
- `KeyMode keymode [return-keybinding]` - Activates the named 'keymode' (or, all key binding lines prefaced with the same 'keymode':) and deactivates all others until the 'return-keybinding' (by default Escape) is pressed. The default keymode is named 'default'.
- `ForEach {command} [{condition}] | Map {command} [{condition}]` - Runs the given 'command' (normally one from the Window Commands section above) on each window. If you specify a 'condition' (See Conditions, below) the action will be limited to matching windows.
- `If {condition} {then-command} [{else-command}] | Cond {condition} {then-command} [{else-command}]` - If the 'condition' command returns true, then run the 'then-command', otherwise run the optional 'else-command'. See Conditions below for more information on the 'condition' argument.

**Conditions**

- `Matches pattern` - Returns true if the current window matches the given 'pattern'. See CLIENT PATTERNS below for details on the 'pattern' syntax. If your key binding uses the OnWindow modifier, it matches against the window you clicked, not the...
- `Some condition` - Returns true if any window on any workspace (not just the currently focused one) matches the 'condition'.
- `Every condition` - Returns true if every window on every workspace (not just the current one) matches the 'condition'.
- `Not condition` - Returns true if 'condition' returns false, and vice-versa.
- `And {condition1} {condition2} [{condition3} ...]` - Returns true if and only if all given conditions return true.
- `Or {condition1} {condition2} [{condition3} ...]` - Returns true if any of the listed conditions return true.
- `Xor {condition1} {condition2} [{condition3} ...]` - Returns the boolean xor of the truth values for all conditions listed.

### 3.8 Registered command names at 1.3.7

The tag registers 128 command names through `REGISTER_COMMAND*` macros ([src-cmdparser] lines 35-75). The list is lower-cased because parsing is case-insensitive. Source: `git grep` of the tag's `src/`.

```text
activate, activatetab, addworkspace, and, arrangewindows, arrangewindowshorizontal, 
arrangewindowsstackbottom, arrangewindowsstackleft, arrangewindowsstackright, 
arrangewindowsstacktop, arrangewindowsvertical, attach, bindkey, clientmenu, clientpatterntest, 
close, closeallwindows, commanddialog, cond, custommenu, deiconify, delay, detachclient, every, 
exec, execcommand, execute, exit, export, focus, focusdown, focusleft, focusright, focusup, 
foreach, fullscreen, gotowindow, hidemenus, iconify, if, keymode, kill, killwindow, 
leftworkspace, lower, lowerlayer, macrocmd, map, matches, maximize, maximizehorizontal, 
maximizevertical, maximizewindow, minimize, minimizewindow, move, movedown, moveleft, 
moveright, movetableft, movetabright, moveto, moveup, name, nextgroup, nexttab, nextwindow, 
nextworkspace, not, or, prevgroup, prevtab, prevwindow, prevworkspace, quit, raise, raiselayer, 
reconfig, reconfigure, reloadstyle, removelastworkspace, resize, resizehorizontal, resizeto, 
resizevertical, restart, rightworkspace, rootmenu, saverc, sendtonexthead, sendtonextworkspace, 
sendtoprevhead, sendtoprevworkspace, sendtoworkspace, setalpha, setdecor, setenv, sethead, 
setlayer, setresourcevalue, setresourcevaluedialog, setstyle, settitle, settitledialog, 
setworkspacename, setworkspacenamedialog, setxprop, shade, shadeoff, shadeon, shadewindow, 
showdesktop, some, startmoving, startresizing, starttabbing, stick, stickwindow, tab, 
taketonextworkspace, taketoprevworkspace, taketoworkspace, togglecmd, toggledecor, windowmenu, 
workspace, workspacemenu, xor
```

### 3.9 Commands added after 1.3.7

Registered on master but absent from the tag (names verified against the tag's registry):

- `markwindow`, `gotomarkedwindow`: "shortcut to windows", commit [`174e62ff`](https://github.com/fluxbox/fluxbox/commit/174e62ff) (2020-08-23, Richard Tamin). Fix in [`6168d9c8`](https://github.com/fluxbox/fluxbox/commit/6168d9c8).
- `relabelbutton`: commit [`fbb2d166`](https://github.com/fluxbox/fluxbox/commit/fbb2d166) (2016-06-29).
- `unclutter`: commit [`a5b5be5e`](https://github.com/fluxbox/fluxbox/commit/a5b5be5e) (2016-08-29). Reduces window overlap without resizing.
- `toggleslithidden`: commit [`1473bcf6`](https://github.com/fluxbox/fluxbox/commit/1473bcf6) (2016-08-15).
- `toggletoolbarabove`: commit [`6c0565c4`](https://github.com/fluxbox/fluxbox/commit/6c0565c4) (2016-08-12).
- `toggletoolbarvisible`: commit [`1473bcf6`](https://github.com/fluxbox/fluxbox/commit/1473bcf6) (2016-08-15).
- `toggleslitbarabove`: commit [`6c0565c4`](https://github.com/fluxbox/fluxbox/commit/6c0565c4). **Documented as `ToggleSlitAbove`** (Surprise 11).
- `setfocusprotection`: commit [`6890143d`](https://github.com/fluxbox/fluxbox/commit/6890143d) (2026-10-07, Adam Spiers). Changes the focus protection of one open window. Uses the same values as apps `[FocusProtection]`.

### 3.10 Default keys file (1.3.7, `data/keys`, verbatim)

The file is MIT-licensed under [copying]. Reproduced unchanged from the tag.

```text
# click on the desktop to get menus
OnDesktop Mouse1 :HideMenus
OnDesktop Mouse2 :WorkspaceMenu
OnDesktop Mouse3 :RootMenu

# scroll on the desktop to change workspaces
OnDesktop Mouse4 :PrevWorkspace
OnDesktop Mouse5 :NextWorkspace

# scroll on the toolbar to change current window
OnToolbar Mouse4 :PrevWindow {static groups} (iconhidden=no)
OnToolbar Mouse5 :NextWindow {static groups} (iconhidden=no)

# alt + left/right click to move/resize a window
OnWindow Mod1 Mouse1 :MacroCmd {Raise} {Focus} {StartMoving}
OnWindowBorder Move1 :StartMoving

OnWindow Mod1 Mouse3 :MacroCmd {Raise} {Focus} {StartResizing NearestCorner}
OnLeftGrip Move1 :StartResizing bottomleft
OnRightGrip Move1 :StartResizing bottomright

# alt + middle click to lower the window
OnWindow Mod1 Mouse2 :Lower

# control-click a window's titlebar and drag to attach windows
OnTitlebar Control Mouse1 :StartTabbing

# double click on the titlebar to shade
OnTitlebar Double Mouse1 :Shade

# left click on the titlebar to move the window
OnTitlebar Mouse1 :MacroCmd {Raise} {Focus} {ActivateTab}
OnTitlebar Move1  :StartMoving

# middle click on the titlebar to lower
OnTitlebar Mouse2 :Lower

# right click on the titlebar for a menu of options
OnTitlebar Mouse3 :WindowMenu

# alt-tab
Mod1 Tab :NextWindow {groups} (workspace=[current])
Mod1 Shift Tab :PrevWindow {groups} (workspace=[current])

# cycle through tabs in the current window
Mod4 Tab :NextTab
Mod4 Shift Tab :PrevTab

# go to a specific tab in the current window
Mod4 1 :Tab 1
Mod4 2 :Tab 2
Mod4 3 :Tab 3
Mod4 4 :Tab 4
Mod4 5 :Tab 5
Mod4 6 :Tab 6
Mod4 7 :Tab 7
Mod4 8 :Tab 8
Mod4 9 :Tab 9

# open a terminal
Mod1 F1 :Exec xterm

# open a dialog to run programs
Mod1 F2 :Exec fbrun

# volume settings, using common keycodes
# if these don't work, use xev to find out your real keycodes
176 :Exec amixer sset Master,0 1+
174 :Exec amixer sset Master,0 1-
160 :Exec amixer sset Master,0 toggle

# current window commands
Mod1 F4 :Close
Mod1 F5 :Kill
Mod1 F9 :Minimize
Mod1 F10 :Maximize
Mod1 F11 :Fullscreen

# open the window menu
Mod1 space :WindowMenu

# exit fluxbox
Control Mod1 Delete :Exit

# change to previous/next workspace
Control Mod1 Left :PrevWorkspace
Control Mod1 Right :NextWorkspace

# send the current window to previous/next workspace
Mod4 Left :SendToPrevWorkspace
Mod4 Right :SendToNextWorkspace

# send the current window and follow it to previous/next workspace
Control Mod4 Left :TakeToPrevWorkspace
Control Mod4 Right :TakeToNextWorkspace

# change to a specific workspace
Control F1 :Workspace 1
Control F2 :Workspace 2
Control F3 :Workspace 3
Control F4 :Workspace 4
Control F5 :Workspace 5
Control F6 :Workspace 6
Control F7 :Workspace 7
Control F8 :Workspace 8
Control F9 :Workspace 9
Control F10 :Workspace 10
Control F11 :Workspace 11
Control F12 :Workspace 12

# send the current window to a specific workspace
Mod4 F1 :SendToWorkspace 1
Mod4 F2 :SendToWorkspace 2
Mod4 F3 :SendToWorkspace 3
Mod4 F4 :SendToWorkspace 4
Mod4 F5 :SendToWorkspace 5
Mod4 F6 :SendToWorkspace 6
Mod4 F7 :SendToWorkspace 7
Mod4 F8 :SendToWorkspace 8
Mod4 F9 :SendToWorkspace 9
Mod4 F10 :SendToWorkspace 10
Mod4 F11 :SendToWorkspace 11
Mod4 F12 :SendToWorkspace 12

# send the current window and change to a specific workspace
Control Mod4 F1 :TakeToWorkspace 1
Control Mod4 F2 :TakeToWorkspace 2
Control Mod4 F3 :TakeToWorkspace 3
Control Mod4 F4 :TakeToWorkspace 4
Control Mod4 F5 :TakeToWorkspace 5
Control Mod4 F6 :TakeToWorkspace 6
Control Mod4 F7 :TakeToWorkspace 7
Control Mod4 F8 :TakeToWorkspace 8
Control Mod4 F9 :TakeToWorkspace 9
Control Mod4 F10 :TakeToWorkspace 10
Control Mod4 F11 :TakeToWorkspace 11
Control Mod4 F12 :TakeToWorkspace 12
```

### 3.11 Example from the manual (1.3.7, verbatim)

```text
# Mod4+drag moves a window
OnWindow Mod4 Mouse1 :StartMoving

# If any xterm windows are open, cycle through them. If none are open, open
# one:
Mod4 t :If {Some Matches (xterm)} {NextWindow (xterm)} {Exec xterm}

# Set a different wallpaper on every workspace:
ChangeWorkspace :Exec fbsetbg ~/.fluxbox/bg$(xprop -root _NET_CURRENT_DESKTOP | awk '{print $3}').png

# Focusses the next window with it's xproperty 'PROP' set to 'foo'
Mod4 p Mod4 Tab :NextWindow (@PROP=foo)
```

## 4. Apps file (`~/.fluxbox/apps`)

Source: [man-apps] (tag), [src-remember] (tag), [src-clientpat] (tag).

### 4.1 Sections

- `[app] (pattern) {count}` ... `[end]`: applies settings to matching windows. `{count}` limits how many windows match.
- `[transient] (pattern)` ... `[end]`: same, for transient dialogs (`WM_TRANSIENT_FOR`).
- `[group] (pattern)` ... `[end]`: auto-tabs the matching `[app]` lines together. The `[group] (pattern)` syntax dates from 1.0rc3 (ChangeLog line 1445). The old `groups` file was deprecated in 1.0.0 and removed in 1.1.0 ([ChangeLog] lines 1218 and 1052).
- `[startup] {command}`: runs once, on first start only. Not run on restart or reconfigure ([src-remember] line 789, tag; [ChangeLog] lines 1584 and 1594).

The manual says the apps file takes effect without a reload ([man-apps] DESCRIPTION).

### 4.2 Client properties (matched in parentheses)

From [src-clientpat] at the tag. Property names are case-insensitive and values are regular expressions (`regex(7)`):

`class`, `name`, `title`, `role`, `transient`, `maximized`, `maximizedhorizontal`, `maximizedvertical`, `minimized`, `fullscreen`, `shaded`, `stuck`, `focushidden`, `iconhidden`, `urgent`, `workspace`, `workspacename`, `layer`, `head`, `screen`.

The client-pattern manual also documents `@XPROP` and the `[current]` and `[mouse]` values ([man-patterns]). The manual's client-pattern text is reproduced in section 4.6.

### 4.3 Settings (1.3.7)

Keys recognised by [src-remember] at the tag: `workspace`, `head`, `layer`, `dimensions`, `position`, `shaded`, `tab`, `focushidden`, `iconhidden`, `hidden`, `deco`, `alpha`, `sticky`, `focusnewwindow`, `minimized`, `maximized`, `fullscreen`, `jump`, `close`.

- `[Workspace] {n}`: workspace index, starting at 0 ([man-apps]).
- `[Jump] {yes|no}`: switch to that workspace when the window opens.
- `[Head] {n}`: Xinerama head.
- `[Layer] {n}`: layer number (2 AboveDock, 4 Dock, 6 Top, 8 Normal, 10 Bottom, 12 Desktop). Named values also work in the code (`getNumFromString`, [src-layer]).
- `[Dimensions] {w h}`: pixels, or `%` of the screen.
- `[Position] (anchor) {x y}`: anchor is one of `TopLeft Left BottomLeft Top Center Bottom TopRight Right BottomRight`. `WINCENTER` is accepted as an alias for `Center` ([src-window] line 3670, tag).
- `[Deco] {value}`: presets `NORMAL NONE BORDER TAB TINY TOOL`, or a bitmask. Bits from 1<<0 to 1<<10 are: titlebar, handle/grips, border, iconify, maximize, close, menu, sticky, shade, external tabs, focus enabled ([man-apps]).
- `[Shaded] {bool}`, `[Tab] {bool}`, `[Sticky] {bool}`, `[Minimized] {bool}`, `[Fullscreen] {bool}`.
- `[Maximized] {yes|horz|vert|no}`.
- `[FocusNewWindow] {bool}`: deprecated in master ([man-apps-master]). Still parsed on 1.3.7.
- `[FocusHidden] {bool}`: left out of NextWindow and PrevWindow.
- `[IconHidden] {bool}`: left out of the iconbar.
- `[Hidden] {bool}`: both of the above.
- `[Alpha] {focused [unfocused]}`: 0-255.
- `[Close] {bool}`: save these settings when the window closes ([man-apps]).

### 4.4 Settings added after 1.3.7

- `[FocusProtection] {value[,value...]}`: `None`, `Gain`, `Refuse`, `Deny`, `Lock`. Added 2016 (commit [`1a61881e`](https://github.com/fluxbox/fluxbox/commit/1a61881e), 2016-06-19). Documented in master ([man-apps-master]).
- `[IgnoreSizeHints] {bool}`: commit [`8d88d9be`](https://github.com/fluxbox/fluxbox/commit/8d88d9be) (2016-08-12).
- `[FocusNewWindow]` is superseded by `[FocusProtection]` Gain and Refuse. Merged in commit [`07d8fbfb`](https://github.com/fluxbox/fluxbox/commit/07d8fbfb) (2016-06-26).

### 4.5 Default apps file (1.3.7, `data/apps.in`, verbatim)

Only the `fbrun` window is pre-configured. Its `WINCENTER` anchor is an alias for `Center` ([src-window] line 3670, tag).

```text
[app] (name=@pkgprefix@fbrun@pkgsuffix@)
  [Position]	(WINCENTER)	{0 0}
  [Layer]	{2}
[end]
```

### 4.6 Example from the manual (1.3.7, verbatim)

```text
# Put the first two windows which end with 'term' on workspace 1
[app] (name=.*[tT]erm) {2}
  [Workspace]   {1}
[end]

# Center kate with a specific size, and update these values when the window is
# closed.
[app] (name=kate)
  [Dimensions]  {1022 747}
  [Position]    (CENTER) {0 0}
  [Close]       {yes}
[end]

# When starting konqueror, jump to workspace 1 first and start it there.
[app] (name=konqueror)
  [Workspace]   {1}
  [Jump]        {yes}
[end]

# start all aterm without decorations
[app] (name=aterm)
  [Deco]        {NONE}
[end]

# a group with the gimp dock and toolbox
# appears on layer 4 (bottom)
[group]
  [app] (name=gimp) (role=gimp-dock)
  [app] (name=gimp) (role=gimp-toolbox)
  [Layer]       {4}
[end]
```

### 4.7 Client patterns (1.3.7, `client-patterns.txt`, verbatim)

Included by the keys and apps manuals ([man-patterns]).

```text
A 'pattern' looks like this:::
    *(*['propertyname'[!]=]'regexp'*)* ...

Match definitions are enclosed in parentheses *(*...*)*, and if no
'propertyname' is given then *Name* is assumed. The 'regexp' can contain any
regular expression, or the special value *[current]*, which matches the
corresponding value of the currently focused window. See 'regex(7)' for more
information on acceptable regular expressions.

'propertyname' is not case sensitive, whereas the 'regexp' is.

If you specify multiple *('pattern'*) arguments, this implies an AND condition -
All specified patterns must match.

You can use *=* to test for equality or *!=* to test for inequality.

The following values are accepted for 'propertyname':::
*Name*;;
    A string, corresponding to the CLASSNAME property (The first field of
    WM_CLASS from the output of the *xprop(1)* utility).
*Class*;;
    A string, corresponding to the CLASSCLASS property (The second field of
    WM_CLASS from the output of the *xprop(1)* utility).
*Title*;;
    A string, corresponding to the window title (WM_NAME from *xprop(1)*).
*Role*;;
    A string, corresponding to the ROLE property (WM_WINDOW_ROLE from 
    *xprop(1)*).
*Transient*;;
    Either *yes* or *no*, depending on whether the window is transient
    (typically, a popup dialog) or not.
*Maximized*;;
    Either *yes* or *no*, depending on whether the window is maximized or
    not.
*MaximizedHorizontal*;;
    Either *yes* or *no*, depending on whether the window is maximized
    horizontally or not.
*MaximizedVertical*;;
    Either *yes* or *no*, depending on whether the window is maximized
    vertically or not.
*Minimized*;;
    Either *yes* or *no*, depending on whether the window is minimized
    (iconified) or not.
*Fullscreen*;;
    Either *yes* or *no*, depending on whether the window is fullscreen or
    not.
*Shaded*;;
    Either *yes* or *no*, depending on whether the window is shaded or
    not.
*Stuck*;;
    Either *yes* or *no*, depending on whether the window is sticky (on
    all workspaces) or not.
*FocusHidden*;;
    Either *yes* or *no*, depending on whether the window has asked to be
    left off the focus list (or, the alt-tab list), or not.
*IconHidden*;;
    Either *yes* or *no*, depending on whether the window has asked to be
    left off the icon list (or, the taskbar), or not.
*Urgent*;;
    Either *yes* or *no*, depending on whether the window has the urgent
    hint set.
*Workspace*;;
    A number corresponding to the workspace number to which the window is
    attached. The first workspace here is *0*. You may also use *[current]* to
    match the currently visible workspace.
*WorkspaceName*;;
    A string corresponding to the name of the workspace to which the
    window is attached.
*Head*;;
    The number of the display head to which the window is attached. You
    may match this against the special value *[mouse]* which refers to the
    head where the mouse pointer currently resides.
*Layer*;;
    The string name of the window's layer, which is one of
    *AboveDock*, *Dock*, *Top*, *Normal*, *Bottom*, *Desktop*
*Screen*;;
    The number of the currently used 'screen'. If the setup of the
    running xserver involves independent screens ('not Xinerama'), the $DISPLAY
    environment contains something like ':0.1' or ':1.0'. The part after the
    dot ('.') is the number of the screen.
*@XPROP*;;
    A string, corresponding to any xproperty (Use either the *xprop(1)*
    utility or the 'SetXProp' command to set a xproperty to a window)

.Matches any windows with the CLASSNAME of "xterm"
..........
(xterm)
..........

.Matches any windows with the same CLASSNAME as the currently focused window
..........
(Name=[current])
..........

.Matches any windows on the same head as the mouse but on a different layer than the currently focused window
...........
(Head=[mouse]) (Layer!=[current])
...........

.Matches any windows having a xproperty named FOO with "bar" in it
..............
(@FOO=.*bar.*)
..............
```

## 5. Menus

Source: [man-menu] (tag), [src-menucreator] (tag), util/fluxbox-generate_menu.in ([gen]).

### 5.1 Root menu syntax

Each line has up to four fields:

```
['tag'] ('label') {'command'} <'icon'>
```

- The file starts with `[begin] (title)` and ends with `[end]`. Every tag is on its own line.
- Comments start with `#` or `!`.
- Icons must be `.xpm` or `.png`. They are scaled down to fit ([man-menu] ROOT MENU).
- `\\` escapes a backslash in labels, commands and filenames.
- `[encoding] {name}` ... `[endencoding]` sets the encoding for a block. Names come from `iconv -l`.

Structural and command tags, from [src-menucreator] at the tag and [man-menu]:

- `[submenu] (label) {title} <icon>` ... `[end]`.
- `[include] (path)`: a file or a directory of files, inlined.
- `[separator]`, `[nop] (label)`.
- `[exec] (label) {command} <icon>`: run through `$SHELL` or `/bin/sh`.
- `[config] (label)`: the Configuration submenu.
- `[reconfig] (label)`, `[restart] (label) {cmd}`, `[exit] (label)`.
- `[style] (label) {file}`: apply one style file.
- `[stylesmenu] (dir)`: one item per style file in the directory.
- `[stylesdir] (label) {dir}`: as stylesmenu, in a submenu.
- `[themesdir]`, `[themesmenu]`: in source but not in the 1.3.7 manual.
- `[wallpapers] (dir) {cmd}`: one item per image. Default command `fbsetbg`.
- `[wallpapermenu]`, `[rootcommands]`: aliases of wallpapers in source, not in the manual.
- `[workspaces] (label)`: links to the Workspace menu.
- `[icons] (label)`: an iconmenu submenu of iconified windows. In source, not in the manual.
- Any keys-file command can be used as a tag. For example `[commanddialog] (Fluxbox Command)` is used by the generator ([gen], Fluxbox submenu).

### 5.2 Window menu tags (1.3.7, [man-menu] WINDOW MENU)

`[shade]`, `[stick]`, `[maximize]`, `[iconify]`, `[close]`, `[kill]`, `[raise]`, `[lower]`, `[settitledialog]`, `[sendto]`, `[layer]`, `[alpha]`, `[extramenus]`, `[separator]`.

### 5.3 Default window menu (1.3.7, `data/windowmenu`, verbatim)

```text
[begin]
  [shade]
  [stick]
  [maximize]
  [iconify]
  [raise]
  [lower]
  [settitledialog]
  [sendto]
  [layer]
  [alpha]
  [extramenus]
  [separator]
  [close]
[end]
```

### 5.4 Example root menu from the manual (1.3.7, verbatim)

```text
# fluxbox menu file
[begin] (fluxbox)
    [exec] (rxvt) {rxvt -ls} </usr/X11R6/share/icons/terminal.xpm>
    [exec] (netscape) {netscape -install}
    [exec] (The GIMP) {gimp}
    [exec] (XV) {xv}
    [exec] (Vim) {rxvt -geometry 132x60 -name VIM -e screen vim}
    [exec] (Mutt) {rxvt -name mutt -e mutt}
    [submenu] (mozilla)
        [exec] (browser) {mozilla -browser}
        [exec] (news) {mozilla -news}
        [exec] (mail) {mozilla -mail}
        [exec] (edit) {mozilla -edit}
        [exec] (compose) {mozilla -compose}
    [end]
    [submenu] (Window Manager)
        [exec] (Edit Menus) {nedit ~/.fluxbox/menu}
        [submenu] (Style) {Which Style?}
            [stylesdir] (~/.fluxbox/styles)
            [stylesmenu] (fluxbox Styles) {@pkgdatadir@/styles}
        [end]
        [config] (Config Options)
        [reconfig] (Reconfigure)
        [restart] (Restart)
    [end]
    [exit] (Log Out)
[end]
```

### 5.5 Default root menu

No static root menu is shipped. `data/menu` is generated at build time, by `sh util/fluxbox-generate_menu` with `MENUTITLE=Fluxbox-1.3.7` and `INSTALL=Yes` ([data-makemodule]). The Fluxbox submenu section of the generator (lines 1826-1911 at the tag) is reproduced below. It is where the Configure, System Styles, User Styles, Workspace List, Tools, Window Managers, Fluxbox Command, Reload config, Restart and Exit items come from.

Generator defaults (lines 581-614 of [gen], tag): `CONFIGUREMENU='Configure'`, `FBSETTINGSMENU='Fluxbox menu'`, `SYSTEMSTYLES='System Styles'`, `USERSTYLES='User Styles'`, `WORKSPACEMENU='Workspace List'`, `TOOLS='Tools'`, `WINDOWMANAGERS='Window Managers'`, `FLUXBOXCOMMAND='Fluxbox Command'`, `RELOADITEM='Reload config'`, `RESTARTITEM='Restart'`, `EXITITEM='Exit'`.

```sh
append_submenu "${FBSETTINGSMENU}"
    append "[config] (${CONFIGUREMENU})"

    append_menu "[submenu] (${SYSTEMSTYLES}) {${STYLEMENUTITLE}}"
        append "[stylesdir] (${PREFIX}/share/fluxbox/styles)"
    append_menu_end

    append_menu "[submenu] (${USERSTYLES}) {${STYLEMENUTITLE}}"
        append "[stylesdir] (~/.@pkgprefix@fluxbox@pkgsuffix@/styles)"
    append_menu_end

    # Backgroundmenu
    addbackground() {
                picturename=`basename "$1"`
                append "[exec] (${picturename%.???}) {@pkgprefix@fbsetbg@pkgsuffix@ -a \"$1\" }"
    }

    if [ "$BACKGROUNDMENUITEM" = yes ]; then
        IFS=: # set delimetor for find
        NUMBER_OF_BACKGROUNDS=`find $BACKGROUND_DIRS -follow -type f 2> /dev/null|wc -l`
        if [ "$NUMBER_OF_BACKGROUNDS" -gt 0 ]; then
            append_menu "[submenu] (${BACKGROUNDMENU}) {${BACKGROUNDMENUTITLE}}"
            append "[exec] (${RANDOMBACKGROUND}) {@pkgprefix@fbsetbg@pkgsuffix@ -r ${USERFLUXDIR}/backgrounds}"
            if [ "$NUMBER_OF_BACKGROUNDS" -gt 30 ]; then
                menucounter=1 ; counter=1
                append_menu "[submenu] (${BACKGROUNDMENU} $menucounter) {${BACKGROUNDMENUTITLE}}"
                find $BACKGROUND_DIRS -follow -type f|sort|while read i; do
                    counter=`expr $counter + 1`
                    if [ $counter -eq 30 ]; then
                        counter=1
                        menucounter=`expr $menucounter + 1`
                        append_menu_end
                        append_menu "[submenu] (${BACKGROUNDMENU} $menucounter) {${BACKGROUNDMENUTITLE}}"
                    fi
                    addbackground "$i"
                done
                append_menu_end
            else
                find $BACKGROUND_DIRS -follow -type f|sort|while read i; do
                addbackground "$i"
                done
            fi
            append_menu_end
        else
            echo "Warning: You wanted a background-menu but I couldn't find any backgrounds in:
    $BACKGROUND_DIRS" >&2
        fi
    fi

    append "[workspaces] (${WORKSPACEMENU})"

    append_submenu "${TOOLS}"
        normal_find fluxconf fluxkeys fluxmenu
        find_it fbpanel append "[exec] (Fluxbox panel) {fbpanel}"
        find_it $XMESSAGE append \
            "[exec] (${WINDOWNAME}) {xprop WM_CLASS|cut -d \\\" -f 2|$XMESSAGE -file - -center}"
        find_it import append "[exec] (${SCREENSHOT} - JPG) {import screenshot.jpg && display -resize 50% screenshot.jpg}"
        find_it import append "[exec] (${SCREENSHOT} - PNG) {import screenshot.png && display -resize 50% screenshot.png}"
        find_it ${LAUNCHER} append "[exec] (${RUNCOMMAND}) {$LAUNCHER_CMD}"
        find_it switch append "[exec] (gtk-theme-switch) {switch}"
        find_it switch2 append "[exec] (gtk2-theme-switch) {switch2}"
        find_it @pkgprefix@fluxbox-generate_menu@pkgsuffix@ append "[exec] (${REGENERATEMENU}) {$FBGM_CMD}"
    append_menu_end

    append_submenu "${WINDOWMANAGERS}"
    #hard to properly maintain since there are so many exceptions to the rule.
    for wm in mwm twm wmii beryl compiz metacity icewm ion kde sawfish enlightenment fvwm openbox evilwm waimea xfce pekwm xfce4 fvwm2 blackbox ; do
        find_it start${wm} append "[restart] (${wm}) {start${wm}}" ||\
            find_it ${wm} append "[restart] (${wm}) {${wm}}"
    done
        find_it startgnome append "[restart] (gnome) {startgnome}" ||\
            find_it gnome-session append "[restart] (gnome) {gnome-session}"

        find_it startwindowmaker append "[restart] (windowmaker) {startwindowmaker}" ||\
            find_it wmaker append "[restart] (windowmaker) {wmaker}"
    append_menu_end
    find_it xlock append "[exec] (${LOCKSCREEN}) {xlock}" ||\
        find_it xscreensaver-command append "[exec] (${LOCKSCREEN}) {xscreensaver-command -lock}"
    append "[commanddialog] (${FLUXBOXCOMMAND})"
    append "[reconfig] (${RELOADITEM})"
    append "[restart] (${RESTARTITEM})"
    append "[exec] (${ABOUTITEM}) {(@pkgprefix@fluxbox@pkgsuffix@@EXEEXT@ -v; @pkgprefix@fluxbox@pkgsuffix@@EXEEXT@ -info | sed 1d) | $XMESSAGE -file - -center}"
    append "[separator]"
    append "[exit] (${EXITITEM})"

    append_menu_end
```

If the resulting file yields no items, the fallback in [src-screen] lines 1276-1285 gives a menu titled "Fluxbox default menu" with `xterm`, `Restart` and `Exit`.

### 5.6 Generators

- `fluxbox-generate_menu`: shell script shipped in `util/` ([gen]). It scans `.desktop` files and writes `~/.fluxbox/menu`. Settings come from `~/.fluxbox/menuconfig`. The Fluxbox submenu in section 5.5 is appended by the script.
- `menumaker`: external. `mmaker -f FluxBox` writes a full XML-derived menu. Options `--no-legacy` and `--no-debian` filter entries ([arch]).
- `xdg-menu`: external, not in this repo. Arch wiki refers to it ([arch]).

## 6. Styles

Source: [man-style] (tag), [src-texture], [src-themeitems], [src-rootTheme] (all tag).

### 6.1 Location and layout

- User styles: `~/.fluxbox/styles/<name>/`. System styles: `$prefix/share/fluxbox/styles/`.
- A style is a directory with `theme.cfg` (or `style.cfg`) and optionally `pixmaps/` ([man-style] LOCATION).
- Selection: `session.styleFile` in init, or the Styles submenus in the root menu.
- Overlay: `session.styleOverlay` (default `~/.fluxbox/overlay`) overrides any style ([man-fb] STYLES; the wiki's Style overlay page says "Since Fluxbox 0.9.15" ([wiki-overlay])).

### 6.2 Syntax

- Each line is `component: value`. Comments start with `!`.
- A wildcard may stand for a family of keys. `*font: sans-8` sets every font. Specific keys override it: `toolbar.clock.textColor: rgb:255/0/0` ([man-style] CREATING YOUR STYLE).
- Colours: `#rrggbb` or `rgb:r/g/b` ([man-style] COLOR FORMATS).

### 6.3 Textures

A texture is up to five words in any order, set on the component itself (for example `toolbar.clock: Raised Gradient Diagonal Bevel1`):

- Relief: `Flat`, `Raised`, `Sunken`.
- Fill: `Solid` or `Gradient`. `ParentRelative` makes the component transparent. `Pixmap` uses the `.pixmap` resource.
- Gradient type: `Horizontal`, `Vertical`, `Diagonal`, `CrossDiagonal`, `Pipecross`, `Elliptic`, `Rectangle`, `Pyramid`. Matched as substrings in [src-texture] lines 65-79 (tag).
- `Interlaced`: darkens every other line ([src-texture] line 107).
- `Bevel1` (default, shading on the edge) or `Bevel2` (shading one pixel in). Parsed at [src-texture] line 98.

Gradients use `.color` and `.colorTo`. `Interlaced` in Solid mode uses `colorTo` as the interlace colour ([man-style]).

### 6.4 Fonts and effects

- A name that does not start with `-` is an Xft pattern, for example `sans-8:bold`. A name that starts with `-` is an X core font ([man-style] FONT EFFECTS; [man-fb] `*font:`).
- Effects are set per component ([src-themeitems] lines 155-172 at the tag):
  - `<item>.effect: shadow` with `<item>.shadow.color`, `<item>.shadow.x`, `<item>.shadow.y`.
  - `<item>.effect: halo` with `<item>.halo.color`.
- Example from the manual: `menu.title.font: sans-8:bold`, `menu.title.effect: shadow`, `menu.title.shadow.color: green`, `menu.title.shadow.x: 3`.

### 6.5 Background

`background:` takes `centered`, `aspect`, `tiled`, `fullscreen`, `random`, `solid`, `gradient`, `mod`, `none` or `unset` ([src-rootTheme] lines 206-247, tag; [man-style] BACKGROUND).

- `centered|aspect|tiled|fullscreen` need `background.pixmap`. `random` needs a directory. fluxbox calls `fbsetbg`.
- `solid`, `gradient`, `mod` need `background.color` ([man-style] BACKGROUND). `gradient` and `mod` also need `background.colorTo`. `mod` needs `background.modX` and `background.modY`. fluxbox calls `fbsetroot`.
- `none`: do not change the background. `unset`: overlay-only, never run fbsetbg.

### 6.6 Component reference (1.3.7 manual, verbatim)

This is the manual's complete component list at the tag ([man-style] FULL COMPONENT LIST). Use it as the definitive key list for 1.3.7.

```text
Here is the exhaustive component list for fluxbox(1) styles. Each one is listed
with their type of value required. Comments in a style file are preceded
with an exclamation point (!) which we also use here so that these can be
pasted into a new theme.cfg to be customized appropriately. Please note that
in order to keep styles consistent it is  often the practice of stylists
to provide all of the theme-items in their style file even if they are not
used. This allows the user the ease of changing different components.

WINDOW OPTIONS
--------------
Many, many things you can do with window design in fluxbox(1), below are your
options. Have fun.

   -----------------------------------------
   window.bevelWidth:              <integer>
   window.borderColor:             <color>
   window.borderWidth:             <integer>
   window.button.focus:            <texture type>
   window.button.focus.color:      <color>
   window.button.focus.colorTo:    <color>
   window.button.focus.picColor:   <color>
   window.button.focus.pixmap:     <filename>
   window.button.pressed: <texture type>
   window.button.pressed.color:    <color>
   window.button.pressed.colorTo:  <color>
   window.button.pressed.pixmap:   <filename>
   window.button.unfocus:          <texture type>
   window.button.unfocus.color:    <color>
   window.button.unfocus.colorTo:  <color>
   window.button.unfocus.picColor: <color>
   window.button.unfocus.pixmap:   <filename>
   window.close.pixmap:            <filename>
   window.close.pressed.pixmap:    <filename>
   window.close.unfocus.pixmap:    <filename>
   window.font:                    <font>
   window.frame.focusColor:        <color>
   window.frame.unfocusColor:      <color>
   window.grip.focus:              <texture type>
   window.grip.focus.color:        <color>
   window.grip.focus.colorTo:      <color>
   window.grip.focus.pixmap:       <filename>
   window.grip.unfocus:            <texture type>
   window.grip.unfocus.color:      <color>
   window.grip.unfocus.colorTo:    <color>
   window.grip.unfocus.pixmap:     <filename>
   window.handle.focus:            <texture type>
   window.handle.focus.color:      <color>
   window.handle.focus.colorTo:    <color>
   window.handle.focus.pixmap:     <filename>
   window.handle.unfocus:          <texture type>
   window.handle.unfocus.color:    <color>
   window.handle.unfocus.colorTo:  <color>
   window.handle.unfocus.pixmap:   <filename>
   window.handleWidth:             <integer>
   window.iconify.pixmap:          <filename>
   window.iconify.pressed.pixmap:  <filename>
   window.iconify.unfocus.pixmap:  <filename>
   window.justify:                 <{Left|Right|Center}>
   window.label.active:            <texture type>
   window.label.active.textColor:  <color>
   window.label.focus:             <texture type>
   window.label.focus.color:       <color>
   window.label.focus.colorTo:     <color>
   window.label.focus.pixmap:      <filename>
   window.label.unfocus:           <texture type>
   window.label.unfocus.color:     <color>
   window.label.unfocus.colorTo:   <color>
   window.label.unfocus.pixmap:    <filename>
   window.label.focus.textColor:   <color>
   window.label.unfocus.textColor: <color>
   window.maximize.pixmap:         <filename>
   window.maximize.pressed.pixmap: <filename>
   window.maximize.unfocus.pixmap: <filename>
   window.roundCorners:            <{Top|Bottom}{Left|Right}>
   window.shade.pixmap:            <filename>
   window.shade.pressed.pixmap:    <filename>
   window.shade.unfocus.pixmap:    <filename>
   window.stick.pixmap:            <filename>
   window.stick.pressed.pixmap:    <filename>
   window.stick.unfocus.pixmap:    <filename>
   window.stuck.pixmap:            <filename>
   window.stuck.unfocus.pixmap:    <filename>
   window.lhalf.pixmap:            <filename>
   window.lhalf.unfocus.pixmap:    <filename>
   window.rhalf.pixmap:            <filename>
   window.rhalf.unfocus.pixmap:    <filename>
   window.title.focus:             <texture type>
   window.title.focus.color:       <color>
   window.title.focus.colorTo:     <color>
   window.title.focus.pixmap:      <filename>
   window.title.height:            <integer>
   window.title.unfocus:           <texture type>
   window.title.unfocus.color:     <color>
   window.title.unfocus.colorTo:   <color>
   window.title.unfocus.pixmap:    <filename>
   -----------------------------------------

MENU OPTIONS
------------
Everything you need to make your menu look pretty.

   -----------------------------------------
   menu.bevelWidth:                <integer>
   menu.borderColor:               <color>
   menu.borderWidth:               <integer>
   menu.bullet:                    <{empty|square|triangle|diamond}>
   menu.bullet.position:           <{left|right}>
   menu.frame:                     <texture type>
   menu.frame.color:               <color>
   menu.frame.colorTo:             <color>
   menu.frame.disableColor:        <color>
   menu.frame.font:                <font>
   menu.frame.justify:             <{Left|Right|Center}>
   menu.frame.pixmap:              <filename>
   menu.frame.textColor:           <color>
   menu.hilite:                    <texture type>
   menu.hilite.color:              <color>
   menu.hilite.colorTo:            <color>
   menu.hilite.font:               <font>
   menu.hilite.justify:            <{left|center|right}>
   menu.hilite.pixmap:             <filename>
   menu.hilite.textColor:          <color>
   menu.itemHeight:                <integer>
   menu.title:                     <texture type>
   menu.title.color:               <color>
   menu.title.colorTo:             <color>
   menu.title.font:                <font>
   menu.title.pixmap:              <filename>
   menu.title.textColor:           <color>
   menu.title.justify:             <{Left|Right|Center}>
   menu.titleHeight:               <integer>
   menu.roundCorners:              <{Top|Bottom}{Left|Right}>
   menu.selected.pixmap:           <filename>
   menu.submenu.pixmap:            <filename>
   menu.unselected.pixmap:         <filename>
   -----------------------------------------

BACKGROUND
------------
Every style must specify the background option. If you don't want your style to
change the user's background, then use `background: none'. The options
`centered', `aspect', `tiled', and `fullscreen' require the `background.pixmap'
resource to contain a valid file name. The `random' option requires
`background.pixmap' to contain a valid directory name. For these options,
*fluxbox(1)* will call *fbsetbg(1)* to set the background. The options `gradient',
`solid', and `mod' all require `background.color' to be set. `gradient' and
`mod' both require `background.colorTo'. `mod' requires `background.modX' and
`background.modY' to be set as well. These options will be passed to
*fbsetroot(1)* to set the background. The special option `unset' is for use in
user overlay files only. It specifies that fbsetbg should never be run (by
default, even when `none' is set in the overlay, fluxbox will try to run
``fbsetbg -z'' to restore the last wallpaper).

   background: centered|aspect|tiled|fullscreen|random|solid|gradient <texture>|mod|none|unset
   background.pixmap: <file or directory>
   background.color: <color>
   background.colorTo: <color>
   background.modX: <integer>
   background.modY: <integer>

SLIT
----
Here are all of the options for the slit.

   -----------------------------------------
   slit: <texture type>
   slit.bevelWidth: <integer>
   slit.borderColor: <color>
   slit.borderWidth:               <integer>
   slit.color:                     <color>
   slit.colorTo:                   <color>
   slit.pixmap:                    <filename>
   -----------------------------------------

TOOLBAR OPTIONS
---------------
Below you will find all of the configuration possibilities for the toolbar.
The list is pretty extensive and offers you many options to make your toolbar
look just the way you want it.

   -----------------------------------------
   toolbar: <texture type>
   toolbar.bevelWidth:             <integer (0-255)>
   toolbar.borderColor:            <color>
   toolbar.borderWidth:            <integer>
   toolbar.button.scale:           <integer>
   toolbar.color:                  <color>
   toolbar.colorTo:                <color>
   toolbar.clock:                  <texture type>
   toolbar.clock.borderColor:      <color>
   toolbar.clock.borderWidth:      <integer>
   toolbar.clock.font:             <font>
   toolbar.clock.justify:          <{Left|Right|Center}>
   toolbar.clock.pixmap:           <filename>
   toolbar.clock.color:            <color>
   toolbar.clock.colorTo:          <color>
   toolbar.clock.textColor:        <color>
   toolbar.height:                 <integer>
   toolbar.iconbar.focused:        <texture type>
   toolbar.iconbar.focused.color:  <color>
   toolbar.iconbar.focused.colorTo:<color>
   toolbar.iconbar.focused.pixmap: <filename>
   toolbar.iconbar.unfocused:      <texture type>
   toolbar.iconbar.unfocused.color:  <color>
   toolbar.iconbar.unfocused.colorTo: <color>
   toolbar.iconbar.unfocused.pixmap: <filename>
   toolbar.iconbar.empty:          <texture type>
   toolbar.iconbar.empty.color:    <color>
   toolbar.iconbar.empty.colorTo:  <color>
   toolbar.iconbar.empty.pixmap:   <filename>
   toolbar.iconbar.focused.borderColor: <color>
   toolbar.iconbar.focused.borderWidth:    <integer>
   toolbar.iconbar.unfocused.borderColor: <color>
   toolbar.iconbar.unfocused.borderWidth:  <integer>
   toolbar.iconbar.borderColor:    <color>
   toolbar.iconbar.borderWidth:    <integer>
   toolbar.iconbar.focused.font:   <font>
   toolbar.iconbar.focused.justify:        <{Left|Right|Center}>
   toolbar.iconbar.focused.textColor: <color>
   toolbar.iconbar.unfocused.font: <font>
   toolbar.iconbar.unfocused.justify:      <{Left|Right|Center}>
   toolbar.iconbar.unfocused.textColor: <color>
   toolbar.pixmap:                 <filename>
   toolbar.shaped:                 <boolean>
   toolbar.workspace.font:         <font>
   toolbar.workspace.justify:      <{Left|Right|Center}>
   toolbar.workspace.textColor:    <color>
   toolbar.workspace:              <texture type>
   toolbar.workspace.borderColor:  <color>
   toolbar.workspace.borderWidth:  <integer>
   toolbar.workspace.color:        <color>
   toolbar.workspace.colorTo:      <color>
   toolbar.workspace.pixmap:       <filename>
   -----------------------------------------
```

### 6.7 Gaps between the style manual and the code (1.3.7)

- `window.tab.*`: documented, not read (Surprise 3).
- `toolbar.button.scale`: documented, not read. The code reads `toolbar.button.size` (Surprise 4).
- `window.font` is read at 1.3.7. The master manual renames it to `window.label.focus.font` and `window.label.unfocus.font`. That rename is in master only.
- Items composed from prefixes (for example `window.<item>.focus.color`) do not appear literally in source. A grep for the full key misses them. Check the `FbWinFrameTheme`, `ToolbarTheme` and `IconbarTheme` constructors instead.

### 6.8 Example style (1.3.7, `data/styles/Emerge/theme.cfg`, verbatim)

The style header credits ikaro (FluxMOD, 2003) and has no separate licence line. The fluxbox repo distributes it under the project's MIT licence.

```text
!---------------------------------------------------------------------------------
! FluxMOD www.imaginere.dk
! Style name: Emerge
! Style Author: ikaro ( ikaro@bersirc.com )
! Style Date: Sun Sep 14 08:25:12 CEST 2003
! Style info: Simple desktop, clean and stylish.
! Style Comments: Thank you Henrik for making Fluxbox.
!
!----------------------------------------------------------------------------------

!menu:
menu.title: Raised Bevel1 Gradient Vertical
menu.title.textColor: #000000
!menu.title.pixmap:
menu.title.color: #ebebeb
menu.title.colorTo: #ffffff
!menu.title.font:
menu.title.justify: Center


!menu.frame.pixmap:
menu.frame: Raised Bevel1 Gradient CrossDiagonal
menu.frame.color: #ffffff
menu.frame.colorTo: #ebebeb
menu.frame.textColor:	#000000
menu.frame.disableColor:
!menu.frame.font:
menu.frame.justify: Left
menu.bullet.position: Left
menu.bullet: Square
menu.bevelWidth: 2
menu.borderwidth: 1
menu.borderColor: #000000


menu.hilite: Raised Bevel2 Gradient Vertical
menu.hilite.textColor: #000000
!menu.hilite.pixmap:
menu.hilite.color: #ebebeb
menu.hilite.colorTo: #ffffff

menu.submenu.pixmap: bullet.xpm
menu.selected.pixmap: selected.xpm
menu.unselected.pixmap: unselected.xpm
!menu.roundCorners:

!window.font:
window.justify: Center
!window.roundCorners:
window.alpha: 255
window.title.height:
window.bevelWidth: 2
window.borderWidth: 1
window.handleWidth: 4
window.borderColor: #525050

window.close.pixmap: close.xpm
window.maximize.pixmap: max.xpm
window.iconify.pixmap: icon.xpm
window.stick.pixmap: stick.xpm

window.close.pressed.pixmap: close-pressed.xpm
window.maximize.pressed.pixmap: max-pressed.xpm
window.iconify.pressed.pixmap: icon-pressed.xpm
window.stick.pressed.pixmap: stick-pressed.xpm

window.close.unfocus.pixmap: close-unfocus.xpm
window.maximize.unfocus.pixmap: max-unfocus.xpm
window.iconify.unfocus.pixmap: icon-unfocus.xpm
window.stick.unfocus.pixmap: stick-unfocus.xpm

window.stuck.pixmap:	 stuck.xpm
window.stuck.unfocus.pixmap: stuck-unfocus.xpm

!window.shade.pixmap:
!window.shade.pressed.pixmap:
!window.shade.unfocus.pixmap:

window.grip.focus: Raised Bevel1 Gradient Vertical
!window.grip.focus.pixmap: 
window.grip.focus.color: #ebebeb
window.grip.focus.colorTo: #ffffff

window.grip.unfocus: Raised Bevel1 Gradient Vertical
!window.grip.unfocus.pixmap:            
window.grip.unfocus.color: #cfcfcf
window.grip.unfocus.colorTo: #cfcfcf

window.handle.focus: Raised Bevel1 Gradient Vertical
!window.handle.focus.pixmap:
window.handle.focus.color:	#ebebeb
window.handle.focus.colorTo: #ffffff

window.handle.unfocus: Raised Bevel1 Gradient Vertical
!window.handle.unfocus.pixmap:
window.handle.unfocus.color: #cfcfcf
window.handle.unfocus.colorTo: #cfcfcf

window.label.focus: Raised Bevel1 Gradient Vertical
!window.label.focus.pixmap:
window.label.focus.color: #ebebeb
window.label.focus.colorTo: #ffffff
window.label.focus.textColor: #000000
!window.label.focus.font:
window.label.focus.justify: Center

window.justify:	Center
window.label.unfocus: Raised Bevel1 Gradient Vertical
!window.label.unfocus.pixmap:
window.label.unfocus.color:	#e3e3e3
window.label.unfocus.colorTo: #e3e3e3
window.label.unfocus.textColor:	#747171

window.title.focus: Flat
!window.title.focus.pixmap:
window.title.focus.color: #ebebeb
window.title.focus.colorTo:

window.title.unfocus: Flat
!window.title.unfocus.pixmap:
window.title.unfocus.color: #ebebeb
window.title.unfocus.colorTo:
window.frame.focusColor:	#525050
window.frame.unfocusColor: #525050


*.font: sans-8

slit: Raised Bevel2 Gradient Horizontal
!slit.pixmap:
slit.color: #ebebeb
slit.colorTo: #ffffff
slit.borderWidth: 1
slit.bevelWidth: 1
slit.borderColor: #ffffff

toolbar: Flat
!toolbar.pixmap:
toolbar.color: #ebebeb
toolbar.colorTo:
toolbar.borderWidth: 1
toolbar.borderColor: #525050
toolbar.bevelWidth: 2
toolbar.shaped: True
toolbar.alpha: 255
toolbar.height: 17

toolbar.clock: Raised Bevel1 Gradient Vertical
!toolbar.clock.pixmap: 
toolbar.clock.color: #ebebeb
toolbar.clock.colorTo: #cfcfcf
!toolbar.clock.font:
toolbar.clock.textColor: #000000
toolbar.clock.borderWidth: 0
toolbar.clock.borderColor:
toolbar.clock.justify: Center

toolbar.workspace: Raised Bevel1 Gradient Vertical
!toolbar.workspace.pixmap: 
toolbar.workspace.color: #ebebeb
toolbar.workspace.colorTo: #cfcfcf
toolbar.workspace.borderWidth: 0
toolbar.workspace.borderColor:
!toolbar.workspace.font:
toolbar.workspace.textColor: #000000
toolbar.workspace.justify: Center

toolbar.iconbar.focused: Raised Bevel1 Gradient Vertical
!toolbar.iconbar.focused.pixmap: 
toolbar.iconbar.focused.color: #ebebeb
toolbar.iconbar.focused.colorTo: #dbdbdb
toolbar.iconbar.focused.borderWidth: 1
toolbar.iconbar.focused.borderColor: #5e5b5b
!toolbar.iconbar.focused.font:
toolbar.iconbar.focused.textColor: #000000
toolbar.iconbar.focused.justify: Center

toolbar.iconbar.unfocused: Raised Bevel1 Gradient Vertical
!toolbar.iconbar.unfocused.pixmap:
toolbar.iconbar.unfocused.color: #ebebeb
toolbar.iconbar.unfocused.colorTo: #cfcfcf
toolbar.iconbar.unfocused.borderWidth: 0
toolbar.iconbar.unfocused.borderColor:
!toolbar.iconbar.unfocused.font:
toolbar.iconbar.unfocused.textColor: #747171
toolbar.iconbar.unfocused.justify: Center

toolbar.iconbar.empty: Raised Bevel1 Gradient Vertical
!toolbar.iconbar.empty.pixmap: 
toolbar.iconbar.empty.color:#ebebeb
toolbar.iconbar.empty.colorTo: #cfcfcf

toolbar.iconbar.borderWidth: 1
toolbar.iconbar.borderColor: #dbdbdb

! need this here, even though there is no background in the style
background: none
```

### 6.9 Other shipped styles (1.3.7)

`data/styles/` at the tag contains: `BlueFlux`, `Emerge`, `arch`, `bloe`, `bora_black`, `bora_blue`, `bora_green`, `carp`, `green_tea`, `ostrich`, `zimek_bisque`, `zimek_darkblue`, `zimek_green`.

## 7. Window behaviour and helper tools

### 7.1 Focus model

- `session.screenN.focusModel` (1.3.7): `ClickToFocus` (default), `MouseFocus`, `StrictMouseFocus`. `StrictMouseFocus` also focuses a window that moves under a still pointer ([man-fb] FOCUS MODEL).
- `session.screenN.tabFocusModel`: `ClickToTabFocus` (default), `SloppyTabFocus` ([src-focus] tag).
- `session.screenN.focusNewWindows`: true.
- `session.screenN.autoRaise`, `session.autoRaiseDelay`, `session.screenN.clickRaises`: see section 2.3.

### 7.2 Raise, lower and layers

- Left-click a border raises. Middle-click on a border or titlebar lowers. Right-click on a titlebar opens the Window menu ([man-fb] USING FLUXBOX).
- Layers (13 numbered slots, [man-fb] LAYERS; enum in [src-layer] lines 36-43 at the tag):

| Name | Number |
|---|---|
| Menu | 0 |
| AboveDock | 2 |
| Dock | 4 |
| Top | 6 |
| Normal | 8 |
| Bottom | 10 |
| Desktop | 12 |

- Windows: apps `[Layer]`, Window menu `Layer...`, keys `SetLayer`, `RaiseLayer`, `LowerLayer`.
- Toolbar and slit: `session.screenN.toolbar.layer` and `slit.layer`, default `Dock`.
- Above-dock toggles: `ToggleToolbarAbove` and `ToggleSlitAbove` (registered as `toggleslitbarabove`) are **[post-1.3.7]** (see 3.9).

### 7.3 Tabs and grouping

- Middle-click and drag a window's tab onto another window to group them. In the default keys, Control-drag a titlebar also starts tabbing: `OnTitlebar Control Mouse1 :StartTabbing` ([keys data] file, section 3.10).
- `session.tabsAttachArea`: `Window` lets you drop anywhere on the target window. `Titlebar` requires dropping on its titlebar ([man-fb] session.tabsAttachArea; [wiki-tabs]).
- `session.screenN.tabs.intitlebar` embeds tabs in the titlebar. `tab.placement`, `tab.width`, `tabs.maxOver` control external tabs ([man-fb] TAB OPTIONS).
- Keys for tabs: `NextTab`, `PrevTab`, `Tab N`, `MoveTabLeft`, `MoveTabRight`, `DetachClient`, `ActivateTab` (keys manual, section 3.7).
- Auto-grouping in the apps file uses `[group]` ([man-apps] GROUP SECTIONS).
- Two Mod4 bindings in the default keys cycle tabs: `Mod4 Tab :NextTab`, and `Mod4 1..9 :Tab N`.
- `AutotabPlacement` (new windows tab with the focused one) is **[post-1.3.7]** (commit [`ea466fa9`](https://github.com/fluxbox/fluxbox/commit/ea466fa9), 2016-09-11).
- Dragging a tab to another workspace: **[post-1.3.7]** (commit [`bc1ad61a`](https://github.com/fluxbox/fluxbox/commit/bc1ad61a), 2016-09-13).

### 7.4 Window menu contents (default)

From `data/windowmenu` (section 5.3): Shade, Stick, Maximize, Iconify, Raise, Lower, Set title, Send to, Layer, Transparency, extra menus (Remember), separator, Close.

Maximize buttons: button 1 maximize, button 2 vertical only, button 3 horizontal only ([man-menu] WINDOW MENU).

### 7.5 Slit and dockapps

- The slit holds dockable applications. Run them with `-w` so they dock ([man-fb] THE SLIT).
- Dockapp detection: a window whose `WM_CLASS` class is `DockApp` is put in the slit ([src-screen] lines 1083 and 1150, tag). Added in 1.3.6 ([ChangeLog] line 80).
- KDE system-tray dockapps: detected by `isKdeDockapp` and `addKdeDockapp` ([src-screen] lines 1005-1039, tag). Controlled by `slit.acceptKdeDockapps` (default true).
- WindowMaker dockapp protocol: the slit uses the `DockApp` class convention. Master changed unmap handling to set `WithdrawnState` (commit [`c7ff3696`](https://github.com/fluxbox/fluxbox/commit/c7ff3696), 2025-06-19), which bears on the withdrawn-window docking convention.
- Slit ordering: `slitlist` file, or "Save SlitList" in the Slit menu ([man-fb] Slitlist File).
- Slit menu options: placement, layer, auto hide, auto raise (master only), maximize over, alpha, clients list ([man-fb] Slit Menu).

### 7.6 Toolbar

- Tools (1.3.7 manual, [man-fb] TOOLBAR): `workspacename`, `prevworkspace`, `nextworkspace`, `iconbar`, `prevwindow`, `nextwindow`, `systemtray`, `clock`. Also `button.<name>` (see section 2.4 for its resource status). The tool factory in [src-toolfactory] (tag) implements the first eight names.
- Clock format: `strftimeFormat`, a `strftime(3)` string ([man-fb]).

### 7.7 Iconbar modes and alignment

Modes (menu values from [src-iconbar] lines 172-178 at the tag):

- `none`
- `{static groups} (minimized=yes)` (Icons)
- `{static groups} (minimized=no)` (NoIcons)
- `{static groups} (minimized=yes) (workspace)` (WorkspaceIcons)
- `{static groups} (minimized=no) (workspace)` (WorkspaceNoIcons)
- `{static groups} (workspace)` (Workspace, default)
- `{static groups}` (All Windows)

Each mode is a window pattern ([man-fb] Iconbar Mode).

Alignment: `Left`, `Relative`, `Right` at 1.3.7 ([src-iconbar] lines 182-184 at the tag). `RelativeSmart` is **[post-1.3.7]** (commit [`b0663bc1`](https://github.com/fluxbox/fluxbox/commit/b0663bc1), 2021).

### 7.8 Workspaces

- `session.screenN.workspaces` sets the count. Add and remove from the Workspace menu or keys `AddWorkspace` and `RemoveLastWorkspace` ([man-keys]).
- `NextWorkspace [n]`, `PrevWorkspace [n]` wrap. `RightWorkspace`, `LeftWorkspace` do not wrap. `NextWorkspace 0` toggles the former workspace on master (commit [`a2fc845d`](https://github.com/fluxbox/fluxbox/commit/a2fc845d), 2016-09-03).
- Desktop wheel: default `OnDesktop Mouse4 :PrevWorkspace` and `Mouse5 :NextWorkspace` ([data-keys]).
- Toolbar wheel: `OnToolbar Mouse4 :PrevWindow {static groups} (iconhidden=no)` ([data-keys]).
- Workspace warping: section 2.3.

### 7.9 Window placement

- `session.screenN.windowPlacement` (default `RowSmartPlacement`). Strategies at the tag: `RowSmartPlacement`, `ColSmartPlacement`, `RowMinOverlapPlacement`, `ColMinOverlapPlacement`, `UnderMousePlacement`, `CascadePlacement` ([src-placement] lines 187-215, tag). `AutotabPlacement` is master-only (see 7.3).
- Direction: `rowPlacementDirection` (`LeftToRight`), `colPlacementDirection` (`TopToBottom`).
- Apps `[Position]` and `[Dimensions]` override placement for matching windows ([man-apps]).

### 7.10 Edge snapping and resistance

- `session.screenN.edgeSnapThreshold`: 10 px. Windows snap to screen edges and other windows during a move ([man-fb] RESOURCES).
- `edgeResizeSnapThreshold`: master only (section 2.4).
- `session.ignoreBorder` (default False) is described only as configuring border dragging ([man-fb] RESOURCES).

### 7.11 Maximize, struts and full maximization

- Maximize over toolbar and slit is controlled by `toolbar.maxOver`, `slit.maxOver`, `tabs.maxOver`. `fullMaximization` overrides all three ([man-fb] RESOURCES; Configuration menu Maximize Options).
- `maxIgnoreIncrement`, `maxDisableMove`, `maxDisableResize` ([man-fb] Maximize Options).
- Struts: 1.3.7 reads `_NET_WM_STRUT` ([src-screen] `availableWorkspaceArea`, tag). The `struts` resource is master only (section 2.4).

### 7.12 Move and resize

- `opaqueMove` (default true): show window content while dragging. Otherwise an outline is drawn.
- Resize opacity: no resource in 1.3.7. Master adds `opaqueResize` (section 2.4).
- Move and resize keys: `StartMoving`, `StartResizing [corner]` with `NearestCorner`, `NearestEdge`, `NearestCornerOrEdge`, `Center`, `TopLeft`, `Top`, `TopRight`, `Left`, `Right`, `BottomLeft`, `Bottom`, `BottomRight` ([man-keys] Mouse Commands).
- `showwindowposition`: popup with the window's coordinates while dragging.

### 7.13 Menus: typeahead, delay and tooltips

- Typeahead: start typing in a menu. Matches are shown; Tab cycles them; Backspace narrows; Enter activates; Esc closes ([wiki-typeahead]).
- `session.menuSearch`: `nowhere`, `itemstart` (default), `somewhere` ([man-fb] RESOURCES; ChangeLog 1.3.7 lines 11-32).
- Submenu delay: `session.screenN.menuDelay`, default 200 ms.
- Tooltips: `session.screenN.tooltipDelay`, default 500 ms.

### 7.14 Helper programs

- `fluxbox-remote(1)`: X11 client, sends key commands to a running fluxbox. Needs `session.screenN.allowRemoteActions: true`. The manual cautions that any X client can use it ([man-remote] CAVEATS).
- `fbrun(1)`: run dialog. Options in the tag manual ([man-fbrun]): `-title`, `-text`, `-w`, `-h`, `-display`, `-pos`, `-nearmouse`, `-fg`, `-bg`, `-font`, `-hf`, `-help`. Options `-center`, `-cf`, `-preselect` and `-autocomplete` are master-only.
- `fbsetbg(1)`: wallpaper setter. Options: `-f file` (fullscreen), `-c` (centred), `-t` (tiled), `-a` (aspect), `-u wallpapersetter`, `-b fbsetrootoptions`, `-r dir` (random), `-l` (last), `-i` (info), `-p` (tips), `-h`. Uppercase variants (`-F -C -T -A -U -B -R`) do not remember ([man-fbsetbg]).
- `fbsetroot(1)`: `-solid color`, `-mod x y`, `-gradient texturestring`, `-display`, `-bg/-background color`, `-fg/-foreground color`, `-from color`, `-to color`, `-help` ([man-fbsetroot]).
- `startfluxbox(1)`: runs `~/.fluxbox/startup` and then fluxbox. Example startup in [man-startfb].
- `fluxbox -rc file`, `-no-slit`, `-no-toolbar`, `-log file`, `-display`, `-screen`, `-verbose`, `-sync`, `-list-commands` ([man-fb] OPTIONS).

### 7.15 Signals and environment

- `SIGUSR1` restarts fluxbox. `SIGUSR2` reloads configuration ([man-fb] SIGNALS).
- `HOME` locates `~/.fluxbox`. `DISPLAY` is the target display ([man-fb] ENVIRONMENT).
- `Export` and `SetEnv` keys change the environment for children ([man-keys]).

## 8. Version history (0.9.x to 1.3.7)

Release dates from [fluxbox-news] and tag dates from git. ChangeLog line numbers refer to [ChangeLog].

| Version | Date | Notable changes (source) |
|---|---|---|
| 0.9.12 | 2005-01-18 | `Tab` command (line 2927). |
| 0.9.14 | 2005-09-15 | `MouseFocus`, `ClickFocus`, `MouseTabFocus`, `ClickTabFocus` (line 2410). Keycodes in keys file (line 2542). |
| 0.9.15 | 2006-03-23 | `session.styleOverlay` ([wiki-overlay]). |
| 1.0rc | 2006-06-13 | Keymodes (line 2112; first commit [`33079d25`](https://github.com/fluxbox/fluxbox/commit/33079d25), 2006-04-12). `ToggleCmd` (line 1924). External tabs on by default (line 2014). Apps keywords case-insensitive (line 1994). |
| 1.0rc3 | 2007-03-20 | Typeahead in menus (line 1384). Mouse buttons as keys (block). `[group] (workspace)` (line 1445). |
| 1.0.0 | 2007-10-08 | `fluxbox-remote` added (block). Groups file deprecated (line 1218). |
| 1.1.0 | 2008-09-04 | Groups file removed; auto-grouping in apps (line 1052). `[transient]` (line 716). `Attach` (line 961). `TypeAheadFocus` (line 1077). Conditionals, ForEach, ClientMenu, Delay, StartTabbing, ShadeOn/Off, SetLayer, SetDecor, SendToNext/PrevHead (block). MinOverlap placements (block). `OnTitlebar` and `Double` modifiers (block). |
| 1.3.0 | 2011-02-19 | `ActivateTab` (line 557). `StrictMouseFocus` (line 560). `MoveN`/`ClickN` (line 584). `Fullscreen` command (line 587). Titlebar button visibility in apps (line 606). `background: unset` (line 619). Rootcommand removed (line 646). |
| 1.3.1 | 2011-02-27 | Bugfix release ([fluxbox-news]). |
| 1.3.2 | 2011-10-30 | Bugfix release ([fluxbox-news]). |
| 1.3.3 | 2012-12-30 | `OnTab` modifier (line 236). `NearestCorner`, `NearestEdge`, `NearestCornerOrEdge` (line 250). |
| 1.3.4 | 2013-02-10 | `LHalf`/`RHalf` titlebar buttons (line 161). `ClientPatternTest` (line 167). |
| 1.3.5 | 2013-02-13 | No feature entries in its block. |
| 1.3.6 | 2015-01-06 | `DockApp` WM_CLASS handled as dockapps (line 80). `ArrangeWindowsStack` (line 113). Toolbar workspace switching (line 141). |
| 1.3.7 | 2015-02-08 | Typeahead options `nowhere`, `itemstart`, `somewhere` (line 11). Typeahead not limited to starts (line 32). |

Notes:

- Keys, apps and tabs predate 1.0. `session.appsFile` appears in 0.9.11 (line 3037) and the tab focus models in 0.9.14 (line 2410).
- Between 1.0 and 1.1 the keys grammar gained conditionals, `ForEach`, and the apps file took over auto-grouping.
- The `groups` file was deprecated in 1.0.0 and removed in 1.1.0 ([ChangeLog] lines 1218 and 1052).
- Manual man pages for 1.3.7 are dated `08 February 2015` ([man-fb]).

## 9. Repository state since 2015

### 9.1 Releases

- Last tag: `Release-1_3_7` (2015-02-08). There are no tags after it. Tag list: `Release-1_3_0` to `Release-1_3_7`, `Release-1_1_0`, `Release-1_1_1`, `Release-1_0_0`, `Release-1_0rc` and older.
- fluxbox.org news: last item is "Fluxconf2015 - Genesis of the 'There is no cabal!'" dated 2015-08-15 ([fluxconf-news]). It reports a conference in Heidelberg on 2015-08-13 and no release. No later news was listed on the homepage or news index when fetched on 2026-10-18 ([fluxbox-news]).

### 9.2 Commits

Counted with `git log` on the full history:

- Total commits by author-date year: 2015: 132; 2016: 128; 2017: 7; 2018: 7; 2019: 7; 2020: 11; 2021: 9; 2022: 5; 2023: 3; 2024: 1; 2025: 3; 2026: 5.
- Commits after the tag (226): 2013: 2; 2014: 20; 2015: 18; 2016: 128; 2017: 7; 2018: 7; 2019: 7; 2020: 11; 2021: 9; 2022: 5; 2023: 3; 2024: 1; 2025: 3; 2026: 5. Commits dated 2013-2015 are older branch work merged later.
- Most of 2016 is one maintainer's push (Thomas Lübking) plus Mathias Gumz and Mark Tiefenbruck.

### 9.3 Post-tag features on master

2016 (Thomas Lübking and others), by commit:

- Autotab placement [`ea466fa9`](https://github.com/fluxbox/fluxbox/commit/ea466fa9) (2016-09-11).
- Unclutter command [`a5b5be5e`](https://github.com/fluxbox/fluxbox/commit/a5b5be5e) (2016-08-29).
- Artificial struts per head [`f22435d6`](https://github.com/fluxbox/fluxbox/commit/f22435d6) (2016-08-11).
- Toolbar and slit autoraise [`fe8ff872`](https://github.com/fluxbox/fluxbox/commit/fe8ff872) (2016-08-13); toggle commands [`6c0565c4`](https://github.com/fluxbox/fluxbox/commit/6c0565c4) (2016-08-12); toggle hidden [`1473bcf6`](https://github.com/fluxbox/fluxbox/commit/1473bcf6) (2016-08-15).
- `OnSlit` context [`2678060e`](https://github.com/fluxbox/fluxbox/commit/2678060e) (2016-09-13); `OnWinButton`, `OnMinButton`, `OnMaxButton` [`4545f4da`](https://github.com/fluxbox/fluxbox/commit/4545f4da) (2016-09-14).
- `SpacerTool` [`f6e1f555`](https://github.com/fluxbox/fluxbox/commit/f6e1f555) (2016-07-24).
- `FocusProtection` for apps [`1a61881e`](https://github.com/fluxbox/fluxbox/commit/1a61881e) (2016-06-19), documented [`6907dc2c`](https://github.com/fluxbox/fluxbox/commit/6907dc2c) (2016-06-26); `FocusNewWindow` merged into it [`07d8fbfb`](https://github.com/fluxbox/fluxbox/commit/07d8fbfb) (2016-06-26).
- `IgnoreSizeHints` apps key [`8d88d9be`](https://github.com/fluxbox/fluxbox/commit/8d88d9be) (2016-08-12).
- Tooltips for tabs [`c69d5afb`](https://github.com/fluxbox/fluxbox/commit/c69d5afb); drag tabs to other workspaces [`bc1ad61a`](https://github.com/fluxbox/fluxbox/commit/bc1ad61a) (2016-09-13).
- `Next/PrevWorkspace 0` toggle [`a2fc845d`](https://github.com/fluxbox/fluxbox/commit/a2fc845d) (2016-09-03).
- 5-second emacs chord timeout [`6ca64223`](https://github.com/fluxbox/fluxbox/commit/6ca64223) (2016-08-31).
- Indicate iconified windows in the iconbar [`3058861f`](https://github.com/fluxbox/fluxbox/commit/3058861f) (2016-08-13).

2017-2021:

- Vertical workspace warping [`7cb7bfaa`](https://github.com/fluxbox/fluxbox/commit/7cb7bfaa) (2017-11-19).
- `MarkWindow` and `GotoMarkedWindow` [`174e62ff`](https://github.com/fluxbox/fluxbox/commit/174e62ff) (2020-08-23, Richard Tamin); fix [`6168d9c8`](https://github.com/fluxbox/fluxbox/commit/6168d9c8) (2020-09-27).
- Batch of patches from several contributors via Mark Tiefenbruck, 2021-07 (for example [`0279936d`](https://github.com/fluxbox/fluxbox/commit/0279936d) opaque resize delay; [`b0663bc1`](https://github.com/fluxbox/fluxbox/commit/b0663bc1) RelativeSmart; [`8bc11006`](https://github.com/fluxbox/fluxbox/commit/8bc11006) workspace warping split).

2025-2026:

- `WithdrawnState` on unmap [`c7ff3696`](https://github.com/fluxbox/fluxbox/commit/c7ff3696) (2025-06-19, Zhiyi Zhang).
- RandR notify event fix [`36f99b92`](https://github.com/fluxbox/fluxbox/commit/36f99b92) (2026-02-15, Brandon Enright).
- `_NET_DESKTOP_GEOMETRY` refresh on screen size change [`7723b83d`](https://github.com/fluxbox/fluxbox/commit/7723b83d) (2026-10-10, Adam Spiers).
- `SetFocusProtection` command [`6890143d`](https://github.com/fluxbox/fluxbox/commit/6890143d), `Factor FocusProtection flag parsing` [`edfa8582`](https://github.com/fluxbox/fluxbox/commit/edfa8582), `Apply FocusProtection to windows managed during a restart` [`d675a8e7`](https://github.com/fluxbox/fluxbox/commit/d675a8e7) (all 2026-10-07, Adam Spiers).

### 9.4 Other notes

- The master manuals list `ToggleSlitAbove` and `OnSlit`, which were added after the tag (Surprise 11).
- The tag's `fluxbox-keys.txt` lacks `OnSlit`, `Unclutter`, and the slit and toolbar toggle commands.
- `git.fluxbox.org` does not resolve here, so repo mirrors other than GitHub were not compared.

## 10. Sources

Bracketed IDs in the text are links to the sources listed here. Tag links point at `Release-1_3_7`. Links marked master point at branch `master`, HEAD [`6890143d`](https://github.com/fluxbox/fluxbox/commit/6890143d) (2026-10-07). Commit hashes link to GitHub commits.

[man-fb]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/doc/asciidoc/fluxbox.txt
[man-keys]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/doc/asciidoc/fluxbox-keys.txt
[man-apps]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/doc/asciidoc/fluxbox-apps.txt
[man-menu]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/doc/asciidoc/fluxbox-menu.txt
[man-style]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/doc/asciidoc/fluxbox-style.txt
[man-patterns]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/doc/asciidoc/client-patterns.txt
[man-remote]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/doc/asciidoc/fluxbox-remote.txt
[man-fbrun]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/doc/asciidoc/fbrun.txt
[man-fbsetbg]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/doc/asciidoc/fbsetbg.txt
[man-fbsetroot]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/doc/asciidoc/fbsetroot.txt
[man-startfb]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/doc/asciidoc/startfluxbox.txt
[ChangeLog]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/ChangeLog
[copying]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/COPYING
[data-keys]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/data/keys
[data-init]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/data/init.in
[data-apps]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/data/apps.in
[data-windowmenu]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/data/windowmenu
[data-overlay]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/data/overlay
[data-makemodule]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/data/Makemodule.am
[data-emerge]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/data/styles/Emerge/theme.cfg
[gen]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/util/fluxbox-generate_menu.in
[fbsetbg-sh]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/util/fbsetbg
[src-fluxbox]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/src/fluxbox.cc
[src-screenres]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/src/ScreenResource.cc
[src-toolbar]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/src/Toolbar.cc
[src-slit]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/src/Slit.cc
[src-iconbar]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/src/IconbarTool.cc
[src-focus]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/src/FocusControl.cc
[src-placement]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/src/ScreenPlacement.cc
[src-window]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/src/Window.cc
[src-keys]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/src/Keys.cc
[src-remember]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/src/Remember.cc
[src-clientpat]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/src/ClientPattern.cc
[src-menucreator]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/src/MenuCreator.cc
[src-screen]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/src/Screen.cc
[src-layer]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/src/Layer.hh
[src-texture]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/src/FbTk/Texture.cc
[src-themeitems]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/src/FbTk/ThemeItems.cc
[src-rootTheme]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/src/RootTheme.cc
[src-toolfactory]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/src/ToolFactory.cc
[src-toolbarTheme]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/src/ToolbarTheme.cc
[src-clock]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/src/ClockTool.cc
[src-cmdparser]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/src/FbTk/CommandParser.hh
[src-menusearch]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/src/FbTk/MenuSearch.hh
[src-buttontool]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/src/ButtonTool.cc
[src-configure]: https://github.com/fluxbox/fluxbox/blob/Release-1_3_7/configure.ac
[src-workspacecmd]: https://github.com/fluxbox/fluxbox/blob/master/src/WorkspaceCmd.cc
[man-fb-master]: https://github.com/fluxbox/fluxbox/blob/master/doc/asciidoc/fluxbox.txt
[man-apps-master]: https://github.com/fluxbox/fluxbox/blob/master/doc/asciidoc/fluxbox-apps.txt
[man-keys-master]: https://github.com/fluxbox/fluxbox/blob/master/doc/asciidoc/fluxbox-keys.txt
[man-style-master]: https://github.com/fluxbox/fluxbox/blob/master/doc/asciidoc/fluxbox-style.txt
[wiki-keymodes]: https://web.archive.org/web/20160111122816/http://fluxbox-wiki.org/category/howtos/en/Keymodes.html
[wiki-tabs]: https://web.archive.org/web/20160111122816/http://fluxbox-wiki.org/category/howtos/en/Tabs.html
[wiki-typeahead]: https://web.archive.org/web/20160111122816/http://fluxbox-wiki.org/category/howtos/en/Typeahead.html
[wiki-overlay]: https://web.archive.org/web/20160111122816/http://fluxbox-wiki.org/category/howtos/en/Style_overlay.html
[arch]: https://wiki.archlinux.org/title/Fluxbox
[fluxbox-news]: https://fluxbox.org/news/
[fluxconf-news]: https://fluxbox.org/news/2015-08-15-fluxconf2015-genesis-of-the-there-is-no-cabal/

## Appendix: Fluxbox 1.3.7 man page sources at the tag

`doc/asciidoc/` at `Release-1_3_7` holds `client-patterns.txt`, `fbrun.txt`, `fbsetbg.txt`, `fbsetroot.txt`, `fluxbox-apps.txt`, `fluxbox-keys.txt`, `fluxbox-menu.txt`, `fluxbox-remote.txt`, `fluxbox-style.txt`, `fluxbox.txt`, `startfluxbox.txt`, and `README.txt`. The `.in` files in `doc/` are the generated man pages.
