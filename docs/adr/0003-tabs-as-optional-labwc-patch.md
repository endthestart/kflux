# 0003: Tabs as an optional labwc patch, not upstreamed

Date: 2026-10-19 (revised 2026-10-20). Status: accepted.

## Context

Window tabs were Fluxbox's signature feature. labwc has no plugin surface, and
tabs need the scene graph, decorations, focus and foreign-toplevel handles, so
they have to be in the compositor. labwc called tabs out of scope
([labwc#1932](https://github.com/labwc/labwc/issues/1932)), and its
CONTRIBUTING.md bans AI-generated contributions. A patched labwc can't enter
Arch's or other distros' official repositories.

## Decision

- Tabs live in [`patches/labwc-tabs.patch`](../../patches/labwc-tabs.patch),
  built as the optional `labwc-kflux` package, which provides and conflicts
  with `labwc`. The patch is GPL-2.0-only, like labwc.
- kflux works fully on stock labwc. Without the patch, tab bindings are
  reported by `kflux warnings`.
- Everything that can be done in kflux (the translator, Waybar) is done there.
  What needs labwc goes into this one patch, kept as small as possible.
- The patch is not offered upstream while labwc bans AI-generated content.
  Revisit if that policy changes.

The patch's design and how to rebase it: [docs/labwc-kflux.md](../labwc-kflux.md).

## Consequences

- `labwc-kflux` ships in the AUR, later perhaps the CachyOS repository; never
  in an official distro repository.
- Each labwc release needs a rebase of the patch.
