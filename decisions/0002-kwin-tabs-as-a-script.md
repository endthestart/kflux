# 0002: KWin tabs as a KWin script, not a fork

Date: 2026-10-19. Status: **deprecated** by [0003](0003-1.0-is-kflux-on-labwc.md). The spike worked, but kflux isn't going for a Plasma-based desktop. Tabs will come to labwc instead.

## Question

The goal: Fluxbox-style window tabs on KWin, time-boxed. Should they
come from a KWin fork, a patch carried on KWin, or something that needs
neither?

## Decision

Ship tabs as **fluxtabs**, a declarative KWin script (QML and JavaScript, about
400 lines, MIT). Don't fork KWin. Go back
to a patch only if tabs drawn inside the window decoration become a
requirement, and then propose it upstream rather than carrying a fork.

## What the spike showed

Tested on KWin 6.8.0 (CachyOS) in a Plasma Wayland session, in a VM
on an Intel Mac with software rendering. The script and its screenshots were
left out of the public repository when this record was deprecated.

| Behaviour | Result |
|---|---|
| Tab the active window into the window it overlaps (Meta+Ctrl+G) | works |
| Fluxbox-style external tab strip above the frame, showing every tab's title, active one highlighted | works |
| Strip moves into the titlebar when the frame touches the top of the screen (maximised) | works |
| Next/previous tab (Meta+Tab / Meta+Shift+Tab); a click on a tab switches | works (shortcuts tested; clicks not automated) |
| Switching keeps one shared frame: geometry, maximised size, minimise and desktop follow the active tab | works |
| Background tabs hidden from the taskbar, Alt-Tab and pager; only the active tab shows | works |
| Translucent windows (the kflux Konsole) don't show the tab underneath them | works: background tabs get opacity 0 |
| Detach (Meta+Ctrl+D, or middle-click a tab) | works |
| Closing a tab hands the frame to the next tab | implemented, not yet exercised |
| Drag a window onto another's titlebar to tab it (Fluxbox Ctrl-drag) | implemented, needs a manual test: the VM had no pointer automation |

Dev loop: each iteration was loaded from a fresh path through KWin's
`/Scripting` D-Bus interface. KWin's single QML engine caches
components by URL, so reinstalling at the same path keeps stale code.

## Why not a fork

Everything tabs need is in KWin 6's scripting API:

- **Window state:** `frameGeometry`, `skipTaskbar`, `skipSwitcher`, `opacity`, `minimized` and `desktops` are writable.
- **Events:** `stackingOrder`, `cursorPos`, and the move/resize signals tell the script when and where a window was dropped.
- **Shortcuts:** `ShortcutHandler` registers them.
- **Tab strip:** `PlasmaCore.Window` draws it as an unmanaged internal window.

A fork would mean rebasing on every Plasma release, every four months plus
bugfix releases, and version-locking KWin against plasma-workspace. The
script installs per user or system-wide, can go on the KDE Store, and survives
Plasma updates as long as the Plasma 6 scripting API stays stable.

## Limits of the script approach (where a patch would help)

1. **Strip stacking.** The strip is an overlay, not part of the decoration. It
   can't be stacked just above its own frame, so it shows only while the group
   is focused. Fluxbox showed tabs on unfocused groups too. Fixing that needs
   group awareness in KDecoration, or a decoration plugin that knows about
   groups.
2. **Maximise and fullscreen are copied as geometry, not state.** Restoring a
   background tab can then behave oddly. Next step: mirror state with
   `setMaximize()`.
3. **No modifier for drag-to-tab.** Scripts can't read keyboard modifiers, so
   dropping onto a titlebar always tabs. A `RequireShift` option (via a
   shortcut-held mode) is possible later.
4. **Groups don't survive a session restart.**
5. **Overview and Present Windows still show background tabs.**

## Consequences for kflux

- The fallback Plasma session can now have Fluxbox tabs. The script works on
  any KWin 6 Plasma session, kflux or not.
- This opens a third base for kflux: KWin with fluxtabs, plus kflux's
  translator generating KWin and Plasma config. That would keep 100% of KDE and
  add tabs. Pick the 1.0 base once the fluxland port reports.
- Packaging: ship fluxtabs as its own package (`kwin-fluxtabs`) so Plasma
  users can install it without kflux.
