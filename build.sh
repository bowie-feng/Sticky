#!/bin/bash
set -euo pipefail

APP_NAME="Sticky"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$PROJECT_DIR/.build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
DIST_DIR="$PROJECT_DIR/dist"

# Parse arguments
DO_INSTALL=false
DO_DMG=false
DO_DIST=false

for arg in "$@"; do
    case "$arg" in
        --install) DO_INSTALL=true ;;
        --dmg)     DO_DMG=true ;;
        --dist)    DO_DIST=true ;;
    esac
done

echo "=== Building $APP_NAME ==="

# Compile with Swift Package Manager
cd "$PROJECT_DIR"
swift build -c release --arch arm64

# ------------------------------------------------------------------
# Create .app bundle
# ------------------------------------------------------------------
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

# ------------------------------------------------------------------
# Copy to /Applications
# ------------------------------------------------------------------
if $DO_INSTALL; then
    echo "=== Installing to /Applications ==="
    rm -rf "/Applications/$APP_NAME.app"
    cp -R "$APP_BUNDLE" "/Applications/"
    echo "Installed successfully."
fi

# ------------------------------------------------------------------
# Create distributable .app copy & .dmg
# ------------------------------------------------------------------
if $DO_DIST || $DO_DMG; then
    VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$APP_BUNDLE/Contents/Info.plist" 2>/dev/null || echo "1.0.0")
    DMG_NAME="${APP_NAME}-v${VERSION}"
    DMG_PATH="$DIST_DIR/$DMG_NAME.dmg"

    rm -rf "$DIST_DIR"
    mkdir -p "$DIST_DIR"

    # Copy a clean .app into dist/
    cp -R "$APP_BUNDLE" "$DIST_DIR/$APP_NAME.app"
    echo "=== .app copied to $DIST_DIR/$APP_NAME.app ==="
fi

if $DO_DMG; then
    echo "=== Creating DMG ==="

    # Create a temporary disk image to hold the .app + Applications symlink
    DMG_TMP="$DIST_DIR/.tmp.dmg"
    DMG_VOLNAME="$APP_NAME"

    # Calculate required size (app size + 2MB margin)
    APP_SIZE_KB=$(du -sk "$DIST_DIR/$APP_NAME.app" | cut -f1)
    DMG_SIZE=$((APP_SIZE_KB + 4096))

    # Create sparse image
    hdiutil create -size ${DMG_SIZE}k -volname "$DMG_VOLNAME" -fs HFS+ -srcfolder "$DIST_DIR/$APP_NAME.app" -format UDRW "$DMG_TMP" > /dev/null

    # Mount it
    DEVICE=$(hdiutil attach -readwrite -noverify -noautoopen "$DMG_TMP" | awk '/Apple_HFS/{print $1}')
    MOUNT="/Volumes/$DMG_VOLNAME"

    # Add Applications shortcut
    ln -s /Applications "$MOUNT/Applications"

    # Set icon positions (optional, makes it look nicer)
    if command -v osascript &> /dev/null; then
        osascript -e "
tell application \"Finder\"
    tell disk \"$DMG_VOLNAME\"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set bounds of container window to {200, 200, 600, 480}
        set theViewOptions to the icon view options of container window
        set arrangement of theViewOptions to not arranged
        set icon size of theViewOptions to 96
        set position of item \"$APP_NAME.app\" of container window to {120, 140}
        set position of item \"Applications\" of container window to {280, 140}
        close
    end tell
end tell" > /dev/null 2>&1 || true
    fi

    # Detach and convert to compressed read-only
    hdiutil detach "$DEVICE" > /dev/null
    hdiutil convert "$DMG_TMP" -format UDZO -imagekey zlib-level=9 -o "$DMG_PATH" > /dev/null
    rm -f "$DMG_TMP"

    echo "=== DMG created: $DMG_PATH ==="
fi

# ------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------
if $DO_DIST || $DO_DMG; then
    echo ""
    echo "=== 📦 Distribution ready ==="
    ls -lh "$DIST_DIR/"
    echo ""
    echo "Share the .dmg (or .app) from: $DIST_DIR"
fi
