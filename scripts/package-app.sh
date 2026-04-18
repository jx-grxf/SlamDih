#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="SlamDih"
VERSION="${1:-0.2.0}"
BUILD_NUMBER="${2:-${BUILD_NUMBER:-2}}"
BUILD_ROOT="${BUILD_ROOT:-$ROOT_DIR/.build/xcode-release}"
APP_PATH="$BUILD_ROOT/Release/$APP_NAME.app"
CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY:--}"

if [[ -z "${DEVELOPER_DIR:-}" && -d /Applications/Xcode.app/Contents/Developer ]]; then
  export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
fi

rm -rf "$BUILD_ROOT"

xcodebuild \
  -project "$ROOT_DIR/SlamDih.xcodeproj" \
  -scheme "$APP_NAME" \
  -configuration Release \
  -destination 'platform=macOS' \
  SYMROOT="$BUILD_ROOT" \
  MARKETING_VERSION="$VERSION" \
  CURRENT_PROJECT_VERSION="$BUILD_NUMBER" \
  CODE_SIGNING_ALLOWED=NO \
  build

if [[ ! -d "$APP_PATH" ]]; then
  echo "Expected app bundle not found at $APP_PATH" >&2
  exit 1
fi

if [[ "$CODE_SIGN_IDENTITY" == "-" ]]; then
  codesign --force --deep --sign - "$APP_PATH"
else
  codesign --force --deep --options runtime --timestamp --sign "$CODE_SIGN_IDENTITY" "$APP_PATH"
fi

codesign --verify --deep --strict --verbose=2 "$APP_PATH"

echo "Created $APP_PATH"
