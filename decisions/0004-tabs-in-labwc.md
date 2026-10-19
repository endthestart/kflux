# 0004: Fluxbox tabs in labwc, as a carried patch

Date: 2026-10-19. Status: accepted for the patch; upstreaming is the maintainer's
call ([0003](0003-1.0-is-kflux-on-labwc.md)).

## Decision

Add Fluxbox-style window tabs to labwc 0.20.2 (the version CachyOS ships) as
`third_party/patches/labwc-tabs.patch`, built as the `labwc-kflux` package,
which provides and conflicts with `labwc`. The patch is the smallest feature
that feels like Fluxbox: group windows into one frame, show every tab in the
titlebar, switch, detach. The kflux translator maps Fluxbox's tab commands and
the `apps` file's `[group]` onto it.

## The model

A **tab group** is a list of ordinary labwc views plus a pointer to the
**active** one. There's no new frame object: the active view *is* the frame,
and the others are hidden behind it.

- **One visible member.** Hidden members keep their surfaces mapped but their
  scene trees are disabled. `view_is_focusable()` returns false for them, which
  drops them from everything that walks `server.views` with criteria: the
  window switcher, focus-topmost, show-desktop, placement, edge snapping. Their
  `foreign_toplevel` handles are destroyed while hidden, so taskbars, Waybar
  and the client-list menu show one entry per group.
- **Frame state lives on the active member.** Move, resize, maximize,
  minimize, shade, fullscreen, tiling, layer, omnipresence and workspace act on
  the active view only, with no changes to those code paths. Whenever the
  active member changes (switch, detach, close), the new one takes the old
  one's frame state: workspace, layer, omnipresence, output, fullscreen,
  maximized axes, tiled edge or region, natural geometry, geometry and shade.
- **Sizes stay in step eagerly.** When the active member's geometry changes,
  hidden members are configured to the same box, so a switch doesn't show a
  stale-size buffer while the client catches up.
- **Stacking.** A switch puts the new active view exactly where the old one was
  in `server.views` and in the scene graph, and moves focus with it only if
  the old one had focus.
- **Lifetime.** A member that unmaps or is destroyed leaves its group; if it was
  active, its neighbour takes over its frame state. A group of one dissolves.
- **Activation requests.** Focusing a hidden member (xdg-activation, a
  client-list menu item, a `Focus` action) switches to that tab first, as
  Fluxbox does.
- **Decorations.** Grouping needs a server-side titlebar on both windows.
  CSD windows can't be tabbed: there's nowhere to draw the strip.

## The tab strip

When a view's group has more than one member, its titlebar's title area (the
space between the buttons) is split into equal-width tabs, one per member, in
group order. Each tab shows that member's title. The active tab keeps the
titlebar's own background; the others get a translucent dark overlay and the
inactive label colour, with 1px separators in the border colour. The strip is
rebuilt when the group changes, a member's title changes, or the frame width
changes. Tab nodes are `LAB_NODE_TITLE` nodes, so every existing `Title` and
`TitleBar` mousebind still works on them; their node descriptor carries the
member they stand for.

No new theme keys in this patch. Fluxbox's `window.label.focus/unfocus/active`
textures would map onto three optional keys later if the derived colours
aren't enough.

## Actions

| labwc action | Fluxbox command | What it does |
|---|---|---|
| `ActivateTab` | `ActivateTab` | Mousebind: switch to the tab under the cursor |
| `NextTab` / `PreviousTab` | `NextTab` / `PrevTab` | Switch tab, wrapping |
| `GoToTab index="n"` | `Tab n` | Switch to the nth tab (1-based; negative counts from the end) |
| `MoveTabLeft` / `MoveTabRight` | `MoveTabLeft` / `MoveTabRight` | Reorder the active tab |
| `DetachTab` | `DetachClient` | Take the active tab out into its own window, offset by one titlebar height |
| `StartTabbing` | `StartTabbing` | Mousebind drag: an outline follows the cursor; dropped on another window's titlebar the window joins that group as its active tab; dropped anywhere else, it leaves its group (if any) and moves there |
| `GroupWithWindowBelow` | (kflux addition) | Tab the window into the topmost window beneath it that overlaps it on the same workspace (else the next window down) |
| `JoinTabGroup identifier="glob"` | `apps` `[group]` | Window-rule action: on first map, join the topmost visible window on the workspace whose app id matches |

