#!/bin/bash

# Hermes App Packaging Script
# Creates a distributable .app bundle and .dmg installer

set -e

echo "📦 Packaging Hermes Translation App for Distribution"
echo ""

# Configuration
APP_NAME="HermesApp"
DMG_NAME="Hermes-Installer"
VERSION="1.0"
BUILD_DIR="build"
RELEASE_DIR="release"
DIST_DIR="dist"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Clean previous builds
echo -e "${BLUE}🧹 Cleaning previous builds...${NC}"
rm -rf "$BUILD_DIR" "$RELEASE_DIR" "$DIST_DIR"
mkdir -p "$RELEASE_DIR" "$DIST_DIR"

# Generate icons if they don't exist
if [ ! -f "HermesApp/Assets.xcassets/AppIcon.appiconset/hermes-16.png" ]; then
    echo -e "${YELLOW}🎨 Generating app icons...${NC}"
    ./create_icon.sh
fi

# Build the app in Release configuration
echo -e "${BLUE}🔨 Building Release version...${NC}"
xcodebuild \
    -project "$APP_NAME.xcodeproj" \
    -scheme "$APP_NAME" \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    clean build \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

# Find the built app
APP_PATH=$(find "$BUILD_DIR" -name "*.app" -type d | head -1)

if [ -z "$APP_PATH" ]; then
    echo -e "${YELLOW}❌ Error: Could not find built app${NC}"
    exit 1
fi

echo -e "${GREEN}✅ App built successfully at: $APP_PATH${NC}"

# Copy app to release directory
echo -e "${BLUE}📋 Copying app to release directory...${NC}"
cp -R "$APP_PATH" "$RELEASE_DIR/"
RELEASE_APP="$RELEASE_DIR/$APP_NAME.app"

