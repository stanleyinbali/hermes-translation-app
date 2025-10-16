import SwiftUI
import Cocoa

@main
struct HermesApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // Empty scene - the app runs entirely from the menu bar
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize the menu bar controller
        _ = MenuBarController.shared
        
        // Hide dock icon since this is a menu bar app
        NSApp.setActivationPolicy(.accessory)
        
        // Prevent the app from terminating when all windows are closed
        NSApp.setActivationPolicy(.accessory)
        
        print("Hermes Translation App launched")
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Clean up global shortcut monitoring
        GlobalShortcutMonitor.shared.stopMonitoring()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ app: NSApplication) -> Bool {
        // Don't terminate when closing windows - this is a menu bar app
        return false
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // Show the popover when clicking on the dock icon (if visible)
        if !flag {
            MenuBarController.shared.showPopover()
        }
        return true
    }
}

