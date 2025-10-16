# Hermes App Troubleshooting Guide

## ✅ Issues Fixed

### 1. Grant Permission Button Not Working
**Problem**: Clicking "Grant Permission" button did nothing.

**Fix**: Updated the button to:
1. Request accessibility permission (triggers system dialog)
2. Open System Settings directly to Privacy & Security > Accessibility page

**How to Use**:
1. Click "Grant Permission" button in settings
2. System Settings will open to the Accessibility pane
3. Find "HermesApp" in the list and enable it
4. Restart the app for changes to take effect

### 2. Runtime Console Errors

#### Notification Authorization Error (FIXED)
**Before**: `Notification authorization error: Notifications are not allowed for this application`

**Fix**: 
- Added `NSUserNotificationAlertStyle` to Info.plist
- Implemented modern `UNUserNotificationCenter` API
- Added automatic authorization request

#### SwiftUI Recursion Warning (FIXED)
**Warning**: `It's not legal to call -layoutSubtreeIfNeeded on a view which is already being laid out`

**Fix**: Changed from `@StateObject` to `@ObservedObject` for shared singletons:
- `MenuBarController.shared`
- `GeminiTranslationService.shared`
- `GlobalShortcutMonitor.shared`

This prevents multiple instances and layout recursion issues.

## 🚀 How to Use Hermes

### First Time Setup

1. **Launch the App**
   - Find Hermes icon in your menu bar (top right)
   - Click the icon to open the popover

2. **Add API Key**
   - Click Settings (gear icon)
   - Enter your Gemini API key
   - Click "Save"

3. **Grant Accessibility Permission**
   - In Settings, click "Grant Permission"
   - System Settings will open
   - Enable "HermesApp" in Accessibility list
   - Restart Hermes

### Using Translation

**Method 1: Cmd+C+C (Primary)**
1. Select any text in any application
2. Press Cmd+C twice quickly (double-tap)
3. Translation appears in floating window
4. Click "Copy" or "Replace"

**Method 2: Context Menu (Backup)**
1. Select text
2. Right-click
3. Choose "Translate with Hermes" from Services menu

## 🐛 Common Issues

### "Nothing happens when I press Cmd+C+C"
**Cause**: Accessibility permission not granted

**Solution**:
1. Open Hermes Settings
2. Click "Grant Permission"
3. Enable HermesApp in System Settings
4. Restart the app

### "Translation failed" errors
**Causes**:
- No API key configured
- Invalid API key
- No internet connection
- API rate limit reached

**Solutions**:
1. Check API key in Settings
2. Verify internet connection
3. Wait a moment if rate limited

### App doesn't appear in menu bar
**Solutions**:
1. Check Activity Monitor - ensure HermesApp is running
2. Reset menu bar: `killall SystemUIServer`
3. Reinstall the app

### Popover closes immediately
**Cause**: macOS system issue

**Solution**: Click the menu bar icon again to reopen

## 🔧 Advanced Troubleshooting

### Check Accessibility Permission Manually
```bash
# Check if app has accessibility permission
sqlite3 /Library/Application\ Support/com.apple.TCC/TCC.db \
  "SELECT * FROM access WHERE service='kTCCServiceAccessibility'"
```

### Reset All Permissions
1. Open System Settings
2. Privacy & Security > Accessibility
3. Remove HermesApp from the list
4. Re-add by clicking "Grant Permission" in app

### View Console Logs
1. Open Console.app
2. Filter by "HermesApp" or "Hermes"
3. Check for error messages

### Clear App Cache
```bash
rm -rf ~/Library/Caches/com.hermes.HermesApp
rm -rf ~/Library/Application\ Support/HermesApp
```

## 📝 Remaining Known Issues

### Non-Critical Console Warnings
These warnings are normal macOS system messages and don't affect functionality:
- `CALocalDisplayUpdateBlock returned NO`
- `BSBlockSentinel:FBSWorkspaceScenesClient] failed!`
- `fopen failed for data file` (cache warming)

These are macOS system behaviors and can be safely ignored.

## 🆘 Getting Help

If you encounter issues not covered here:

1. **Check Console**: Open Console.app and filter for "Hermes"
2. **Verify Setup**: Ensure all permissions are granted
3. **Test API Key**: Try the key in a simple curl request
4. **Restart**: Quit and relaunch the app

## ✅ Success Checklist

Before reporting an issue, verify:
- [ ] Accessibility permission granted in System Settings
- [ ] API key entered and saved in Settings
- [ ] App shows in menu bar
- [ ] Internet connection active
- [ ] macOS 14+ (Sonoma or later)
- [ ] App restarted after granting permissions

Your Hermes translation app should now work perfectly! 🎉

## 🔐 Keychain Permission Dialog on Launch

### Why This Appears
When you first launch Hermes, macOS shows a keychain permission dialog:
> "HermesApp wants to use your confidential information stored in 'com.hermes.HermesApp' in your keychain."

This is a **normal macOS security feature** that appears when an app first accesses the keychain.

### What To Do
**Click "Always Allow"**

This will:
- Grant Hermes permission to securely store your API key
- Prevent the dialog from appearing again
- Is completely safe and normal for apps that use secure storage

### Why It's Safe
- Hermes only stores your Gemini API key in the keychain
- The keychain is macOS's secure password storage system
- No other apps can access Hermes's keychain data
- Your API key is encrypted by macOS

### Options Explained
- **Always Allow**: Recommended - Prevents future prompts
- **Allow**: Permits this one time only (will ask again)
- **Deny**: Blocks keychain access (app won't be able to save API key)

This is the same security dialog you see with password managers and other secure apps.
