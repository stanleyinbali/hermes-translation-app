import SwiftUI

struct SettingsView: View {
    @Binding var isPresented: Bool
    
    @ObservedObject private var translationService = GeminiTranslationService.shared
    @ObservedObject private var shortcutMonitor = GlobalShortcutMonitor.shared
    
    @State private var apiKey: String = ""
    @AppStorage("selectedGeminiModel") private var selectedModel: String = GeminiModel.flashLite.rawValue
    @State private var showingAPIKeyField = false
    @State private var saveError: String?
    @State private var saveSuccess = false
    
    // Computed property to get the actual GeminiModel enum
    private var currentModel: GeminiModel {
        GeminiModel(rawValue: selectedModel) ?? .flashLite
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            headerView
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // API Configuration Section
                    apiConfigurationSection
                    
                    Divider()
                    
                    // Shortcut Configuration Section
                    shortcutConfigurationSection
                    
                    Divider()
                    
                    // About Section
                    aboutSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(width: 400, height: 350)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            loadCurrentSettings()
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: {
                isPresented = false
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.borderless)
            
            Text("Settings")
                .font(.headline)
                .fontWeight(.medium)
            
            Spacer()
            
            Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    private var apiConfigurationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Gemini API Configuration")
                .font(.title3)
                .fontWeight(.medium)
            
            // API Key field
            VStack(alignment: .leading, spacing: 6) {
                Text("API Key")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    if showingAPIKeyField {
                        SecureField("Enter your Gemini API key", text: $apiKey)
                            .textFieldStyle(.roundedBorder)
                    } else {
                        HStack {
                            Text(translationService.hasValidAPIKey() ? "••••••••••••••••" : "Not configured")
                                .foregroundColor(translationService.hasValidAPIKey() ? .primary : .secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(6)
                    }
                    
                    Button(showingAPIKeyField ? "Save" : "Edit") {
                        if showingAPIKeyField {
                            saveAPIKey()
                        } else {
                            showingAPIKeyField = true
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
                
                if showingAPIKeyField {
                    HStack {
                        Button("Cancel") {
                            showingAPIKeyField = false
                            apiKey = ""
                            saveError = nil
                        }
                        .buttonStyle(.borderless)
                        .controlSize(.small)
                        
                        Spacer()
                    }
                }
                
                Text("Get your free API key from Google AI Studio")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Model selection
            VStack(alignment: .leading, spacing: 6) {
                Text("Model")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Picker("Model", selection: $selectedModel) {
                    ForEach(GeminiModel.allCases) { model in
                        Text(model.displayName).tag(model.rawValue)
                    }
                }
                .pickerStyle(.menu)
                
                // Show description below the picker
                if let model = GeminiModel(rawValue: selectedModel) {
                    Text(model.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("Your selection is automatically saved")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Error/Success messages
            if let error = saveError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 4)
            }
            
            if saveSuccess {
                Text("Settings saved successfully")
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(.top, 4)
            }
        }
    }
    
    private var shortcutConfigurationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Global Shortcuts")
                .font(.title3)
                .fontWeight(.medium)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Cmd+C+C Translation")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("Double-tap Cmd+C to translate selected text")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: .constant(shortcutMonitor.hasAccessibilityPermission))
                        .disabled(true)
                }
                
                // Permission status
                HStack {
                    Image(systemName: shortcutMonitor.hasAccessibilityPermission ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .foregroundColor(shortcutMonitor.hasAccessibilityPermission ? .green : .orange)
                    
                    Text(shortcutMonitor.statusMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if !shortcutMonitor.hasAccessibilityPermission {
                        Button("Grant Permission") {
                            openSystemPreferences()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                }
            }
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About Hermes")
                .font(.title3)
                .fontWeight(.medium)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Version 1.0")
                    .font(.subheadline)
                
                Text("Fast bidirectional English-Japanese translation")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Link("Visit GitHub Repository", destination: URL(string: "https://github.com")!)
                    .font(.caption)
            }
        }
    }
    
    // MARK: - Actions
    
    private func openSystemPreferences() {
        // Request accessibility permission (shows system dialog)
        shortcutMonitor.requestAccessibilityPermission()
        
        // Open System Settings to Privacy & Security > Accessibility
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func loadCurrentSettings() {
        // Don't check keychain on view load to avoid permission prompt
        // The translationService.hasValidAPIKey() will check when needed
    }
    
    private func saveAPIKey() {
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            saveError = "API key cannot be empty"
            return
        }
        
        do {
            try translationService.setAPIKey(apiKey)
            showingAPIKeyField = false
            apiKey = ""
            saveError = nil
            saveSuccess = true
            
            // Hide success message after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                saveSuccess = false
            }
            
        } catch {
            saveError = "Failed to save API key: \(error.localizedDescription)"
        }
    }
}

