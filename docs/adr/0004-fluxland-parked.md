# 0004: fluxland is parked

Date: 2026-10-19 (revised 2026-10-20). Status: accepted.

## Context

[fluxland](https://github.com/ecliptik/fluxland) is an MIT-licensed Wayland
Fluxbox clone with native tabs, keymodes, a toolbar and a slit. kflux ported
it from wlroots 0.18 to 0.20 and ran it as a second session. The port needed
six fixes beyond the API changes, including two crashes on first use and
broken mouse tabbing, and every wlroots release would need another port with
no upstream maintainer to share it.

## Decision

fluxland is not part of any kflux release. The port, its PKGBUILD, session
files, dev scripts and findings stay together in
[`experimental/fluxland/`](../../experimental/fluxland/), intact and movable
to a repository of its own. `tools/build.sh --with-fluxland` still builds it
into the test image.

## Consequences

- kflux's release tooling and the default test image don't depend on it.
- If labwc stays closed to AI-assisted work, fluxland is the candidate for a
  compositor kflux controls; that would be a project of its own.
