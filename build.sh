#!/bin/bash
set -euo pipefail

APP_NAME="Sticky"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$PROJECT_DIR/.build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

echo "=== Building $APP_NAME ==="

# Compile with Swift Package Manager
cd "$PROJECT_DIR"
swift build -c release --arch arm64

# Create app bundle structure
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Copy binary
cp "$BUILD_DIR/arm64-apple-macosx/release/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/"

# Copy Info.plist
cp "$PROJECT_DIR/Info.plist" "$APP_BUNDLE/Contents/"

# Copy any additional resources (app icon, etc.)
if [ -d "$PROJECT_DIR/Resources" ]; then
    cp -R "$PROJECT_DIR/Resources/"* "$APP_BUNDLE/Contents/Resources/" 2>/dev/null || true
fi

echo "=== Build complete ==="
echo "App bundle: $APP_BUNDLE"

# Copy to /Applications
if [ "${1:-}" = "--install" ]; then
    echo "=== Installing to /Applications ==="
    rm -rf "/Applications/$APP_NAME.app"
    cp -R "$APP_BUNDLE" "/Applications/"
    echo "Installed successfully."
else
    echo "Run with --install to copy to /Applications"
fi
