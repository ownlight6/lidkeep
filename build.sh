#!/bin/bash
# Builds LidKeep.app as a universal binary (Intel + Apple silicon), macOS 12+.
# Requires only the Xcode Command Line Tools: xcode-select --install
set -euo pipefail

APP="LidKeep.app"
BUILD="build"
DEPLOY_TARGET="12.0"
# 版本号默认 1.0.0，CI 中可用 APP_VERSION 环境变量覆盖（如：APP_VERSION=1.0.1 ./build.sh）
VERSION="${APP_VERSION:-1.0.0}"

rm -rf "$BUILD" "$APP"
mkdir -p "$BUILD" "$APP/Contents/MacOS"

for arch in arm64 x86_64; do
    swiftc -O \
        -target "${arch}-apple-macos${DEPLOY_TARGET}" \
        -o "$BUILD/LidKeep-$arch" \
        LidKeep.swift
done

lipo -create "$BUILD/LidKeep-arm64" "$BUILD/LidKeep-x86_64" \
     -output "$APP/Contents/MacOS/LidKeep"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key><string>LidKeep</string>
    <key>CFBundleDisplayName</key><string>LidKeep</string>
    <key>CFBundleIdentifier</key><string>com.ownlight6.lidkeep</string>
    <key>CFBundleVersion</key><string>${VERSION}</string>
    <key>CFBundleShortVersionString</key><string>${VERSION}</string>
    <key>CFBundleExecutable</key><string>LidKeep</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>LSMinimumSystemVersion</key><string>${DEPLOY_TARGET}</string>
    <key>LSUIElement</key><true/>
</dict>
</plist>
PLIST

codesign --force --deep --sign - "$APP"
rm -rf "$BUILD"

echo "Built $APP"
lipo -archs "$APP/Contents/MacOS/LidKeep"

# Package for distribution. ditto preserves the bundle structure that a plain
# `zip` would flatten.
rm -f LidKeep.zip
ditto -c -k --sequesterRsrc --keepParent "$APP" LidKeep.zip
echo "Packaged LidKeep.zip"