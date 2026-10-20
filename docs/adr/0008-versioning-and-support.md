# 0008: Versioning and support window

Date: 2026-10-20. Status: accepted.

## Decision

- **Semantic versioning** of kflux's user-facing contract: the files in
  `~/.config/kflux` and the `kflux` command. Before 1.0, config formats may
  change with a migration note in the changelog. After 1.0, breaking changes
  only in a major release, and anything deprecated warns for at least one
  minor release first.
- **Cadence:** a minor release about every four months, a few weeks after a
  labwc release; patch releases as needed. No fixed dates before 1.0.
- **Support:** the current minor gets bug fixes; the previous minor gets
  security fixes for 3 months after its successor ships. No LTS until there is
  a second maintainer.
- Generated files (`~/.config/labwc`, `~/.config/kflux/generated`) are not part
  of the contract.

The release procedure is [docs/RELEASING.md](../RELEASING.md).
