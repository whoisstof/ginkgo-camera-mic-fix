#!/usr/bin/env bash
# Build the flashable Magisk module zip.
set -euo pipefail
cd "$(dirname "$0")/.."

command -v zip >/dev/null || { echo "zip is required" >&2; exit 1; }

OUT="dist/camera-fix-ginkgo.zip"
mkdir -p dist
rm -f "$OUT"

(cd module && zip -r9 "../$OUT" . -x '.*' >/dev/null)

echo "Built $OUT"
unzip -l "$OUT"
