# ✅ After Granting Accessibility Permission

## What You're Seeing

After checking the "HermesApp" box in Accessibility settings, you see:
- ✅ Green checkmark but says "Shortcut monitoring disabled"
- Console error: "Cannot start monitoring: no accessibility permission"

## Why This Happens

macOS requires apps to **restart** after accessibility permission is granted for the permission to take effect in the running app.

## 🔧 Solution: Restart Hermes

### Method 1: Quit and Relaunch (Recommended)
1. Right-click the Hermes icon in menu bar
2. Click "Quit Hermes"
3. Launch Hermes again from Applications
4. The green checkmark should now say: **"Monitoring Cmd+C+C shortcuts"** ✅

### Method 2: Force Quit
1. Press Cmd+Option+Esc
2. Select "HermesApp"
3. Click "Force Quit"
4. Relaunch the app

## ✅ How to Verify It's Working

After restarting, check the Settings:
- Open Hermes → Click Settings (gear icon)
- Look at "Global Shortcuts" section
- Should say: **"Monitoring Cmd+C+C shortcuts"** ✓

Or check the console in Xcode:
- Should see: **"✅ Accessibility permission granted! Starting monitoring..."**
- Should see: **"Global shortcut monitoring started"**

## 🧪 Test Translation

1. Open any app (Safari, Notes, Messages)
2. Select some English text: "Hello, how are you?"
3. Press **Cmd+C+C** (double-tap quickly)
4. Translation popover should appear!

## 🐛 If It Still Doesn't Work

**Check the permission is actually enabled:**
1. Open System Settings → Privacy & Security → Accessibility
2. Verify "HermesApp" has a ✓ checkmark
3. If not checked, enable it
4. Restart Hermes again

**Check the console for errors:**
- In Xcode, filter by "Hermes" or "monitoring"
- Look for error messages
- Should see "Starting monitoring..." not "Cannot start monitoring"

**Reset and try again:**
1. Remove HermesApp from Accessibility list
2. Quit Hermes completely
3. Launch Hermes
4. Click "Grant Permission" again
5. Enable in System Settings
6. Restart Hermes

## 📊 Status Messages

| Message | Meaning |
|---------|---------|
| "Monitoring Cmd+C+C shortcuts" | ✅ Working! Ready to translate |
| "Shortcut monitoring disabled" | ⚠️ Need to restart app |
| "Accessibility permission required" | ❌ Not granted in System Settings |

## 💡 Code Improvements Made

I've updated the code to:
- ✅ Auto-detect when permission is granted (checks every 2 seconds)
- ✅ Automatically start monitoring when permission detected
- ✅ Show clear status messages
- ✅ Better console logging for debugging

**Rebuild for these improvements:**
```bash
cd /Users/theja.stanley/Documents/my-project/Hermes
./build.sh
```

With the new build, the app will detect permission changes automatically and start monitoring without requiring a manual restart!
