#!/usr/bin/env bash
# Packages dist/Meridian.app into dist/Meridian-<version>.dmg with an Applications shortcut.
# Notarizes it when NOTARY_APPLE_ID / NOTARY_PASSWORD / NOTARY_TEAM_ID are set.
set -euo pipefail
cd "$(dirname "$0")/.."

VERSION="${1:-${VERSION:-0.1.0}}"
VERSION="${VERSION#v}"
DMG="dist/Meridian-$VERSION.dmg"
STAGE="$(mktemp -d)/Meridian"

mkdir -p "$STAGE"
cp -R dist/Meridian.app "$STAGE/"
ln -s /Applications "$STAGE/Applications"
rm -f "$DMG"
hdiutil create -volname "Meridian $VERSION" -srcfolder "$STAGE" -ov -format UDZO "$DMG"

if [[ -n "${CODESIGN_IDENTITY:-}" && "${CODESIGN_IDENTITY}" != "-" ]]; then
  codesign --sign "$CODESIGN_IDENTITY" --timestamp "$DMG"
fi

if [[ -n "${NOTARY_APPLE_ID:-}" && -n "${NOTARY_PASSWORD:-}" && -n "${NOTARY_TEAM_ID:-}" ]]; then
  xcrun notarytool submit "$DMG" --apple-id "$NOTARY_APPLE_ID" --password "$NOTARY_PASSWORD" \
    --team-id "$NOTARY_TEAM_ID" --wait
  xcrun stapler staple "$DMG"
fi

shasum -a 256 "$DMG" | tee "$DMG.sha256"
echo "Packaged $DMG"
