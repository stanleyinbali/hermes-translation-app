# Hermes Distribution Guide

## 🎯 Package for Distribution

### Quick Command

```bash
./package.sh
```

This creates:
- ✅ `dist/Hermes-v1.0.zip` - Simple download
- ✅ `dist/Hermes-v1.0.dmg` - macOS installer  
- ✅ `dist/INSTALL.md` - User instructions
- ✅ `release/HermesApp.app` - Standalone app

---

## 📦 What Gets Created

### 1. ZIP Archive (Simplest)
**File**: `Hermes-v1.0.zip`
- Single compressed file
- ~2-5 MB size
- User extracts and drags to Applications
- **Best for**: Direct downloads, GitHub releases

### 2. DMG Installer (Professional)
**File**: `Hermes-v1.0.dmg`
- Disk image with app + Applications shortcut
- ~5-10 MB size
- User drags app to Applications folder
- **Best for**: Website downloads, polished distribution

### 3. Standalone App
**Folder**: `release/HermesApp.app`
- Uncompressed app bundle
- Ready to test locally
- **Best for**: Development testing

---

## 🚀 Distribution Methods

### Method 1: Direct Download (Easiest)

**Upload to your server/cloud:**
```bash
# Example with cloud storage
cp dist/Hermes-v1.0.dmg ~/Dropbox/Public/
cp dist/Hermes-v1.0.zip ~/Dropbox/Public/

# Get shareable link
# Users download and double-click
```

**Pros**: Simple, no account needed
**Cons**: No version management

---

### Method 2: GitHub Releases (Recommended)

1. **Create a release on GitHub:**
   ```bash
   git tag v1.0
   git push origin v1.0
   ```

2. **Upload files to release:**
   - Go to: `https://github.com/yourusername/hermes/releases`
   - Click "Draft a new release"
   - Choose tag: `v1.0`
   - Upload `Hermes-v1.0.dmg` and `Hermes-v1.0.zip`
   - Add release notes from `dist/INSTALL.md`
   - Click "Publish release"

3. **Users download from:**
   ```
   https://github.com/yourusername/hermes/releases/latest
   ```

**Pros**: Version control, automatic hosting, professional
**Cons**: Requires GitHub account

---

### Method 3: Self-Hosted Website

**Simple HTML page:**
```html
<!DOCTYPE html>
<html>
<head>
    <title>Hermes - Download</title>
</head>
<body>
    <h1>Hermes Translation App</h1>
    <p>Instant English-Japanese translation for macOS</p>
    
    <a href="Hermes-v1.0.dmg">Download DMG (Recommended)</a>
    <a href="Hermes-v1.0.zip">Download ZIP (Alternative)</a>
    
    <h2>Installation</h2>
    <ol>
        <li>Download the DMG or ZIP file</li>
        <li>Drag Hermes to Applications</li>
        <li>Launch and grant permissions</li>
        <li>Add your Gemini API key</li>
    </ol>
</body>
</html>
```

**Pros**: Full control, custom branding
**Cons**: Need hosting

---

## 🔒 Dealing with macOS Security

### The "App Can't Be Opened" Warning

Since the app is **not code-signed**, users will see:
> "HermesApp.app can't be opened because it is from an unidentified developer"

### Solutions for Users

**Option 1: Right-Click Method (Easiest)**
```
1. Right-click HermesApp.app
2. Click "Open"
3. Click "Open" in the dialog
```

**Option 2: Terminal Command**
```bash
xattr -cr /Applications/HermesApp.app
```

**Option 3: System Settings**
```
System Settings → Privacy & Security → 
Scroll down → Click "Open Anyway"
```

### Include This in Your Distribution

Add to README or website:
```markdown
⚠️ Security Note: Right-click the app and select "Open" on first launch.
This is normal for apps outside the Mac App Store.
```

---

## 💰 For Production Distribution

### If You Want to Avoid Security Warnings

**Enroll in Apple Developer Program ($99/year)**

Benefits:
- ✅ Code sign your app
- ✅ Notarize with Apple
- ✅ No security warnings
- ✅ Distribute via Mac App Store (optional)

**Steps:**
1. Join Apple Developer Program
2. Get Developer ID certificate
3. Code sign the app
4. Notarize with Apple
5. Distribute without warnings

**Update `package.sh` with:**
```bash
# Add your Developer ID
DEVELOPER_ID="Developer ID Application: Your Name (TEAM_ID)"

# Code sign
codesign --deep --force --verify --verbose \
    --sign "$DEVELOPER_ID" \
    "$RELEASE_APP"

# Notarize
xcrun notarytool submit "$DMG_PATH" \
    --apple-id "your@email.com" \
    --team-id "TEAM_ID" \
    --password "app-specific-password"
```

---

## 📝 Sample Distribution README

Create this as your download page description:

```markdown
# Hermes - Instant Translation for macOS

Fast bidirectional English-Japanese translation with a simple Cmd+C+C shortcut.

## Download

- [Download Hermes v1.0 (DMG)](Hermes-v1.0.dmg) - Recommended
- [Download Hermes v1.0 (ZIP)](Hermes-v1.0.zip) - Alternative

## Quick Start

1. **Download** the DMG or ZIP
2. **Drag** HermesApp to Applications folder
3. **Launch** and grant Accessibility permission
4. **Add** your Gemini API key (free from Google)
5. **Select text** and press **Cmd+C+C** to translate!

## First Launch

macOS may show a security warning. This is normal for apps outside the Mac App Store.

**Solution**: Right-click HermesApp.app → Click "Open" → Click "Open" again

## Requirements

- macOS 14.0+ (Sonoma)
- Gemini API key (free): https://makersuite.google.com/app/apikey

## Support

See the [Installation Guide](INSTALL.md) for detailed instructions.
```

---

## 🧪 Test Your Package

Before distributing:

```bash
# 1. Build the package
./package.sh

# 2. Test the ZIP
cd dist
unzip Hermes-v1.0.zip
open HermesApp.app

# 3. Test the DMG
open Hermes-v1.0.dmg
# Drag app to Applications in the mounted DMG
```

---

## 📊 File Size Reference

| File | Size | Description |
|------|------|-------------|
| `.app` bundle | ~3-5 MB | Uncompressed app |
| `.zip` archive | ~2-4 MB | Compressed for download |
| `.dmg` installer | ~4-8 MB | Disk image with installer UI |

---

## ✅ Distribution Checklist

Before sharing:

- [ ] Run `./package.sh` successfully
- [ ] Test the ZIP on a clean machine
- [ ] Test the DMG installation flow
- [ ] Verify app launches without crashes
- [ ] Test Cmd+C+C shortcut works
- [ ] Verify translations work with valid API key
- [ ] Include INSTALL.md instructions
- [ ] Document the security warning workaround
- [ ] Add version number to filename
- [ ] Create release notes

---

## 🎉 You're Ready!

Your app is now packaged and ready for distribution. Choose your method:

1. **Quick & Easy**: Upload ZIP to Dropbox/Google Drive
2. **Professional**: GitHub Releases with DMG
3. **Full Control**: Self-hosted with custom website

The `package.sh` script handles all the hard work - just run it and share the files!

For questions about code signing and notarization, see Apple's documentation:
https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution

