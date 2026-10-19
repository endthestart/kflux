#!/usr/bin/env bash
# Build a release-shaped tarball (kflux-VERSION/...) from the working tree,
# for local PKGBUILD tests before a real tagged release exists.
#   packaging/make-dist.sh [version] [outdir]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER="${1:-0.1.0}"
OUT="${2:-$ROOT/.cache/dist}"
mkdir -p "$OUT"
COPYFILE_DISABLE=1 tar -C "$ROOT" --no-xattrs \
  --exclude ./.cache --exclude ./vm --exclude ./screenshots --exclude ./third_party/fluxland \
  --exclude ./docs/upstream \
  --exclude '__pycache__' -s ",^\.,kflux-$VER," -czf "$OUT/kflux-$VER.tar.gz" \
  ./Makefile ./LICENSE ./LICENSES ./NOTICE.md ./README.md ./docs ./overlay \
  ./third_party/patches
echo "$OUT/kflux-$VER.tar.gz"
