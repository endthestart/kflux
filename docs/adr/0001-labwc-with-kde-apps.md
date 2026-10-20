# 0001: labwc as the compositor, KDE apps behind it

Date: 2026-10-18 (revised 2026-10-19). Status: accepted.

## Context

kflux wants Fluxbox's model, a desktop whose whole behaviour lives in a few
short text files, with KDE's applications and services. The candidates were
Plasma themed to look like Fluxbox, labwc with KDE apps on top, a fork of KWin
or the Plasma shell, and fluxland (a Wayland Fluxbox clone).

## Decision

kflux runs on stock [labwc](https://labwc.github.io), with Waybar as the
toolbar and slit, and KDE's apps and services (Dolphin, Konsole, Kate,
KRunner, System Settings modules, KDE Connect, the portals and the polkit
agent) running on it.

Rejected:

- **Plasma, themed.** It can copy Fluxbox's look but not its model: Plasma's
  state lives in GUI-written files that aren't meant for hand editing.
- **A KWin or Plasma fork.** Most of what a fork would add is possible through
  KDE's plugin points; only tabs need KWin itself, and a fork must be rebased
  on every Plasma release. A KWin tabs script (fluxtabs) was spiked and worked,
  but kflux isn't going for a Plasma-based desktop; it was never released.
- **fluxland as the base.** See [0004](0004-fluxland-parked.md).

## Consequences

- labwc's Openbox-lineage config (`rc.xml`, `menu.xml`, `themerc`) already
  matches Fluxbox's model; most Fluxbox keys translate one to one.
- Display settings use wdisplays, because KScreen needs KWin. Notifications are
  mako, not Plasma's.
- The iconbar lists windows from every workspace: Wayland's foreign-toplevel
  protocol carries no workspace.
- Revisit if labwc development stalls, or if Plasma features come to matter
  more than the text-file model.
