# Hermes App Icon Guide

## 🎨 Icon Design

The Hermes app icon features a modern, clean design that represents instant translation:

### Visual Elements
- **Background**: Modern blue gradient (#007AFF → #5AC8FA) following iOS design language
- **Main Symbol**: Clean white "H" letterform representing "Hermes"
- **Translation Indicators**: Orange dots (#FF9500) suggesting bidirectional translation
- **Style**: Rounded corners and modern typography following macOS design guidelines

### Icon Sizes Generated
All required macOS app icon sizes have been created:
- 16x16px (menu bar size)
- 32x32px (small icon)
- 64x64px (medium icon) 
- 128x128px (large icon)
- 256x256px (Retina medium)
- 512x512px (Retina large)
- 1024x1024px (App Store)

## 🔧 Generation Scripts

### Automatic Generation
```bash
# Generate all icon sizes
./create_icon.sh

# Or use Python version (requires Pillow)
python3 create_icon.py
```

### Enhanced Build
```bash
# Build app with fresh icons
./update_build.sh
```

## 📱 Menu Bar Icon

The menu bar uses a different icon approach:
- **Primary**: `textformat.abc.dottedunderline` SF Symbol (text formatting with underline)
- **Fallback**: "H⇄" text symbol showing translation direction
- **States**: 
  - Idle: Blue accent color
  - Translating: System blue with animation symbol
  - Error: Red with warning triangle

## 🎯 Design Philosophy

The icon design emphasizes:
1. **Clarity** - Recognizable at small sizes
2. **Purpose** - Clearly represents translation functionality
3. **Brand** - "H" for Hermes, the messenger god
4. **Modern** - Follows current macOS design trends
5. **Accessible** - High contrast and clear shapes

## 🔄 Updating Icons

To update the app icons:

1. Modify the generation scripts (`create_icon.py` or `create_icon.sh`)
2. Run the generation script to create new PNG files
3. The Xcode project will automatically use the new icons
4. Use `./update_build.sh` to build with the fresh icons

## 📂 File Structure

```
HermesApp/Assets.xcassets/AppIcon.appiconset/
├── Contents.json          # Icon metadata
├── hermes-16.png          # 16x16 icon
├── hermes-32.png          # 32x32 icon (@2x for 16x16)
├── hermes-32-1.png        # 32x32 icon (@1x)
├── hermes-64.png          # 64x64 icon (@2x for 32x32)
├── hermes-128.png         # 128x128 icon
├── hermes-256.png         # 256x256 icon (@2x for 128x128)
├── hermes-256-1.png       # 256x256 icon (@1x)
├── hermes-512.png         # 512x512 icon (@2x for 256x256)
├── hermes-512-1.png       # 512x512 icon (@1x)
└── hermes-1024.png        # 1024x1024 icon (@2x for 512x512)
```

The icons are ready for production use and App Store submission! 🚀