# Get app info
BUNDLE_ID=$(defaults read "$RELEASE_APP/Contents/Info.plist" CFBundleIdentifier 2>/dev/null || echo "com.hermes.HermesApp")
APP_VERSION=$(defaults read "$RELEASE_APP/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "$VERSION")

echo ""
echo -e "${GREEN}📱 App Information:${NC}"
echo "   Name: $APP_NAME"
echo "   Bundle ID: $BUNDLE_ID"
echo "   Version: $APP_VERSION"
echo "   Size: $(du -sh "$RELEASE_APP" | cut -f1)"
echo ""

# Create a simple distributable ZIP
echo -e "${BLUE}📦 Creating ZIP archive...${NC}"
cd "$RELEASE_DIR"
zip -r -q "../$DIST_DIR/Hermes-v${APP_VERSION}.zip" "$APP_NAME.app"
cd ..

ZIP_SIZE=$(du -sh "$DIST_DIR/Hermes-v${APP_VERSION}.zip" | cut -f1)
echo -e "${GREEN}✅ ZIP created: Hermes-v${APP_VERSION}.zip ($ZIP_SIZE)${NC}"

# Create DMG installer if hdiutil is available
if command -v hdiutil &> /dev/null; then
    echo -e "${BLUE}💿 Creating DMG installer...${NC}"
    
    # Create temporary directory for DMG contents
    DMG_TEMP="$BUILD_DIR/dmg_temp"
    mkdir -p "$DMG_TEMP"
    
    # Copy app to DMG temp
    cp -R "$RELEASE_APP" "$DMG_TEMP/"
    
    # Create Applications symlink
    ln -s /Applications "$DMG_TEMP/Applications"
    
    # Create README
    cat > "$DMG_TEMP/README.txt" << 'EOFREADME'
Hermes - Instant Translation for macOS
======================================

Installation:
1. Drag HermesApp.app to the Applications folder
2. Launch Hermes from Applications
3. Grant Accessibility permission when prompted
4. Add your Gemini API key in Settings

Usage:
- Press Cmd+C+C to translate selected text
- Get your API key: https://makersuite.google.com/app/apikey

Support: See TROUBLESHOOTING.md in the project folder
EOFREADME
    
    # Create temporary DMG
    echo -e "${BLUE}   Creating disk image...${NC}"
    hdiutil create -volname "Hermes Installer" \
        -srcfolder "$DMG_TEMP" \
        -ov -format UDZO \
        "$DIST_DIR/Hermes-v${APP_VERSION}.dmg" \
        > /dev/null 2>&1
    
    DMG_SIZE=$(du -sh "$DIST_DIR/Hermes-v${APP_VERSION}.dmg" | cut -f1)
    echo -e "${GREEN}✅ DMG created: Hermes-v${APP_VERSION}.dmg ($DMG_SIZE)${NC}"
    
    # Clean up temp
    rm -rf "$DMG_TEMP"
else
    echo -e "${YELLOW}⚠️  hdiutil not found, skipping DMG creation${NC}"
fi

# Create installation instructions
cat > "$DIST_DIR/INSTALL.md" << 'EOFINSTALL'
# Hermes Installation Guide

## Quick Install (Recommended)

### From DMG:
1. Open `Hermes-v1.0.dmg`
2. Drag `HermesApp.app` to `Applications` folder
3. Eject the DMG
4. Launch Hermes from Applications

### From ZIP:
1. Extract `Hermes-v1.0.zip`
2. Move `HermesApp.app` to `/Applications/`
3. Launch Hermes from Applications

## First Launch Setup

1. **Grant Accessibility Permission**
   - Click the Hermes menu bar icon
   - Click Settings (gear icon)
   - Click "Grant Permission"
   - Enable HermesApp in System Settings
   - Restart Hermes

2. **Add Your API Key**
   - Click Settings
   - Enter your Gemini API key
   - Click Save
   - Get key from: https://makersuite.google.com/app/apikey

3. **Test Translation**
   - Select any text
   - Press Cmd+C+C (double-tap)
   - Translation appears!

## System Requirements

- macOS 14.0 (Sonoma) or later
- Internet connection
- Gemini API key (free from Google)

## Troubleshooting

### "App can't be opened" Error
**macOS Gatekeeper Issue**

Solution 1 (Simple):
```bash
xattr -cr /Applications/HermesApp.app
```

Solution 2 (GUI):
1. Right-click HermesApp.app
2. Click "Open"
3. Click "Open" in the dialog

Solution 3 (System Settings):
1. System Settings → Privacy & Security
2. Scroll to bottom → Click "Open Anyway"
3. Enter password → Click "Open"

### Cmd+C+C Not Working
1. Verify Accessibility permission granted
2. Restart the app
3. Check Settings shows "Monitoring Cmd+C+C shortcuts"

### Translation Errors
1. Verify API key is correct
2. Check internet connection
3. See TROUBLESHOOTING.md for details

## Uninstall

1. Quit Hermes (right-click menu bar icon → Quit)
2. Delete `/Applications/HermesApp.app`
3. Optional: Remove keychain data:
   ```bash
   security delete-generic-password -s "com.hermes.HermesApp"
   ```

## Support

- Documentation: See project README.md
- Issues: Check KNOWN_ISSUES.md
- Updates: Rebuild from source

Enjoy instant translation! 🎉
EOFINSTALL

echo ""
echo -e "${GREEN}🎉 Packaging Complete!${NC}"
echo ""
echo -e "${BLUE}📦 Distribution Files:${NC}"
echo "   $DIST_DIR/Hermes-v${APP_VERSION}.zip"
if [ -f "$DIST_DIR/Hermes-v${APP_VERSION}.dmg" ]; then
    echo "   $DIST_DIR/Hermes-v${APP_VERSION}.dmg"
fi
echo "   $DIST_DIR/INSTALL.md"
echo ""
echo -e "${BLUE}📁 Release App:${NC}"
echo "   $RELEASE_APP"
echo ""

# Show distribution options
echo -e "${YELLOW}📤 Distribution Options:${NC}"
echo ""
echo "1. Share the ZIP/DMG file directly"
echo "   → Users download and drag to Applications"
echo ""
echo "2. Upload to GitHub Releases"
echo "   → Tag release with version v${APP_VERSION}"
echo "   → Upload both ZIP and DMG files"
echo ""
echo "3. Self-host on your website"
echo "   → Upload files to your server"
echo "   → Provide download links"
echo ""
echo -e "${GREEN}✅ Your app is ready for distribution!${NC}"
echo ""

# Show Gatekeeper warning
echo -e "${YELLOW}⚠️  Important: Gatekeeper Notice${NC}"
echo ""
echo "Since this app is not code-signed, users may see a security warning."
echo "Users can bypass this by:"
echo "  • Right-clicking the app and selecting 'Open'"
echo "  • Running: xattr -cr /Applications/HermesApp.app"
echo ""
echo "For production distribution, consider:"
echo "  • Enrolling in Apple Developer Program (\$99/year)"
echo "  • Code signing the app"
echo "  • Notarizing with Apple"
echo ""
