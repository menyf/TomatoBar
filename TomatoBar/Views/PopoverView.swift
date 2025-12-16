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
                // When appearance is set to "Dark" and accent color is set to "Graphite"
                // "defaultAction" button label's color is set to the same color as the
                // button, making the button look blank. #24
                .foregroundColor(Color.white)
                .font(.system(.body).monospacedDigit())
                .background(Color.red)
                .frame(maxWidth: .infinity)
        }
        .onHover { over in
            buttonHovered = over
        }
        .controlSize(.large)
        .keyboardShortcut(.defaultAction)
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
                .foregroundColor(Color.white)
                .frame(maxWidth: .infinity)
        }
        .controlSize(.large)
        .keyboardShortcut(.defaultAction)
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
    }

    // MARK: - Footer

    private var footerButtons: some View {
        Group {
            Button {
                NSApp.activate(ignoringOtherApps: true)
                NSApp.orderFrontStandardAboutPanel()
            } label: {
                Text(NSLocalizedString("TBPopoverView.about.label", comment: "About label"))
                Spacer()
            }
            .buttonStyle(.plain)

            Button {
                NSApplication.shared.terminate(self)
            } label: {
                Text(NSLocalizedString("TBPopoverView.quit.label", comment: "Quit label"))
                Spacer()
                Text("\u{2318} Q").foregroundColor(Color.gray)
            }
            .buttonStyle(.plain)
            .keyboardShortcut("q")
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
