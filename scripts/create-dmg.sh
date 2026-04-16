#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="SlamDih"
VERSION="${1:-0.1.0}"
BUILD_ROOT="$ROOT_DIR/.build/xcode-release"
DMG_ROOT="$ROOT_DIR/.build/dmg"
STAGING_DIR="$DMG_ROOT/staging"
APP_PATH="$BUILD_ROOT/Release/$APP_NAME.app"
DMG_PATH="$DMG_ROOT/$APP_NAME-$VERSION.dmg"

if [[ -z "${DEVELOPER_DIR:-}" && -d /Applications/Xcode.app/Contents/Developer ]]; then
  export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
fi

rm -rf "$BUILD_ROOT" "$DMG_ROOT"
mkdir -p "$DMG_ROOT"

xcodebuild \
  -project "$ROOT_DIR/SlamDih.xcodeproj" \
  -scheme "$APP_NAME" \
  -configuration Release \
  -destination 'platform=macOS' \
  SYMROOT="$BUILD_ROOT" \
  CODE_SIGNING_ALLOWED=NO \
  build

if [[ ! -d "$APP_PATH" ]]; then
  echo "Expected app bundle not found at $APP_PATH" >&2
  exit 1
fi

codesign --force --deep --sign - "$APP_PATH"
codesign --verify --deep --strict "$APP_PATH"

mkdir -p "$STAGING_DIR"
ditto "$APP_PATH" "$STAGING_DIR/$APP_NAME.app"
ln -s /Applications "$STAGING_DIR/Applications"

hdiutil create \
  -volname "$APP_NAME $VERSION" \
  -srcfolder "$STAGING_DIR" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

shasum -a 256 "$DMG_PATH" > "$DMG_PATH.sha256"

echo "Created $DMG_PATH"
echo "Created $DMG_PATH.sha256"
