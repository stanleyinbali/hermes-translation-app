import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()
    
    private let service = "com.hermes.HermesApp"
    
    private init() {}
    
    // MARK: - Public API
    
    func store(key: String, value: String) throws {
        let data = Data(value.utf8)
        
        // Delete existing item first
        try? delete(key: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            throw KeychainError.storeFailed(status)
        }
    }
    
    func retrieve(key: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecItemNotFound {
            return nil
        }
        
        if status != errSecSuccess {
            throw KeychainError.retrieveFailed(status)
        }
        
        guard let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }
        
        return string
    }
    
    func delete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.deleteFailed(status)
        }
    }
    
    func update(key: String, value: String) throws {
        let data = Data(value.utf8)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        if status == errSecItemNotFound {
            // Item doesn't exist, create it
            try store(key: key, value: value)
        } else if status != errSecSuccess {
            throw KeychainError.updateFailed(status)
        }
    }
}

// MARK: - Keychain Specific API

extension KeychainManager {
    enum Keys {
        static let geminiAPIKey = "gemini_api_key"
    }
    
    func storeGeminiAPIKey(_ key: String) throws {
        try store(key: Keys.geminiAPIKey, value: key)
    }
    
    func retrieveGeminiAPIKey() throws -> String? {
        return try retrieve(key: Keys.geminiAPIKey)
    }
    
    func deleteGeminiAPIKey() throws {
        try delete(key: Keys.geminiAPIKey)
    }
}

// MARK: - Error Types

enum KeychainError: Error, LocalizedError {
    case storeFailed(OSStatus)
    case retrieveFailed(OSStatus)
    case deleteFailed(OSStatus)
    case updateFailed(OSStatus)
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .storeFailed(let status):
            return "Failed to store item in keychain: \(status)"
        case .retrieveFailed(let status):
            return "Failed to retrieve item from keychain: \(status)"
        case .deleteFailed(let status):
            return "Failed to delete item from keychain: \(status)"
        case .updateFailed(let status):
            return "Failed to update item in keychain: \(status)"
        case .invalidData:
            return "Invalid data retrieved from keychain"
        }
    }
}

