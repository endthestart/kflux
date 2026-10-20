# 0002: Fluxbox-format files, translated by `kflux`

Date: 2026-10-18. Status: accepted.

## Context

Fluxbox users have `init`, `keys`, `apps`, `menu`, `windowmenu`, `slitlist`
and `startup` files, and hundreds of styles. labwc, Waybar, mako, swaylock and
KDE each have their own formats.

## Decision

Users edit Fluxbox-format files in `~/.config/kflux/`. A single translator,
`kflux` (Python, standard library only), renders them into labwc, Waybar,
mako, swaylock and KDE colour configs. Fluxbox styles are used unmodified.
Whatever can't be translated is reported by `kflux warnings`, never silently
dropped.

## Consequences

- One source of truth for the user; generated files are kflux's to rewrite.
- Every style change reaches the window theme, toolbar, slit, wallpaper,
  notifications, lock screen and running KDE apps.
- kflux has to track labwc and Waybar config changes.
- No runtime dependencies beyond Python's standard library for the translator
  itself.
