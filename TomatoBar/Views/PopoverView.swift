// MARK: - PopoverView.swift
// Main popover view displayed when clicking the menu bar icon.
// Contains the timer control button, tab navigation, and child views.

import SwiftUI

// MARK: - ChildView

private enum ChildView {
    case tasks, intervals, settings, sounds
}

// MARK: - TBPopoverView

struct TBPopoverView: View {
    @ObservedObject var timer = TBTimer()
    @ObservedObject var taskManager = TBTaskManager()
    @State private var buttonHovered = false
    @State private var activeChildView = ChildView.tasks

    // MARK: - Localized Strings

    private let startLabel = NSLocalizedString("TBPopoverView.start.label", comment: "Start label")
    private let stopLabel = NSLocalizedString("TBPopoverView.stop.label", comment: "Stop label")
    private let startBreakLabel = NSLocalizedString("TBPopoverView.startBreak.label", comment: "Start break label")

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                timerButton
                if timer.pendingBreak {
                    startBreakButton
                }
            }
            tabPicker
            contentGroupBox
            footerButtons
        }
        #if DEBUG
        .overlay(
            GeometryReader { proxy in
                debugSize(proxy: proxy)
            }
        )
        #endif
        .padding(12)
    }

    // MARK: - Timer Controls

    private var timerButton: some View {
        Button {
            timer.startStop()
            TBStatusItem.shared.closePopover(nil)
        } label: {
            Text(timerButtonTitle)
                .font(.system(.body).monospacedDigit())
                .frame(maxWidth: .infinity)
        }
        .onHover { over in
            buttonHovered = over
        }
        .buttonStyle(PrimaryButtonStyle())
    }

    private var timerButtonTitle: String {
        if timer.timer != nil {
            return buttonHovered ? stopLabel : timer.timeLeftString
        }
        return startLabel
    }

    private var startBreakButton: some View {
        Button {
            timer.startBreak()
            TBStatusItem.shared.closePopover(nil)
        } label: {
            Text(startBreakLabel)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryButtonStyle())
    }

    // MARK: - Tab Navigation

    private var tabPicker: some View {
        Picker("", selection: $activeChildView) {
            Text(NSLocalizedString("TBPopoverView.tasks.label", comment: "Tasks label"))
                .tag(ChildView.tasks)
            Text(NSLocalizedString("TBPopoverView.intervals.label", comment: "Intervals label"))
                .tag(ChildView.intervals)
            Text(NSLocalizedString("TBPopoverView.settings.label", comment: "Settings label"))
                .tag(ChildView.settings)
            Text(NSLocalizedString("TBPopoverView.sounds.label", comment: "Sounds label"))
                .tag(ChildView.sounds)
        }
        .labelsHidden()
        .frame(maxWidth: .infinity)
        .pickerStyle(.segmented)
    }

    // MARK: - Content

    private var contentGroupBox: some View {
        GroupBox {
            switch activeChildView {
            case .intervals:
                IntervalsView().environmentObject(timer)
            case .settings:
                SettingsView().environmentObject(timer)
            case .sounds:
                SoundsView().environmentObject(timer.player)
            case .tasks:
                TasksView().environmentObject(taskManager)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Footer

    private var footerButtons: some View {
        VStack(spacing: 0) {
            Divider()
                .padding(.bottom, 8)

            MenuButton(
                title: NSLocalizedString("TBPopoverView.about.label", comment: "About label"),
                shortcut: nil
            ) {
                NSApp.activate(ignoringOtherApps: true)
                NSApp.orderFrontStandardAboutPanel()
            }

            MenuButton(
                title: NSLocalizedString("TBPopoverView.quit.label", comment: "Quit label"),
                shortcut: "Q"
            ) {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }
}

// MARK: - PrimaryButtonStyle

private struct PrimaryButtonStyle: ButtonStyle {
    @State private var isHovered = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(backgroundColor(isPressed: configuration.isPressed))
            )
            .onHover { hovering in
                isHovered = hovering
            }
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        if isPressed {
            return Color.red.opacity(0.7)
        } else if isHovered {
            return Color.red.opacity(0.85)
        } else {
            return Color.red
        }
    }
}

// MARK: - MenuButton

private struct MenuButton: View {
    let title: String
    let shortcut: String?
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                if let shortcut = shortcut {
                    Text("\u{2318}\(shortcut)")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isHovered ? Color.primary.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - Debug Helpers

#if DEBUG
func debugSize(proxy: GeometryProxy) -> some View {
    print("Optimal popover size:", proxy.size)
    return Color.clear
}
#endif
