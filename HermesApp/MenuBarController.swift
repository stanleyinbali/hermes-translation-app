import SwiftUI
import Cocoa
import UserNotifications

@MainActor
public class MenuBarController: NSObject, ObservableObject {
    public static let shared = MenuBarController()
    
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    
    @Published var isPopoverShown: Bool = false
    @Published var translationState = TranslationState()
    
    private let translationService = GeminiTranslationService.shared
    private let shortcutMonitor = GlobalShortcutMonitor.shared
    
    private override init() {
        super.init()
        setupStatusItem()
        setupShortcutMonitor()
        setupTranslationService()
        setupNotificationAuthorization()
    }
    
    // MARK: - Setup Methods
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let statusItem = statusItem else {
            print("Failed to create status item")
            return
        }
        
        updateStatusItemIcon(state: .idle)
        
        if let button = statusItem.button {
            button.action = #selector(statusItemClicked)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }
    
    private func setupShortcutMonitor() {
        shortcutMonitor.delegate = self
        
        // Start monitoring if permission is already granted
        if shortcutMonitor.hasAccessibilityPermission {
            shortcutMonitor.startMonitoring()
        }
    }
    
    private func setupTranslationService() {
        // Don't load API key on launch to avoid keychain prompt
        // It will be loaded lazily when needed (when user opens settings or tries to translate)
    }
    
    private func setupNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            } else if !granted {
                print("User notifications not granted.")
            }
        }
    }
    
    // MARK: - Status Item Actions
    
    @objc private func statusItemClicked() {
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            togglePopover()
        }
    }
    
    private func togglePopover() {
        if isPopoverShown {
            hidePopover()
        } else {
            showPopover()
        }
    }
    
    @objc public func showPopover() {
        guard let statusButton = statusItem?.button else { return }
        
        if popover == nil {
            setupPopover()
        }
        
        guard let popover = popover else { return }
        
        if !popover.isShown {
            popover.show(relativeTo: statusButton.bounds, of: statusButton, preferredEdge: .minY)
            isPopoverShown = true
            
            // Activate the app to ensure popover gets focus
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    public func hidePopover() {
        popover?.performClose(nil)
        isPopoverShown = false
    }
    
    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 400, height: 300)
        popover?.behavior = .transient
        popover?.delegate = self
        
        let hostingController = NSHostingController(rootView: TranslationPopoverView().environmentObject(self))
        popover?.contentViewController = hostingController
    }
    
    private func showContextMenu() {
        let menu = NSMenu()
        
        // Translation status
        let statusMenuItem = NSMenuItem(
            title: translationState.isTranslating ? "Translating..." : "Ready for translation",
            action: nil,
            keyEquivalent: ""
        )
        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Show Translation Window
        let showItem = NSMenuItem(
            title: "Show Translation Window",
            action: #selector(showPopover),
            keyEquivalent: ""
        )
        showItem.target = self
        menu.addItem(showItem)
        
        // Settings
        let settingsItem = NSMenuItem(
            title: "Settings...",
            action: #selector(showSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Shortcut status
        let shortcutStatus = shortcutMonitor.statusMessage
        let shortcutItem = NSMenuItem(title: shortcutStatus, action: nil, keyEquivalent: "")
        shortcutItem.isEnabled = false
        menu.addItem(shortcutItem)
        
        if !shortcutMonitor.hasAccessibilityPermission {
            let permissionItem = NSMenuItem(
                title: "Grant Accessibility Permission",
                action: #selector(requestAccessibilityPermission),
                keyEquivalent: ""
            )
            permissionItem.target = self
            menu.addItem(permissionItem)
        }
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit
        let quitItem = NSMenuItem(
            title: "Quit Hermes",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)
        
        // Present the menu below the status bar item button
        if let button = self.statusItem?.button {
            menu.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.height + 3), in: button)
        }
    }
    
    @objc private func showSettings() {
        // Show settings in popover
        showPopover()
        // TODO: Switch to settings view in popover
    }
    
    @objc private func requestAccessibilityPermission() {
        shortcutMonitor.requestAccessibilityPermission()
    }
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
    
    // MARK: - Status Icon Management
    
    private enum StatusIconState {
        case idle
        case translating
        case error
    }
    
    private func updateStatusItemIcon(state: StatusIconState) {
        guard let button = statusItem?.button else { return }
        
        let systemName: String
        let tintColor: NSColor
        
        switch state {
        case .idle:
            systemName = "textformat.abc.dottedunderline"
            tintColor = .controlAccentColor
        case .translating:
            systemName = "arrow.triangle.2.circlepath"
            tintColor = .systemBlue
        case .error:
            systemName = "exclamationmark.triangle"
            tintColor = .systemRed
        }
        
        if let image = NSImage(systemSymbolName: systemName, accessibilityDescription: nil) {
            let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .medium)
            let configuredImage = image.withSymbolConfiguration(config)
            
            button.image = configuredImage
            button.image?.isTemplate = true
            button.contentTintColor = tintColor
        } else {
            // Fallback to text if SF Symbol not available
            button.title = "H⇄"
            button.contentTintColor = tintColor
        }
    }
    
    // MARK: - Translation Handling
    
    public func translateText(_ text: String) {
        Task { @MainActor in
            translationState.startTranslation(text: text)
            updateStatusItemIcon(state: .translating)
            
            do {
                let result = try await translationService.translate(text: text)
                translationState.setResult(result)
                updateStatusItemIcon(state: .idle)
                
                // Show popover with result if not already shown
                if !isPopoverShown {
                    showPopover()
                }
            } catch {
                let translationError = error as? TranslationError ?? TranslationError.networkError(error)
                translationState.setError(translationError)
                updateStatusItemIcon(state: .error)
                
                // Show error notification
                showErrorNotification(error: translationError)
            }
        }
    }
    
    private func showErrorNotification(error: TranslationError) {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Translation Error"
        content.body = error.localizedDescription
        content.sound = .default
        
        // Deliver immediately
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        center.add(request) { err in
            if let err = err {
                print("Failed to deliver notification: \(err)")
            }
        }
    }
}

// MARK: - GlobalShortcutMonitorDelegate

extension MenuBarController: GlobalShortcutMonitorDelegate {
    func didTriggerTranslation(with selectedText: String) {
        guard !selectedText.isEmpty else {
            print("No text selected for translation")
            return
        }
        
        print("Translating selected text: \(selectedText)")
        translateText(selectedText)
    }
}

// MARK: - NSPopoverDelegate

extension MenuBarController: NSPopoverDelegate {
    public func popoverDidClose(_ notification: Notification) {
        isPopoverShown = false
    }
    
    public func popoverShouldClose(_ popover: NSPopover) -> Bool {
        return true
    }
}
