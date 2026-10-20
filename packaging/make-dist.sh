#!/usr/bin/env bash
# Build the release tarball kflux-VERSION.tar.gz with git archive, so the same
# tag always gives the same bytes (gzip -n, file times from the commit).
#   packaging/make-dist.sh VERSION [REF] [OUTDIR]
# REF defaults to the working tree (tracked and untracked, not ignored files),
# for testing the PKGBUILDs before a tag exists. For a release, pass vVERSION.
# Paths marked export-ignore in .gitattributes are left out.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER="${1:?usage: make-dist.sh VERSION [REF] [OUTDIR]}"
REF="${2:-}"
OUT="${3:-$ROOT/.cache/dist}"
mkdir -p "$OUT"
cd "$ROOT"
if [[ -n "$REF" ]]; then
  tree="$REF"
else
  idx="$(mktemp)"; trap 'rm -f "$idx"' EXIT
  cp .git/index "$idx"
  GIT_INDEX_FILE="$idx" git add -A
  tree="$(GIT_INDEX_FILE="$idx" git write-tree)"
fi
git archive --format=tar --prefix="kflux-$VER/" "$tree" | gzip -9n > "$OUT/kflux-$VER.tar.gz"
echo "$OUT/kflux-$VER.tar.gz"
