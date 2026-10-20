# 0005: Arch and CachyOS only for 1.0

Date: 2026-10-20. Status: accepted.

## Context

One maintainer can test and support one distro family well. kflux's
dependencies all come from distro packages.

## Decision

kflux 1.0 supports Arch Linux and CachyOS, using the labwc version they ship.
Other distributions are welcome and best-effort. kflux enters an official
distro repository only if a packager in that distro offers to maintain it;
the patched labwc never does.

## Consequences

- Packages: the AUR first, then the CachyOS repository.
- Bug reports from other distros are accepted, but fixes that only matter
  there aren't release blockers.
