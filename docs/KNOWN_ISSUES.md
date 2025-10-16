# Known Issues & Fixes

## Issue 1: "Nothing Happens" / Timeout

### Symptoms
- Console shows "Double Cmd+C detected" but no translation appears
- Popover doesn't show up
- Console shows "⚠️ No text captured from clipboard"

### Causes
1. **Text not copied fast enough** - Some apps (especially complex ones) need more time
2. **No text selected** - You pressed Cmd+C+C without selecting anything
3. **App doesn't support text selection** - Some UI elements can't be selected

### Fixes Applied
✅ Increased clipboard capture time from 50ms → 150ms
✅ Added detailed logging to track text capture
✅ Better error messages in console

### How to Use
1. **Select text clearly** - Make sure text is highlighted
2. **Wait a moment** after selection before pressing Cmd+C+C
3. **Try again** if it doesn't work the first time
4. **Check console** for "📋 Clipboard capture" message to see what was captured

### Workaround
If Cmd+C+C doesn't work:
1. Manually copy the text (Cmd+C once)
2. Open Hermes from menu bar
3. The text should already be captured

---

## Issue 2: Shows Original Text Instead of Translation

### Symptoms
- Translation appears but shows the SAME text as original
- Both "Japanese" and "English" sections show identical text
- Example: Japanese text appears in both boxes

### Causes
1. **Unclear prompt** - API didn't understand it should translate
2. **Wrong language detection** - Detected language incorrectly
3. **API repetition** - Gemini sometimes repeats input instead of translating

### Fixes Applied
✅ Improved prompt to explicitly state translation direction
✅ Better language detection (checks % of Japanese chars)
✅ Added "ONLY output translation" instruction
✅ Logs show detected language and direction

### How to Verify Fix
Check console after translation:
- Should see: **"🇯🇵 Detected Japanese text"** or **"🇺🇸 Detected English text"**
- Should see: **"🎯 Source: Japanese → Target: English"**
- Should see: **"✅ Translation received"** with different text

### What to Check
1. **API Key is valid** - Invalid keys can cause weird responses
2. **Internet connection** - Slow connections might timeout
3. **Text complexity** - Very long or complex text might confuse the model

---

## Debugging: What the Console Tells You

### Good Flow (Working):
```
Double Cmd+C detected - triggering translation
📋 Clipboard capture: 'STEP2完了後のHome画面のデザイン作成について'
🔄 Starting translation...
📝 Text to translate: 'STEP2完了後のHome画面のデザイン作成について'
✅ API key found
🇯🇵 Detected Japanese text (85% Japanese chars)
📥 API Response: {"candidates":[{"content":{"parts":[{"text":"About designing...
✅ Translation received: 'About designing the Home screen after completing STEP2'
🎯 Source: Japanese → Target: English
```

### Bad Flow (Not Working):
```
Double Cmd+C detected - triggering translation
⚠️ No text captured from clipboard  ← Problem: No text selected
```

OR

```
Double Cmd+C detected - triggering translation
📋 Clipboard capture: 'STEP2完了後のHome画面のデザイン作成について'
🔄 Starting translation...
❌ No API key configured  ← Problem: Missing API key
```

---

## Quick Fixes

### If Nothing Happens
1. ✅ Make sure text is selected (highlighted)
2. ✅ Try pressing Cmd+C+C again
3. ✅ Check console for "📋 Clipboard capture" message

### If Shows Original Text
1. ✅ Rebuild the app with new fixes:
   ```bash
   cd /Users/theja.stanley/Documents/my-project/Hermes
   ./build.sh
   ```
2. ✅ Check console for language detection messages
3. ✅ Try with clearer/shorter text first

### If Translation is Wrong
- **Expected**: Gemini is AI, translations won't always be perfect
- **Check**: Is the original text clear and well-formed?
- **Try**: Different model in Settings (Pro vs Flash)

---

## Performance Tips

### For Best Results
1. **Select clearly** - Highlight the text you want to translate
2. **Keep it reasonable** - Very long paragraphs might timeout
3. **Check connection** - Slow internet = slow translations
4. **Be patient** - First translation might take 2-3 seconds

### Model Selection
- **Gemini 2.0 Flash (Default)**: Fastest, good quality
- **Gemini 1.5 Flash**: Slightly slower, similar quality  
- **Gemini 1.5 Pro**: Slowest, highest quality

Change in: Settings → Model dropdown

---

## Success Indicators

### ✅ App is Working When:
- Console shows "✅ Accessibility permission granted!"
- Console shows "Global shortcut monitoring started"
- Settings shows "Monitoring Cmd+C+C shortcuts"
- Translations appear in popover
- Translations are DIFFERENT from original text

### ❌ App Has Issues When:
- Console shows "Cannot start monitoring"
- Settings shows "Shortcut monitoring disabled"
- Popover doesn't appear on Cmd+C+C
- Translations identical to original text
- Console shows "⚠️ No text captured"

---

## Getting Help

If issues persist after rebuild:

1. **Check console logs** - Look for error messages
2. **Verify setup**:
   - ✅ Accessibility permission granted
   - ✅ API key configured
   - ✅ App restarted after granting permission
3. **Test with simple text**: "Hello world"
4. **Check API key** validity at https://makersuite.google.com/

The app is working as expected for most cases - these improvements make it more reliable! 🎉
