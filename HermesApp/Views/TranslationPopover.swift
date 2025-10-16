import SwiftUI

struct TranslationPopoverView: View {
    @ObservedObject private var menuBarController = MenuBarController.shared
    @ObservedObject private var translationService = GeminiTranslationService.shared
    @State private var selectedLanguage: Language = .english
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            if showingSettings {
                SettingsView(isPresented: $showingSettings)
            } else {
                translationView
            }
        }
        .frame(width: 400, height: 350)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private var translationView: some View {
        VStack(spacing: 0) {
            // Header with language selector and controls
            headerView
            
            Divider()
            
            // Content area
            contentView
            
            Divider()
            
            // Action buttons
            actionButtonsView
        }
    }
    
    private var headerView: some View {
        HStack {
            // Language selector (matching the UI design)
            Menu {
                ForEach(Language.allCases) { language in
                    Button(action: {
                        selectedLanguage = language
                    }) {
                        HStack {
                            Text(language.flag)
                            Text(language.displayName)
                            Spacer()
                            if selectedLanguage == language {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selectedLanguage.flag)
                    Text(selectedLanguage.displayName)
                        .fontWeight(.medium)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(6)
            }
            .menuStyle(.borderlessButton)
            
            Spacer()
            
            // Settings button
            Button(action: {
                showingSettings = true
            }) {
                Image(systemName: "gear")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.borderless)
            .help("Settings")
            
            // Close button (matching the X in the UI)
            Button(action: {
                MenuBarController.shared.hidePopover()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.borderless)
            .help("Close")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if menuBarController.translationState.isTranslating {
                    loadingView
                } else if let error = menuBarController.translationState.error {
                    errorView(error)
                } else if let result = menuBarController.translationState.currentResult {
                    translationResultView(result)
                } else if !menuBarController.translationState.selectedText.isEmpty {
                    waitingView
                } else {
                    emptyStateView
                }
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
                .scaleEffect(1.2)
            
            Text("Translating...")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(_ error: TranslationError) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Translation Error")
                .font(.system(size: 17, weight: .semibold))
            
            Text(error.localizedDescription)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if case .noAPIKey = error {
                Button("Add API Key") {
                    showingSettings = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func translationResultView(_ result: TranslationResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Only show translation result, not original text
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    if let detectedLang = result.detectedLanguage {
                        Text("\(detectedLang.flag) \(detectedLang.displayName)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(result.targetLanguage.flag) \(result.targetLanguage.displayName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.bottom, 4)
                
                // Translation result with larger font
                Text(result.translatedText)
                    .font(.system(size: 17, weight: .regular))
                    .lineSpacing(6)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(NSColor.windowBackgroundColor))
                    .cornerRadius(8)
            }
        }
    }
    
    private var waitingView: some View {
        VStack(spacing: 16) {
            Image(systemName: "text.cursor")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("Processing selection...")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "translate")
                .font(.system(size: 56))
                .foregroundColor(.secondary)
            
            Text("Ready to Translate")
                .font(.system(size: 20, weight: .semibold))
            
            VStack(spacing: 8) {
                Text("Select text and press Cmd+C+C")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                
                Text("or right-click and choose 'Translate with Hermes'")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            if !translationService.hasValidAPIKey() {
                Button("Setup API Key") {
                    showingSettings = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var actionButtonsView: some View {
        HStack(spacing: 12) {
            if let result = menuBarController.translationState.currentResult {
                // Copy button (matching the UI design)
                Button(action: {
                    copyToClipboard(result.translatedText)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 15))
                        Text("Copy")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                }
                .buttonStyle(.borderless)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                
                // Replace button (matching the UI design)
                Button(action: {
                    replaceSelectedText(with: result.translatedText)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 15))
                        Text("Replace")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                }
                .buttonStyle(.borderless)
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(8)
            } else {
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - Actions
    
    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        
        // Show brief feedback
        // TODO: Add subtle feedback animation
    }
    
    private func replaceSelectedText(with text: String) {
        // Copy translated text to clipboard
        copyToClipboard(text)
        
        // Simulate Cmd+V to paste
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let source = CGEventSource(stateID: .hidSystemState)
            let cmdVDown = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: true) // V key
            let cmdVUp = CGEvent(keyboardEventSource: source, virtualKey: 9, keyDown: false)
            
            cmdVDown?.flags = .maskCommand
            cmdVUp?.flags = .maskCommand
            
            cmdVDown?.post(tap: .cghidEventTap)
            cmdVUp?.post(tap: .cghidEventTap)
        }
        
        // Close popover after replacing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            MenuBarController.shared.hidePopover()
        }
    }
}

