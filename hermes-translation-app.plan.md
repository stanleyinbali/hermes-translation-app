<!-- 38397c75-0808-4a9f-b805-83c44422e8cf 4fe855de-d383-4d14-8dda-5d3624c51453 -->
# Hermes macOS Translation App

## Project Structure

Create a complete Xcode project with multiple targets:

- **Main App**: Menu bar application (`HermesApp.swift`)
- **Service Extension**: macOS Service for context menu integration (`HermesService`)
- **Shared Framework**: Common models and utilities (`HermesCore`)

## Core Components

### 1. Xcode Project Setup

- Create new macOS app project targeting macOS 14+
- Configure app bundle identifiers and entitlements
- Set up Service extension target with proper Info.plist configuration
- Configure accessibility and input monitoring permissions

### 2. Global Shortcut Monitoring (Primary Method)

- Implement `GlobalShortcutMonitor` class using Carbon/Cocoa APIs
- Monitor Cmd+C keystrokes globally with timing detection for double-tap
- Request accessibility permissions for global event monitoring
- Handle text capture from selected content across applications

### 3. Menu Bar Application Core

- Create persistent menu bar app using `NSStatusItem`
- Implement SwiftUI-based popover matching the UI design
- Manage app lifecycle and background operation
- Handle status item icon states (idle, translating, error)

### 4. Translation Engine Integration

- Port the JavaScript logic from `TranslateLogic` to Swift
- Implement `GeminiTranslationService` with URLSession
- Use gemini-2.5-flash-preview-05-20 model as specified
- Add error handling and retry logic with exponential backoff

### 5. Settings & API Key Management

- Create in-app settings view with SwiftUI
- Implement secure keychain storage for Gemini API key
- Add model selection dropdown (with flash-preview as default)
- Include global shortcut override options

### 6. UI Implementation

- Recreate the floating popover design from the provided image
- Language detection indicator (English/Japanese dropdown)
- Copy and Replace button functionality
- Smooth animations and proper positioning near selected text

### 7. macOS Service Extension (Backup Method)

- Create Service extension for "Translate with Hermes" context menu
- Configure service to accept plain text input
- Bridge service calls to main app via URL schemes or shared container

## Key Files to Create

- `HermesApp/HermesApp.swift` - Main app entry point
- `HermesApp/MenuBarController.swift` - Status item management
- `HermesApp/GlobalShortcutMonitor.swift` - Cmd+C+C detection
- `HermesApp/Views/TranslationPopover.swift` - Main UI popover
- `HermesApp/Views/SettingsView.swift` - App settings interface
- `HermesCore/GeminiTranslationService.swift` - API integration
- `HermesCore/Models.swift` - Data structures
- `HermesCore/KeychainManager.swift` - Secure storage
- `HermesService/ServiceHandler.swift` - Service extension logic

## Technical Implementation Notes

- Use modern SwiftUI with iOS 17+ / macOS 14+ APIs
- Implement proper accessibility permission requests
- Handle app sandboxing limitations for global shortcuts
- Add comprehensive error handling for network and system failures
- Include proper app notarization and code signing setup

### To-dos

- [x] Create Xcode project with main app, service extension, and shared framework targets
- [x] Configure entitlements and Info.plist for accessibility and input monitoring permissions
- [x] Implement GlobalShortcutMonitor class for Cmd+C+C detection using Carbon APIs
- [x] Create menu bar application core with NSStatusItem and lifecycle management
- [x] Port TranslateLogic to Swift and implement GeminiTranslationService with URLSession
- [x] Build SwiftUI popover interface matching the provided UI design
- [x] Implement settings view and keychain manager for secure API key storage
- [x] Create macOS Service extension for context menu integration as backup method