kflux's default keys follow Fluxbox's defaults:

```
OnTitlebar Mouse1 :MacroCmd {Raise} {Focus} {ActivateTab}
OnTitlebar Control Mouse1 :StartTabbing
Mod4 Tab :NextTab
Mod4 Shift Tab :PrevTab
Mod4 g :GroupWithWindowBelow
Mod4 Shift g :DetachClient
```

`StartTabbing` uses an outline rather than moving the window, as Fluxbox did,
so the drop target is whatever titlebar is visibly under the pointer. The
outline is drawn above all windows.

## The `apps` file

```
[group] (workspace)
  [app] (class=org.kde.konsole)
  [app] (class=org.kde.dolphin)
[end]
```

becomes one window rule per member app, each with a `JoinTabGroup` action per
app in the group (its own app first, then the rest). The first action that
finds a target wins. A `[group]` of one app tabs every window of that app
together. The `(workspace)` option is the default behaviour: only windows on
the current workspace are candidates.

## Result (2026-10-19)

Built into the image as `labwc-kflux 0.20.2-1`. `build/verify.sh` passes 28 of
28 on a fresh boot, including two new checks: labwc-kflux is installed and the
tab bindings are translated. Tested in the VM with Dolphin and Konsole
(`screenshots/labwc-tabs-*.png`):

| Behaviour | Result |
|---|---|
| Ctrl-drag Konsole's titlebar onto Dolphin's: one frame, two tabs, one taskbar entry | works |
| Click a tab to switch; Super+Tab | works |
| Super+Shift+G (DetachClient): Konsole back in its own window, two taskbar entries | works |
| Super+G (GroupWithWindowBelow), maximize, Super+Tab: Dolphin takes the maximized frame at full size | works |

Tested headless (labwc headless backend, a small xdg-shell test client,
`wtype`, and a virtual pointer):

- `JoinTabGroup` from a window rule
- `NextTab` wrapping
- maximize, close and detach of the active tab
- `SendToDesktop`, after which a switch on the other desktop brings the new tab there
- iconify of the group
- dragging a tab out to the desktop
- pressing a background tab and dragging, which switches and moves the frame
- one foreign-toplevel handle per group, keeping its place and following the active tab's title

Not yet exercised:

- Xwayland clients
- the `apps` `[group]` rule end to end in the VM (the translation is checked)
- multi-monitor

## Out of scope (for now)

- Fluxbox's external tabs (`session.screen0.tabs.usePixmap`, tabs on the
  frame's side or above it). Tabs live in the titlebar only.
- Dragging a tab within the strip to reorder (use `MoveTabLeft/Right`).
- Saving groups across restarts (Fluxbox's `remember` file).
- Grouping CSD windows.
- Tabs for Xwayland override-redirect windows, and for dialogs/transients
  (they stay attached to their parent and follow it as now).

## Why a patch, why this shape

- labwc has no plugin or scripting surface, and tabs need the scene graph,
  decorations, focus and the foreign-toplevel handles, so it has to be in the
  compositor ([labwc#1932](https://github.com/labwc/labwc/issues/1932) said
  the same).
- Keeping each member a full view means no changes to the xdg-shell or
  Xwayland code, the geometry state machine, or the move/resize grab. The patch
  touches view visibility, focus and the titlebar, plus one new file,
  `src/tabs.c`. That's the shape most likely to rebase cleanly every labwc
  release and to be reviewable upstream.
- The fluxland port (`third_party/patches/fluxland-wlroots-0.20.patch`) and the
  deprecated KWin script ([0002](0002-kwin-tabs-as-a-script.md)) are UX references for strip layout and
  frame-state handoff. No code is shared.
