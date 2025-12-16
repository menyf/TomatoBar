// MARK: - App.swift
// SwiftUI application entry point for TomatoBar.
// Initializes the status bar item and configures app lifecycle.

import LaunchAtLogin
import SwiftUI

// MARK: - NSImage.Name Extensions

extension NSImage.Name {
    static let idle = Self("BarIconIdle")
    static let work = Self("BarIconWork")
    static let shortRest = Self("BarIconShortRest")
    static let longRest = Self("BarIconLongRest")
}

// MARK: - TBApp

@main
struct TBApp: App {
    @NSApplicationDelegateAdaptor(TBStatusItem.self) var appDelegate

    init() {
        TBStatusItem.shared = appDelegate
        LaunchAtLogin.migrateIfNeeded()
        logger.append(event: TBLogEventAppStart())
    }

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
