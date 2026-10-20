# Changelog

All notable changes to kflux are listed here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and kflux uses
[semantic versioning](https://semver.org/) for its user-facing contract
([ADR 0008](docs/adr/0008-versioning-and-support.md)).

## [Unreleased]

### Changed

- The repository is reorganised as a product repository: `src/`, `data/`,
  `patches/`, `packaging/`, `tools/` and `docs/` (with decision records under
  `docs/adr/`). The parked fluxland session moved to `experimental/fluxland/`.
- `make install` is the single install mapping, used by the package, the test
  image and the dev loop.

### Added

- CONTRIBUTING.md (DCO sign-off, AI-assisted contribution policy),
  SECURITY.md, a code of conduct, this changelog, and issue templates.
- `docs/RELEASING.md`: the release procedure, with signed tags and tarballs.

## [0.1.0] - 2026-10-19

First tagged version.

### Added

- The `kflux` translator: Fluxbox `init`, `keys`, `apps`, `menu`,
  `windowmenu`, `slitlist` and `startup` files rendered into labwc, Waybar,
  mako, swaylock and KDE colour configs; any Fluxbox style, unmodified.
- The kflux session, with KDE's apps and services behind labwc.
- `kflux doctor` and `kflux warnings`.
- `labwc-kflux`: labwc 0.20.2 plus Fluxbox-style window tabs.

[Unreleased]: https://github.com/endthestart/kflux/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/endthestart/kflux/releases/tag/v0.1.0
