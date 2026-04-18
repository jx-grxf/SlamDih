#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="SlamDih"
VERSION="${1:-0.2.0}"
BUILD_NUMBER="${2:-${BUILD_NUMBER:-2}}"
BUILD_ROOT="$ROOT_DIR/.build/xcode-release"
DMG_ROOT="$ROOT_DIR/.build/dmg"
APP_PATH="$BUILD_ROOT/Release/$APP_NAME.app"
DMG_PATH="$DMG_ROOT/$APP_NAME-$VERSION.dmg"
CREATE_DMG_PACKAGE="${CREATE_DMG_PACKAGE:-create-dmg@8.1.0}"
CREATE_DMG_OUTPUT="$DMG_ROOT/$APP_NAME $VERSION.dmg"

if [[ -z "${DEVELOPER_DIR:-}" && -d /Applications/Xcode.app/Contents/Developer ]]; then
  export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
fi

rm -rf "$DMG_ROOT"
mkdir -p "$DMG_ROOT"

BUILD_ROOT="$BUILD_ROOT" "$ROOT_DIR/scripts/package-app.sh" "$VERSION" "$BUILD_NUMBER"

rm -f "$CREATE_DMG_OUTPUT" "$DMG_PATH"
npx --yes "$CREATE_DMG_PACKAGE" "$APP_PATH" "$DMG_ROOT" \
  --overwrite \
  --no-code-sign \
  --dmg-title="$APP_NAME $VERSION"

if [[ ! -f "$CREATE_DMG_OUTPUT" ]]; then
  echo "Expected create-dmg output not found at $CREATE_DMG_OUTPUT" >&2
  exit 1
fi

mv "$CREATE_DMG_OUTPUT" "$DMG_PATH"
hdiutil verify "$DMG_PATH"

shasum -a 256 "$DMG_PATH" > "$DMG_PATH.sha256"

echo "Created $DMG_PATH"
echo "Created $DMG_PATH.sha256"
echo "Note: this DMG is not notarized by this script. Treat ad-hoc builds as technical previews."
