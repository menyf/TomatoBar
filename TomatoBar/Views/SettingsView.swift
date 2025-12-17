// MARK: - SettingsView.swift
// General application settings including keyboard shortcuts,
// menu bar display options, and launch at login.
// Updated for macOS 26 Tahoe with Liquid Glass design.

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
        VStack(spacing: 8) {
            shortcutRow

            Divider()
                .padding(.vertical, 4)

            GlassToggleRow(
                icon: "clock",
                iconColor: .blue,
                label: NSLocalizedString("SettingsView.showTimerInMenuBar.label",
                                         comment: "Show timer in menu bar label"),
                isOn: $timer.showTimerInMenuBar
            )
            .onChange(of: timer.showTimerInMenuBar) { _ in
                timer.updateTimeLeft()
            }

            GlassToggleRow(
                icon: "power",
                iconColor: .green,
                label: NSLocalizedString("SettingsView.launchAtLogin.label",
                                         comment: "Launch at login label"),
                isOn: $launchAtLogin.isEnabled
            )

            Divider()
                .padding(.vertical, 4)

            GlassToggleRow(
                icon: "ant",
                iconColor: .red,
                label: NSLocalizedString("SettingsView.debugMode.label",
                                         comment: "Debug mode label"),
                isOn: $timer.debugMode
            )
        }
    }

    // MARK: - Subviews

    private var shortcutRow: some View {
        HStack(spacing: 8) {
            Image(systemName: "keyboard")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.purple)
                .frame(width: 16)

            Text(NSLocalizedString("SettingsView.shortcut.label",
                                   comment: "Shortcut label"))
                .font(.system(size: 12))
                .frame(maxWidth: .infinity, alignment: .leading)

            KeyboardShortcuts.Recorder(for: .startStopTimer)
                .controlSize(.small)
        }
    }
}

// MARK: - GlassToggleRow

private struct GlassToggleRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 16)

            Text(label)
                .font(.system(size: 12))
                .frame(maxWidth: .infinity, alignment: .leading)

            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .labelsHidden()
                .controlSize(.small)
        }
    }
}
