#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="Drowzy"
TARGET_DIR="${TARGET_DIR:-/Applications}"
APP_BUNDLE="$ROOT/.build/$APP_NAME.app"

if [[ ! -d "$APP_BUNDLE" ]]; then
  "$ROOT/scripts/build_app.sh"
fi

ditto "$APP_BUNDLE" "$TARGET_DIR/$APP_NAME.app"
echo "Installed $APP_NAME to $TARGET_DIR."
