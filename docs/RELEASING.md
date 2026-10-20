# Releasing kflux

Versioning and the support window: [ADR 0008](adr/0008-versioning-and-support.md).
Two packages ship from each release: `kflux` (MIT, `arch=any`) and the optional
`labwc-kflux` (GPL-2.0-only), both in the AUR. `labwc-kflux`'s `pkgver`
follows labwc; its `_kfluxver` names the kflux release whose tarball carries
the patch.

## The release key

Tags and tarballs are signed with the kflux release key
([ADR 0009](adr/0009-release-signing-key.md)):

```
KFLUX_RELEASE_KEY_FPR
```

The public key is [kflux-release-key.asc](kflux-release-key.asc) and on
keys.openpgp.org. To verify a release:

```bash
gpg --recv-keys KFLUX_RELEASE_KEY_FPR
gpg --verify kflux-X.Y.Z.tar.gz.sig kflux-X.Y.Z.tar.gz
sha256sum -c SHA256SUMS
git tag -v vX.Y.Z
```

## Calendar

For a minor release (X.Y.0):

| When | What |
|---|---|
| 3 weeks before | **Feature freeze.** Only bug fixes, docs and translations land. |
| 2 weeks before | **String freeze**, once kflux has translations. |
| 1 week before | **Code freeze.** Only release-blocking fixes. Test on real hardware. |
| release day | the steps below |

Patch releases (X.Y.Z) skip the freezes; they carry bug fixes only, or
security fixes for the previous minor. When the previous minor needs a fix
after its successor ships, branch `release-X.Y` from its last tag.

## Cutting a release

Replace `X.Y.Z` throughout.

### 1. Prepare

1. `VERSION` in `src/kflux`.
2. `pkgver` in `packaging/arch/kflux/PKGBUILD`, and `pkgrel=1`.
3. If the tabs patch changed: `_kfluxver` in `packaging/arch/labwc-kflux/PKGBUILD`,
   and bump its `pkgrel` (or set `pkgver` and `pkgrel=1` on a new labwc).
4. CHANGELOG.md: rename `## [Unreleased]` to `## [X.Y.Z] - YYYY-MM-DD`, add a
   new empty `## [Unreleased]`, and update the compare links at the bottom.

### 2. Test

1. `make check`.
2. The packages, from a working-tree tarball, in a clean Arch or CachyOS
   environment (the kflux Colima profile's `cachyos/cachyos` container works):

   ```bash
   packaging/make-dist.sh X.Y.Z            # .cache/dist/kflux-X.Y.Z.tar.gz
   # in packaging/arch/kflux/, with the tarball and an empty .sig copied in:
   makepkg -f --skipinteg && namcap PKGBUILD kflux-*.pkg.tar.zst
   ```

   Install the package with `pacman -U` on stock labwc: only the hard
   dependencies should come in, `kflux doctor` should report every
   `required:` line ok, and `kflux warnings` should list only the tab
   bindings.
3. The test image: `tools/build.sh`, `tools/run-vm.sh --headless`, then
   `tools/verify.sh` must report 0 failures. It builds `labwc-kflux` from its
   PKGBUILD.
4. For a minor release, the owner's real-hardware checklist: SDDM login,
   multiple monitors and HiDPI, suspend and resume, the lock screen, network,
   audio and Bluetooth, a style switch, and tabs with `labwc-kflux`.

### 3. Commit and tag

```bash
git commit -s -am "kflux X.Y.Z"
git tag -s vX.Y.Z -m "kflux X.Y.Z"
git tag -v vX.Y.Z
```

`git config user.signingkey KFLUX_RELEASE_KEY_FPR` in this repository makes
`-s` use the release key.

### 4. Build and sign the release files

```bash
packaging/make-dist.sh X.Y.Z vX.Y.Z .cache/release
cd .cache/release
gpg --local-user KFLUX_RELEASE_KEY_FPR --detach-sign kflux-X.Y.Z.tar.gz
shasum -a 256 kflux-X.Y.Z.tar.gz kflux-X.Y.Z.tar.gz.sig > SHA256SUMS
gpg --verify kflux-X.Y.Z.tar.gz.sig kflux-X.Y.Z.tar.gz
```

`make-dist.sh` uses `git archive` and `gzip -n`, so the same tag always gives
the same tarball. Paths marked `export-ignore` in `.gitattributes` are left
out.

### 5. Publish

1. `git push origin main vX.Y.Z`
2. The GitHub Release, with the changelog section as its notes:

   ```bash
   awk '/^## \[X.Y.Z\]/{f=1;next} /^## \[/{f=0} f' CHANGELOG.md > .cache/release/notes.md
   gh release create vX.Y.Z --verify-tag --title "kflux X.Y.Z" \
     --notes-file .cache/release/notes.md \
     .cache/release/kflux-X.Y.Z.tar.gz .cache/release/kflux-X.Y.Z.tar.gz.sig \
     .cache/release/SHA256SUMS
   ```

3. Download the assets back and check them: `shasum -a 256 -c SHA256SUMS`
   and `gpg --verify`.

### 6. Packages

In each of `packaging/arch/kflux/` and `packaging/arch/labwc-kflux/` (if it
changed), in an Arch environment:

1. `updpkgsums` (fetches the release tarball and records its sum)
2. `makepkg -f` (verifies the signature against `validpgpkeys`), then
   `namcap PKGBUILD *.pkg.tar.zst`
3. `makepkg --printsrcinfo > .SRCINFO`
4. Commit the PKGBUILD and `.SRCINFO` changes here, then push.

Then the AUR, for each package:

```bash
git clone ssh://aur@aur.archlinux.org/kflux.git aur-kflux
cp packaging/arch/kflux/{PKGBUILD,.SRCINFO} aur-kflux/
mkdir -p aur-kflux/keys/pgp && cp docs/kflux-release-key.asc aur-kflux/keys/pgp/KFLUX_RELEASE_KEY_FPR.asc
cd aur-kflux && git add -A && git commit -m "Update to X.Y.Z" && git push
```

### 7. Announce

- Once the AUR packages have had two clean releases, ask the CachyOS team to
  carry them; after that, tell the CachyOS packagers about each release.
- A short post with the release notes on the website. 1.0 is announced on the
  CachyOS forum, r/unixporn and the Arch forums' Community Contributions board.

## Later

- GitHub artifact attestations for the release files, once release CI exists.
- Before 1.0, re-run the USPTO and TMview searches for KFLUX (last run
  2026-10-19: no conflicting mark).
