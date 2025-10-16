# Hermes - Instant Translation for macOS

[![Release](https://img.shields.io/github/v/release/stanleyinbali/hermes-translation-app?style=for-the-badge&logo=github)](https://github.com/stanleyinbali/hermes-translation-app/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/stanleyinbali/hermes-translation-app/total?style=for-the-badge)](https://github.com/stanleyinbali/hermes-translation-app/releases)
[![License](https://img.shields.io/github/license/stanleyinbali/hermes-translation-app?style=for-the-badge)](LICENSE)

A powerful menu bar application that provides instant bidirectional English-Japanese translation using Google's Gemini AI. Build completely by Cursor

## 📥 Download

**[⬇️ Download Latest Release (v1.0.0)](https://github.com/stanleyinbali/hermes-translation-app/releases/latest)**

- **Hermes-v1.0.dmg** (390 KB) - Recommended
- **Hermes-v1.0.zip** (168 KB) - Alternative

## Features

- **Global Shortcut**: Press Cmd+C+C to instantly translate selected text
- **Context Menu**: Right-click selected text and choose "Translate with Hermes"
- **Floating UI**: Clean, modern interface matching macOS design guidelines
- **Secure Storage**: API keys are stored securely in macOS Keychain
- **Multiple Models**: Support for Gemini 2.0 Flash, 1.5 Flash, and 1.5 Pro
- **Smart Detection**: Automatically detects source language (English/Japanese)
- **Copy & Replace**: Instantly copy translations or replace selected text

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later for building
- Gemini API key from Google AI Studio

## Setup

### 1. Get a Gemini API Key

1. Visit [Google AI Studio](https://aistudio.google.com/api-keys)
2. Create API key and use in the app

### 2. Download ready build app OR Build the App yourself

Download the zip or dmg file from link above

OR

1. Open `HermesApp.xcodeproj` in Xcode
2. Set your development team in the project settings
3. Build and run the project (Cmd+R)

### 3. Configure the App

1. Click the Hermes icon in the menu bar
2. Click "Settings" or the gear icon
3. Enter your Gemini API key
4. Grant accessibility permissions when prompted

## Usage

### Global Shortcut Method (Primary)

1. Select any text in any application
2. Press Cmd+C+C quickly (double-tap)
3. The translation appears in a floating window
4. Click "Copy" or "Replace" to use the translation

### Context Menu Method (Backup)

1. Select text in any application
2. Right-click the selected text
3. Choose "Translate with Hermes" from the context menu
4. The translation appears in the floating window

## Permissions

The app requires the following permissions:

- **Accessibility**: To monitor global shortcuts and access selected text
- **Network**: To communicate with the Gemini API

## Architecture

The app consists of three main components:

### HermesApp (Main Application)
- Menu bar controller and UI management
- Global shortcut monitoring using Carbon APIs
- SwiftUI-based popover interface

### HermesCore (Shared Framework)
- Translation service with Gemini API integration
- Secure keychain management for API keys
- Data models and error handling

### HermesService (Service Extension)
- macOS Service for context menu integration
- Backup method for text translation

## Building from Source

### Prerequisites
- Xcode 15.0+
- macOS 14.0+ (Sonoma)
- Swift 5.9+

### Build Steps
```bash
# Clone the repository
git clone <repository-url>
cd hermes

# Open in Xcode
open HermesApp.xcodeproj

# Build and run (Cmd+R in Xcode)
```

## Configuration Files

### Main App Configuration
- `HermesApp/Info.plist` - Main app configuration
- `HermesApp/HermesApp.entitlements` - App permissions and entitlements

### Service Extension
- `HermesService/Info.plist` - Service configuration for context menu

## API Models Supported

- **Gemini 2.0 Flash (Experimental)** - Fastest, latest model (Recommended)
- **Gemini 1.5 Flash** - Fast and efficient
- **Gemini 1.5 Pro** - Most capable, slower

## Troubleshooting

### Global Shortcut Not Working
1. Check that accessibility permissions are granted in System Settings
2. Restart the app after granting permissions
3. Ensure no other apps are conflicting with the Cmd+C shortcut

### Translation Errors
1. Verify your API key is correctly entered
2. Check your internet connection
3. Ensure the selected text is not too long (max ~8000 characters)

### App Not Appearing in Menu Bar
1. Check that the app is running (look in Activity Monitor)
2. Reset menu bar items in System Settings
3. Try restarting the app

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Create a Pull Request

## Security

- API keys are stored securely in macOS Keychain
- No user data is transmitted except for translation requests
- All network requests use HTTPS
- The app runs with minimal permissions required

## Support

For issues and feature requests, please use the GitHub issue tracker.

