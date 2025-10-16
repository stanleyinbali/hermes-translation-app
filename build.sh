#!/bin/bash

# Hermes Translation App Build Script with Icons

set -e

echo "🚀 Building Hermes Translation App with custom icons..."

# Generate icons if they don't exist
if [ ! -f "HermesApp/Assets.xcassets/AppIcon.appiconset/hermes-16.png" ]; then
    echo "🎨 Generating app icons..."
    ./create_icon.sh
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode command line tools not found. Please install Xcode."
    exit 1
fi

# Project settings
PROJECT_NAME="HermesApp"
SCHEME="HermesApp"
CONFIGURATION="Release"
BUILD_DIR="build"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Build the app
echo "🔨 Building $PROJECT_NAME..."
xcodebuild \
    -project "$PROJECT_NAME.xcodeproj" \
    -scheme "$SCHEME" \
    -configuration "$Configuration" \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    build

echo "✅ Build completed successfully!"

# Find the built app
APP_PATH=$(find "$BUILD_DIR" -name "*.app" -type d | head -1)

if [ -n "$APP_PATH" ]; then
    echo "📱 App built at: $APP_PATH"
    
    # Code signing check
    echo "🔒 Checking code signing..."
    if codesign -v "$APP_PATH" 2>/dev/null; then
        echo "✅ Code signing verified"
    else
        echo "⚠️  Warning: Code signing not verified. You may need to sign the app for distribution."
    fi
    
    # App info
    echo "ℹ️  App Information:"
    echo "   Bundle ID: $(defaults read "$APP_PATH/Contents/Info.plist" CFBundleIdentifier 2>/dev/null || echo "Not found")"
    echo "   Version: $(defaults read "$APP_PATH/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "Not found")"
    
else
    echo "❌ Could not find built app"
    exit 1
fi

echo ""
echo "🎉 Build completed! You can now:"
echo "   • Run the app directly: open \"$APP_PATH\""
echo "   • Copy to Applications: cp -R \"$APP_PATH\" /Applications/"
echo "   • Create a DMG for distribution"
echo ""

