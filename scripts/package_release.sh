#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="Drowzy"
VERSION="${VERSION:-$(tr -d '[:space:]' < "$ROOT/VERSION")}"
DIST_DIR="$ROOT/.build/dist"
ZIP_PATH="$DIST_DIR/$APP_NAME-$VERSION-macos.zip"

"$ROOT/scripts/build_app.sh"

mkdir -p "$DIST_DIR"
rm -f "$ZIP_PATH" "$ZIP_PATH.sha256"

ditto -c -k --sequesterRsrc --keepParent "$ROOT/.build/$APP_NAME.app" "$ZIP_PATH"
LC_ALL=C LANG=C shasum -a 256 "$ZIP_PATH" > "$ZIP_PATH.sha256"

echo "Packaged $ZIP_PATH"
echo "Checksum $ZIP_PATH.sha256"
