# labwc-kflux: Fluxbox tabs for labwc

`labwc-kflux` is stock labwc plus one patch,
[`patches/labwc-tabs.patch`](../patches/labwc-tabs.patch), currently against
labwc 0.20.2. It is optional: kflux works fully on stock labwc. Why it's a
carried patch and not upstreamed: [ADR 0003](adr/0003-tabs-as-optional-labwc-patch.md).

The patch is GPL-2.0-only, like labwc. It was written with AI assistance, so it
must not be sent to labwc while labwc bans AI-generated contributions.

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

## Out of scope

- Fluxbox's external tabs (`session.screen0.tabs.usePixmap`, tabs on the
  frame's side or above it). Tabs live in the titlebar only.
- Dragging a tab within the strip to reorder (use `MoveTabLeft/Right`).
- Saving groups across restarts (Fluxbox's `remember` file).
- Grouping CSD windows.
- Tabs for Xwayland override-redirect windows, and for dialogs/transients
  (they stay attached to their parent and follow it as now).

## Why this shape

- labwc has no plugin or scripting surface, and tabs need the scene graph,
  decorations, focus and the foreign-toplevel handles, so it has to be in the
  compositor ([labwc#1932](https://github.com/labwc/labwc/issues/1932) said
  the same).
- Keeping each member a full view means no changes to the xdg-shell or
  Xwayland code, the geometry state machine, or the move/resize grab. The patch
  touches view visibility, focus and the titlebar, plus one new file,
  `src/tabs.c`. That's the shape most likely to rebase cleanly every labwc
  release and to be reviewable upstream.
- fluxland's tabs were the UX reference for strip layout and frame-state
  handoff. No code is shared.

## Rebasing on a new labwc release

1. Unpack the new labwc release tarball into a git tree and commit it as the base.
2. Apply the current patch with `patch -Np1 -i patches/labwc-tabs.patch`, and
   resolve rejects.
3. Build and run labwc's own tests (`meson test -C build`), then the kflux
   image with `tools/build.sh` and `tools/verify.sh`, which checks that
   `labwc-kflux` is installed and the tab bindings are translated.
4. Export the patch: keep its header (first lines up to the first `diff`),
   update the labwc version in it, and append `git diff` against the base.
5. In `packaging/arch/labwc-kflux/PKGBUILD`, set `pkgver` to the labwc version,
   reset `pkgrel=1`, run `updpkgsums` and regenerate `.SRCINFO`.
