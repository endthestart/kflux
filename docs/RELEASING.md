# Releasing kflux

Status: the repository is github.com/endthestart/kflux. 0.1.0 is the first
tag. kflux and labwc-kflux aren't in the AUR yet.

## Repository hygiene

1. **Not tracked.** `.gitignore` covers `.cache/`, `vm/`,
   `third_party/fluxland/` (the 73 MB upstream checkout; the fluxland-kflux
   PKGBUILD fetches fluxland by pinned commit) and `docs/upstream/` (unposted
   upstream drafts). `packaging/make-dist.sh` leaves the same paths out.
2. **Name.** "kflux" was chosen on 2026-10-19 ([research/naming.md](../research/naming.md)). USPTO and TMview (EU, UK and other offices) were searched on 2026-10-19: no KFLUX mark, with UK KFluxMod as the nearest (see naming.md). Re-run both searches just before the first release, since filings change.
3. **Licences.** kflux is MIT ([LICENSE](../LICENSE)). The Fluxbox-derived
   defaults keep Fluxbox's MIT notice
   ([LICENSES/Fluxbox-MIT.txt](../LICENSES/Fluxbox-MIT.txt)). No CC BY-SA
   style is bundled; see [NOTICE.md](../NOTICE.md). fluxland, if vendored,
   keeps its own MIT LICENSE under `third_party/`. `third_party/patches/labwc-tabs.patch`
   modifies labwc and is GPL-2.0-only, like labwc.
4. **Clean-room check.** The repo holds no copied screenshots or art from
   other people. Research links point outward.

## Cutting a release

1. Set `VERSION` in `overlay/usr/bin/kflux`, set `pkgver` in both PKGBUILDs, and tag `vX.Y.Z`.
2. Push the tag. GitHub serves `archive/refs/tags/vX.Y.Z.tar.gz`, the tarball the PKGBUILDs fetch.
3. In `packaging/arch/kflux/` and `packaging/arch/labwc-kflux/` (1.0 ships kflux and labwc-kflux. fluxland-kflux is parked; see decisions/0003 and 0004). labwc-kflux's `pkgver` follows labwc, not kflux: bump `_kfluxver` there, and rebase `labwc-tabs.patch` whenever CachyOS moves to a new labwc:
   - run `updpkgsums`, which replaces the `SKIP` checksum
   - run `makepkg -f`
   - run `namcap PKGBUILD *.pkg.tar.zst`
   - run `makepkg --printsrcinfo > .SRCINFO`
4. AUR: clone `ssh://aur@aur.archlinux.org/kflux.git` and `.../labwc-kflux.git`. Copy `PKGBUILD` and `.SRCINFO` into each, commit and push.

## Testing a package locally (no release needed)

```bash
packaging/make-dist.sh 0.1.0
```

Then, on any Arch or CachyOS machine:

```bash
cd packaging/arch/kflux && KFLUX_SRC=file:///path/to/kflux-0.1.0.tar.gz makepkg -fi
```

Both packages were built and installed this way in a CachyOS VM on
2026-10-19. A fresh login then went through the first-run path:

- the default config was seeded
- the welcome notification showed
- `kflux doctor` reported all checks ok

## CachyOS repository (later)

Once the AUR packages have users, ask CachyOS to carry `kflux` in
the `cachyos` repo. A kflux entry in CachyOS's installer
desktop list would follow from that.
