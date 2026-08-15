#!/bin/zsh
set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
APP="$ROOT/ZhouYanDesktopPet.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
clang -arch arm64 -arch x86_64 "$ROOT/ZhouYanDesktopPet.m" -framework Cocoa -O -o "$APP/Contents/MacOS/ZhouYanDesktopPet"
cp "$ROOT/Info.plist" "$APP/Contents/Info.plist"
cp "$ROOT/spritesheet.png" "$APP/Contents/Resources/spritesheet.png"
codesign --force --deep --sign - "$APP" >/dev/null 2>&1 || true
echo "Built $APP"
