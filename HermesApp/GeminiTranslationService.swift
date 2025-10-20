import Foundation

class GeminiTranslationService: ObservableObject {
    static let shared = GeminiTranslationService()
    
    private let session: URLSession
    private var apiKey: String?
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
        
        // Don't load API key immediately to avoid keychain prompt on launch
        // It will be loaded lazily when needed
    }
    
    // MARK: - API Key Management
    
    func setAPIKey(_ key: String) throws {
        try KeychainManager.shared.storeGeminiAPIKey(key)
        self.apiKey = key
    }
    
    func hasValidAPIKey() -> Bool {
        // Lazy load API key if not already loaded
        if apiKey == nil {
            loadAPIKey()
        }
        return apiKey != nil && !apiKey!.isEmpty
    }
    
    private func loadAPIKey() {
        do {
            self.apiKey = try KeychainManager.shared.retrieveGeminiAPIKey()
        } catch {
            print("Failed to load API key from keychain: \(error)")
        }
    }
    
    // MARK: - Translation API
    
    func translate(
        text: String,
        model: GeminiModel? = nil
    ) async throws -> TranslationResult {
        // Use the provided model or get from UserDefaults
        let selectedModel: GeminiModel
        if let model = model {
            selectedModel = model
        } else {
            let modelString = UserDefaults.standard.string(forKey: "selectedGeminiModel") ?? GeminiModel.flashLite.rawValue
            selectedModel = GeminiModel(rawValue: modelString) ?? .flashLite
        }
        
        print("🤖 Using model: \(selectedModel.displayName)")
        
        return try await translateWithModel(text: text, model: selectedModel)
    }
    
    private func translateWithModel(
        text: String,
        model: GeminiModel
    ) async throws -> TranslationResult {
        print("🔄 Starting translation...")
        print("📝 Text to translate: '\(text.prefix(100))'")
        
        // Lazy load API key if not already loaded
        if apiKey == nil {
            loadAPIKey()
        }
        
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            print("❌ No API key configured")
            throw TranslationError.noAPIKey
        }
        
        print("✅ API key found")
        
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("❌ Empty text provided")
            throw TranslationError.invalidResponse
        }
        
        // Construct API URL
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/\(model.rawValue):generateContent"
        guard var urlComponents = URLComponents(string: urlString) else {
            throw TranslationError.invalidResponse
        }
        
        urlComponents.queryItems = [URLQueryItem(name: "key", value: apiKey)]
        
        guard let url = urlComponents.url else {
            throw TranslationError.invalidResponse
        }
        
        // Prepare request payload
        let requestBody = GeminiRequest(
            contents: [
                GeminiContent(
                    parts: [GeminiPart(text: createPrompt(for: text))]
                )
            ],
            systemInstruction: GeminiContent(
                parts: [GeminiPart(text: "You are a professional, bidirectional English-Japanese translator. Respond only with the clean, translated text.")]
            ),
            generationConfig: GeminiGenerationConfig(temperature: 0.1)
        )
        
        // Create URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            throw TranslationError.invalidResponse
        }
        
        // Execute request with retry logic
        return try await performRequestWithRetry(request: request, originalText: text)
    }
    
    // MARK: - Private Methods
    
    private func createPrompt(for text: String) -> String {
        // Detect if the text is primarily Japanese
        let detectedLang = detectLanguage(in: text)
        
        let direction = detectedLang == .japanese ? "Japanese to English" : "English to Japanese"
        
        return """
        Translate the following text from \(direction). Provide ONLY the translated text, with absolutely no explanations, notes, or original text repeated.
        
        Text to translate: \"\"\"\(text)\"\"\"
        
        Remember: Output ONLY the translation, nothing else.
        """
    }
    
    private func performRequestWithRetry(
        request: URLRequest,
        originalText: String,
        retryCount: Int = 0,
        maxRetries: Int = 3
    ) async throws -> TranslationResult {
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw TranslationError.networkError(NSError(domain: "InvalidResponse", code: 0))
            }
            
            // Handle different HTTP status codes
            switch httpResponse.statusCode {
            case 200:
                return try parseResponse(data: data, originalText: originalText)
            case 401:
                throw TranslationError.invalidAPIKey
            case 429:
                if retryCount < maxRetries {
                    let delay = pow(2.0, Double(retryCount)) // Exponential backoff
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    return try await performRequestWithRetry(
                        request: request,
                        originalText: originalText,
                        retryCount: retryCount + 1,
                        maxRetries: maxRetries
                    )
                } else {
                    throw TranslationError.rateLimitExceeded
                }
            case 500...599:
                throw TranslationError.serviceUnavailable
            default:
                throw TranslationError.networkError(
                    NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: [
                        NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode)"
                    ])
                )
            }
        } catch let error as TranslationError {
            throw error
        } catch {
            if retryCount < maxRetries && shouldRetry(error: error) {
                let delay = pow(2.0, Double(retryCount))
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                return try await performRequestWithRetry(
                    request: request,
                    originalText: originalText,
                    retryCount: retryCount + 1,
                    maxRetries: maxRetries
                )
            } else {
                throw TranslationError.networkError(error)
            }
        }
    }
    
    private func shouldRetry(error: Error) -> Bool {
        // Retry on network errors but not on validation or API key errors
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut, .notConnectedToInternet, .networkConnectionLost:
                return true
            default:
                return false
            }
        }
        return false
    }
    
    private func parseResponse(data: Data, originalText: String) throws -> TranslationResult {
        do {
            // Log raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 API Response: \(responseString.prefix(200))")
            }
            
            let response = try JSONDecoder().decode(GeminiResponse.self, from: data)
            
            guard let candidate = response.candidates?.first,
                  let content = candidate.content,
                  let part = content.parts.first else {
                print("❌ Invalid response structure")
                throw TranslationError.invalidResponse
            }
            
            let translatedText = part.text
            let cleanTranslatedText = translatedText.trimmingCharacters(in: .whitespacesAndNewlines)
            
            print("✅ Translation received: '\(cleanTranslatedText.prefix(100))'")
            
            guard !cleanTranslatedText.isEmpty else {
                print("❌ Empty translation received")
                throw TranslationError.invalidResponse
            }
            
            // Language detection
            let detectedLanguage = detectLanguage(in: originalText)
            let targetLanguage: Language = detectedLanguage == .english ? .japanese : .english
            
            print("🎯 Source: \(detectedLanguage?.displayName ?? "Unknown") → Target: \(targetLanguage.displayName)")
            
            return TranslationResult(
                originalText: originalText,
                translatedText: cleanTranslatedText,
                detectedLanguage: detectedLanguage,
                targetLanguage: targetLanguage
            )
            
        } catch let decodingError as DecodingError {
            print("❌ JSON Decoding error: \(decodingError)")
            throw TranslationError.invalidResponse
        } catch {
            print("❌ Parse error: \(error)")
            throw TranslationError.networkError(error)
        }
    }
    
    private func detectLanguage(in text: String) -> Language? {
        // Check for Japanese characters (Hiragana, Katakana, Kanji)
        let japaneseRange = NSRange(location: 0, length: text.utf16.count)
        let japaneseRegex = try? NSRegularExpression(pattern: "[\\u3040-\\u309F\\u30A0-\\u30FF\\u4E00-\\u9FAF]")
        
        if let regex = japaneseRegex,
           regex.firstMatch(in: text, options: [], range: japaneseRange) != nil {
            // Calculate percentage of Japanese characters
            let japaneseCount = regex.numberOfMatches(in: text, options: [], range: japaneseRange)
            let totalChars = text.count
            let japanesePercentage = Double(japaneseCount) / Double(max(totalChars, 1))
            
            // If more than 10% Japanese characters, consider it Japanese
            if japanesePercentage > 0.1 {
                print("🇯🇵 Detected Japanese text (\(Int(japanesePercentage * 100))% Japanese chars)")
                return .japanese
            }
        }
        
        print("🇺🇸 Detected English text")
        return .english
    }
}

// MARK: - Gemini API Models

private struct GeminiRequest: Codable {
    let contents: [GeminiContent]
    let systemInstruction: GeminiContent?
    let generationConfig: GeminiGenerationConfig?
}

private struct GeminiContent: Codable {
    let parts: [GeminiPart]
}

private struct GeminiPart: Codable {
    let text: String
}

private struct GeminiGenerationConfig: Codable {
    let temperature: Double
}

private struct GeminiResponse: Codable {
    let candidates: [GeminiCandidate]?
}

private struct GeminiCandidate: Codable {
    let content: GeminiContent?
}

