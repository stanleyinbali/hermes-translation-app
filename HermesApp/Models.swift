import Foundation

// MARK: - Translation Models

enum Language: String, CaseIterable, Identifiable {
    case english = "en"
    case japanese = "ja"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English (American)"
        case .japanese: return "Japanese"
        }
    }
    
    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .japanese: return "🇯🇵"
        }
    }
}

struct TranslationRequest {
    let text: String
    let sourceLanguage: Language?
    let targetLanguage: Language?
    
    init(text: String, sourceLanguage: Language? = nil, targetLanguage: Language? = nil) {
        self.text = text
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
    }
}

struct TranslationResult {
    let originalText: String
    let translatedText: String
    let detectedLanguage: Language?
    let targetLanguage: Language
    let timestamp: Date
    
    init(originalText: String, translatedText: String, detectedLanguage: Language?, targetLanguage: Language) {
        self.originalText = originalText
        self.translatedText = translatedText
        self.detectedLanguage = detectedLanguage
        self.targetLanguage = targetLanguage
        self.timestamp = Date()
    }
}

// MARK: - Settings Models

struct AppSettings {
    var geminiAPIKey: String?
    var selectedModel: GeminiModel
    var globalShortcutEnabled: Bool
    var showNotifications: Bool
    var defaultSourceLanguage: Language?
    var defaultTargetLanguage: Language?
    
    init() {
        self.geminiAPIKey = nil
        self.selectedModel = .flashLite
        self.globalShortcutEnabled = true
        self.showNotifications = true
        self.defaultSourceLanguage = nil
        self.defaultTargetLanguage = nil
    }
}

enum GeminiModel: String, CaseIterable, Identifiable {
    case flashLite = "gemini-2.0-flash-lite"
    case flashPreview = "gemini-2.0-flash-exp"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .flashLite: return "Gemini 2.0 Flash-Lite"
        case .flashPreview: return "Gemini 2.0 Flash (Experimental)"
        }
    }
    
    var description: String {
        switch self {
        case .flashLite: return "Fast and efficient (Recommended)"
        case .flashPreview: return "Fastest, latest experimental model"
        }
    }
}

// MARK: - Error Types

enum TranslationError: Error, LocalizedError {
    case noAPIKey
    case invalidAPIKey
    case networkError(Error)
    case invalidResponse
    case textTooLong
    case rateLimitExceeded
    case serviceUnavailable
    
    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "No API key configured. Please add your Gemini API key in settings."
        case .invalidAPIKey:
            return "Invalid API key. Please check your Gemini API key in settings."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from translation service."
        case .textTooLong:
            return "Text is too long for translation."
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .serviceUnavailable:
            return "Translation service is temporarily unavailable."
        }
    }
}

// MARK: - UI State Models

@MainActor
class TranslationState: ObservableObject {
    @Published var isTranslating: Bool = false
    @Published var currentResult: TranslationResult?
    @Published var error: TranslationError?
    @Published var selectedText: String = ""
    
    init() {}
    
    func startTranslation(text: String) {
        self.selectedText = text
        self.isTranslating = true
        self.error = nil
    }
    
    func setResult(_ result: TranslationResult) {
        self.currentResult = result
        self.isTranslating = false
    }
    
    func setError(_ error: TranslationError) {
        self.error = error
        self.isTranslating = false
    }
    
    func reset() {
        self.selectedText = ""
        self.currentResult = nil
        self.error = nil
        self.isTranslating = false
    }
}

