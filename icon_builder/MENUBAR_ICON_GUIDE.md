# Menu Bar Icon Customization Guide

## Current Icon Location

The menu bar icon is configured in:
```
HermesApp/MenuBarController.swift
Lines 220-228
```

## Current Configuration

The app uses an **SF Symbol** (Apple's system icon library):
```swift
systemName = "textformat.abc.dottedunderline"  // This shows as "Abc" with underline
```

---

## How to Change the Icon

### Option 1: Use a Different SF Symbol (Easiest)

Replace line 220 in `MenuBarController.swift`:

```swift
// Current:
systemName = "textformat.abc.dottedunderline"

// Try these alternatives:
systemName = "character.textbox"        // Text in box
systemName = "translate"                 // Translation icon
systemName = "text.bubble"              // Chat bubble
systemName = "character.book.closed"    // Book icon
systemName = "textformat"               // Simple text icon
systemName = "h.square"                 // Letter H in square (for Hermes!)
```

**Browse all SF Symbols:**
Download the free **SF Symbols app** from Apple:
https://developer.apple.com/sf-symbols/

---

### Option 2: Use a Custom Image (Recommended for Branding)

#### 1. Create Your Icon

**Requirements:**
- Format: PNG or PDF
- Size: **18x18 points** (36x36 pixels @2x for retina)
- Style: Monochrome (single color) works best for menu bar
- Background: Transparent

**Recommended tools:**
- Figma (web-based, free)
- Sketch (Mac app)
- Pixelmator Pro (Mac app)
- Adobe Illustrator

#### 2. Add Icon to Xcode

1. Open `HermesApp.xcodeproj` in Xcode
2. In the left sidebar, navigate to:
   ```
   HermesApp → Assets.xcassets
   ```
3. Right-click in the asset catalog
4. Select **"New Image Set"**
5. Rename it to **"MenuBarIcon"**
6. Drag your icon files:
   - `icon.png` → 1x slot
   - `icon@2x.png` → 2x slot (36x36px)
   - `icon@3x.png` → 3x slot (54x54px)

#### 3. Update MenuBarController.swift

Replace the icon loading code (lines 230-241):

**Current code:**
```swift
if let image = NSImage(systemSymbolName: systemName, accessibilityDescription: nil) {
    let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .medium)
    let configuredImage = image.withSymbolConfiguration(config)
    
    button.image = configuredImage
    button.image?.isTemplate = true
    button.contentTintColor = tintColor
} else {
    // Fallback to text if SF Symbol not available
    button.title = "H⇄"
    button.contentTintColor = tintColor
}
```

**Replace with:**
```swift
if let image = NSImage(named: "MenuBarIcon") {
    button.image = image
    button.image?.isTemplate = true  // Allows color tinting
    button.contentTintColor = tintColor
} else {
    // Fallback to SF Symbol
    if let symbolImage = NSImage(systemSymbolName: systemName, accessibilityDescription: nil) {
        let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        button.image = symbolImage.withSymbolConfiguration(config)
        button.image?.isTemplate = true
        button.contentTintColor = tintColor
    }
}
```

---

### Option 3: Text-Based Icon (Quick & Simple)

Replace lines 230-241 in `MenuBarController.swift`:

```swift
// Just use text - no image loading needed
button.title = "H⇄"  // or "翻" (Japanese kanji for translation)
button.contentTintColor = tintColor
```

**Other text ideas:**
- `"H"` - Simple H for Hermes
- `"⇄"` - Bidirectional arrow
- `"翻"` - Japanese translation kanji
- `"译"` - Chinese translation character
- `"En⇄日"` - English ↔ Japanese

---

## Quick Icon Suggestions

### For Hermes Theme:
```swift
systemName = "h.square.fill"           // Solid H icon
systemName = "message.badge.waveform"  // Communication theme
```

### For Translation Theme:
```swift
systemName = "translate"               // Official translation icon
systemName = "globe"                   // International
systemName = "text.bubble.rtl"        // Language bubble
```

### Minimalist:
```swift
systemName = "square.stack.3d.up"     // Abstract layers
systemName = "circle.grid.2x2"        // Simple grid
```

---

## Testing Your Changes

1. Open the project in Xcode
2. Make your changes to `MenuBarController.swift`
3. Build and run: **Cmd+R**
4. The new icon appears in your menu bar immediately!

---

## Pro Tips

### For Template Images (Best Practice):
- Use **monochrome** icons (single color + transparency)
- Set `image.isTemplate = true` so macOS automatically:
  - Inverts colors in Dark Mode
  - Matches system accent color
  - Adjusts for menu bar style

### For Full-Color Icons:
- Set `image.isTemplate = false`
- Icon will show your exact colors
- Won't adapt to Dark Mode automatically

### Size Recommendations:
- **18x18 pt** is standard for menu bar icons
- Use @2x (36x36px) and @3x (54x54px) for sharp retina display
- Add padding - don't fill entire 18x18 space
- Keep it simple - menu bar icons are tiny!

---

## Current Icon States

The app changes icon based on state:

| State | SF Symbol | Color |
|-------|-----------|-------|
| **Idle** | `textformat.abc.dottedunderline` | Accent Color |
| **Translating** | `arrow.triangle.2.circlepath` | Blue |
| **Error** | `exclamationmark.triangle` | Red |

If you use a custom image, consider creating 3 versions:
- `MenuBarIcon` (idle)
- `MenuBarIcon-Translating` (animated or different)
- `MenuBarIcon-Error` (alert style)

---

## Need Help?

1. **Browse SF Symbols**: Download the SF Symbols app
2. **Design tools**: Use Figma (free) or Sketch
3. **Icon resources**:
   - https://www.flaticon.com (free icons)
   - https://www.iconfinder.com
   - https://thenounproject.com

---

**Current location to edit:**
```
/Users/theja.stanley/Documents/my-project/Hermes/HermesApp/MenuBarController.swift
Line 220
```

