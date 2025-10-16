import Foundation
import Carbon
import Cocoa

@MainActor
protocol GlobalShortcutMonitorDelegate: AnyObject {
    func didTriggerTranslation(with selectedText: String)
}

class GlobalShortcutMonitor: ObservableObject {
    static let shared = GlobalShortcutMonitor()
    
    weak var delegate: GlobalShortcutMonitorDelegate?
    
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var lastCopyTime: CFAbsoluteTime = 0
    private let doubleTapTimeInterval: CFAbsoluteTime = 0.5 // 500ms window for double-tap
    
    @Published var isMonitoring: Bool = false
    @Published var hasAccessibilityPermission: Bool = false
    
    private init() {
        checkAccessibilityPermission()
        
        // Periodically check for permission changes
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.checkAccessibilityPermission()
        }
    }
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - Public Interface
    
    func startMonitoring() {
        guard hasAccessibilityPermission else {
            print("Cannot start monitoring: no accessibility permission")
            return
        }
        
        guard !isMonitoring else {
            print("Already monitoring")
            return
        }
        
        setupEventTap()
    }
    
    func stopMonitoring() {
        guard isMonitoring else { return }
        
        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            self.runLoopSource = nil
        }
        
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            CFMachPortInvalidate(eventTap)
            self.eventTap = nil
        }
        
        DispatchQueue.main.async {
            self.isMonitoring = false
        }
    }
    
    func requestAccessibilityPermission() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        
        DispatchQueue.main.async {
            self.hasAccessibilityPermission = accessEnabled
            
            // If already granted, start monitoring immediately
            if accessEnabled && !self.isMonitoring {
                print("✅ Permission already granted, starting monitoring...")
                self.startMonitoring()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func checkAccessibilityPermission() {
        let accessEnabled = AXIsProcessTrusted()
        let previousState = self.hasAccessibilityPermission
        
        DispatchQueue.main.async {
            self.hasAccessibilityPermission = accessEnabled
            
            // If permission was just granted, start monitoring
            if !previousState && accessEnabled {
                print("✅ Accessibility permission granted! Starting monitoring...")
                self.startMonitoring()
            }
        }
    }
    
    private func setupEventTap() {
        let eventMask = (1 << CGEventType.keyDown.rawValue)
        
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) in
                let monitor = Unmanaged<GlobalShortcutMonitor>.fromOpaque(refcon!).takeUnretainedValue()
                return monitor.handleKeyEvent(proxy: proxy, type: type, event: event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )
        
        guard let eventTap = eventTap else {
            print("Failed to create event tap")
            return
        }
        
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        
        guard let runLoopSource = runLoopSource else {
            print("Failed to create run loop source")
            return
        }
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        
        DispatchQueue.main.async {
            self.isMonitoring = true
        }
        
        print("Global shortcut monitoring started")
    }
    
    private func handleKeyEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        guard type == .keyDown else {
            return Unmanaged.passUnretained(event)
        }
        
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let flags = event.flags
        
        // Check for Cmd+C (Command + C)
        // C key code is 8, Command flag is .maskCommand
        if keyCode == 8 && flags.contains(.maskCommand) {
            handleCmdCPress()
        }
        
        return Unmanaged.passUnretained(event)
    }
    
    private func handleCmdCPress() {
        let currentTime = CFAbsoluteTimeGetCurrent()
        
        if currentTime - lastCopyTime <= doubleTapTimeInterval {
            // Double Cmd+C detected!
            handleDoubleCommandC()
            lastCopyTime = 0 // Reset to prevent triple-tap
        } else {
            lastCopyTime = currentTime
        }
    }
    
    private func handleDoubleCommandC() {
        print("Double Cmd+C detected - triggering translation")
        
        // Get selected text using accessibility APIs
        DispatchQueue.global(qos: .userInitiated).async {
            if let selectedText = self.getSelectedText() {
                Task { @MainActor in
                    self.delegate?.didTriggerTranslation(with: selectedText)
                }
            }
        }
    }
    
    private func getSelectedText() -> String? {
        // Method 1: Try to get selected text via accessibility API
        if let text = getSelectedTextViaAccessibility() {
            return text
        }
        
        // Method 2: Fallback to simulating Cmd+C and reading clipboard
        return getSelectedTextViaClipboard()
    }
    
    private func getSelectedTextViaAccessibility() -> String? {
        guard let app = NSWorkspace.shared.frontmostApplication else { return nil }
        
        let appRef = AXUIElementCreateApplication(app.processIdentifier)
        var focusedElement: CFTypeRef?
        
        let result = AXUIElementCopyAttributeValue(appRef, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        
        guard result == .success,
              let element = focusedElement else {
            return nil
        }
        
        var selectedText: CFTypeRef?
        let textResult = AXUIElementCopyAttributeValue(element as! AXUIElement, kAXSelectedTextAttribute as CFString, &selectedText)
        
        if textResult == .success,
           let text = selectedText as? String,
           !text.isEmpty {
            return text
        }
        
        return nil
    }
    
    private func getSelectedTextViaClipboard() -> String? {
        // Save current clipboard
        let pasteboard = NSPasteboard.general
        let originalContents = pasteboard.string(forType: .string)
        
        // Clear clipboard
        pasteboard.clearContents()
        
        // Simulate Cmd+C
        let source = CGEventSource(stateID: .hidSystemState)
        
        let cmdCDown = CGEvent(keyboardEventSource: source, virtualKey: 8, keyDown: true)
        let cmdCUp = CGEvent(keyboardEventSource: source, virtualKey: 8, keyDown: false)
        
        cmdCDown?.flags = .maskCommand
        cmdCUp?.flags = .maskCommand
        
        cmdCDown?.post(tap: .cghidEventTap)
        cmdCUp?.post(tap: .cghidEventTap)
        
        // Wait longer for the copy operation to complete
        usleep(150000) // 150ms (increased from 50ms)
        
        // Get the copied text
        let copiedText = pasteboard.string(forType: .string)
        
        print("📋 Clipboard capture: '\(copiedText?.prefix(50) ?? "nil")'")
        
        // Restore original clipboard if we had something
        if let original = originalContents {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                pasteboard.clearContents()
                pasteboard.setString(original, forType: .string)
            }
        }
        
        let trimmed = copiedText?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed == nil || trimmed!.isEmpty {
            print("⚠️ No text captured from clipboard")
        }
        
        return trimmed
    }
}

// MARK: - Extensions

extension GlobalShortcutMonitor {
    var statusMessage: String {
        if !hasAccessibilityPermission {
            return "Accessibility permission required"
        } else if isMonitoring {
            return "Monitoring Cmd+C+C shortcuts"
        } else {
            return "Shortcut monitoring disabled"
        }
    }
}

