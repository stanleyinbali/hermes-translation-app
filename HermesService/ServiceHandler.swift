import Foundation
import Cocoa

class ServiceHandler: NSObject {
    
    @objc func translateText(_ pboard: NSPasteboard, userData: String?, error: NSErrorPointer) {
        guard let string = pboard.string(forType: .string) else {
            print("No text found in pasteboard")
            return
        }
        
        let trimmedText = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            print("Empty text provided to service")
            return
        }
        
        print("Service received text for translation: \(trimmedText)")
        
        // Send the text to the main app for translation
        // We'll use a URL scheme to communicate with the main app
        let urlString = "hermes://translate?text=\(trimmedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - Service Registration

class ServiceProvider: NSObject {
    static let shared = ServiceProvider()
    private let serviceHandler = ServiceHandler()
    
    private override init() {
        super.init()
    }
    
    func registerService() {
        NSApp.servicesProvider = serviceHandler
        NSUpdateDynamicServices()
        print("Hermes service registered")
    }
}

