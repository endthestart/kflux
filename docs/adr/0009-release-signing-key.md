# 0009: A dedicated release signing key

Date: 2026-10-20. Status: accepted.

## Decision

Releases are signed with a GPG key used only for kflux releases, kept on the
maintainer's machine or a hardware key. It signs the annotated release tags
and a detached signature for each release tarball. Its fingerprint is
published in [docs/RELEASING.md](../RELEASING.md), on the website and in the
PKGBUILDs' `validpgpkeys`.

## Consequences

- makepkg verifies the tarball against the key before building.
- Rotating the key needs a signed transition statement from the old key and a
  `validpgpkeys` update in every package.
