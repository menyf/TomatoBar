// MARK: - SettingsView.swift
// General application settings including keyboard shortcuts,
// menu bar display options, and launch at login.

import KeyboardShortcuts
import LaunchAtLogin
import SwiftUI

extension KeyboardShortcuts.Name {
    static let startStopTimer = Self("startStopTimer")
}

struct SettingsView: View {
    @EnvironmentObject var timer: TBTimer
    @ObservedObject private var launchAtLogin = LaunchAtLogin.observable

    // MARK: - Body

    var body: some View {
        VStack {
            shortcutRecorder
            stopAfterBreakToggle
            showTimerToggle
            launchAtLoginToggle
        }
        .padding(4)
    }

    // MARK: - Subviews

    private var shortcutRecorder: some View {
        KeyboardShortcuts.Recorder(for: .startStopTimer) {
            Text(NSLocalizedString("SettingsView.shortcut.label",
                                   comment: "Shortcut label"))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var stopAfterBreakToggle: some View {
        Toggle(isOn: $timer.stopAfterBreak) {
            Text(NSLocalizedString("SettingsView.stopAfterBreak.label",
                                   comment: "Stop after break label"))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .toggleStyle(.switch)
    }

    private var showTimerToggle: some View {
        Toggle(isOn: $timer.showTimerInMenuBar) {
            Text(NSLocalizedString("SettingsView.showTimerInMenuBar.label",
                                   comment: "Show timer in menu bar label"))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .toggleStyle(.switch)
        .onChange(of: timer.showTimerInMenuBar) { _ in
            timer.updateTimeLeft()
        }
    }

    private var launchAtLoginToggle: some View {
        Toggle(isOn: $launchAtLogin.isEnabled) {
            Text(NSLocalizedString("SettingsView.launchAtLogin.label",
                                   comment: "Launch at login label"))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .toggleStyle(.switch)
    }
}
