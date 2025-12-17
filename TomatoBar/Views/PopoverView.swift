// MARK: - PopoverView.swift
// Main popover view displayed when clicking the menu bar icon.
// Contains the timer control button, tab navigation, and child views.
// Updated for macOS 26 Tahoe with Liquid Glass design.

import SwiftUI

// MARK: - ChildView

private enum ChildView: CaseIterable {
    case tasks, intervals, settings, sounds

    var label: String {
        switch self {
        case .tasks:
            return NSLocalizedString("TBPopoverView.tasks.label", comment: "Tasks label")
        case .intervals:
            return NSLocalizedString("TBPopoverView.intervals.label", comment: "Intervals label")
        case .settings:
            return NSLocalizedString("TBPopoverView.settings.label", comment: "Settings label")
        case .sounds:
            return NSLocalizedString("TBPopoverView.sounds.label", comment: "Sounds label")
        }
    }

    var icon: String {
        switch self {
        case .tasks:
            return "checklist"
        case .intervals:
            return "timer"
        case .settings:
            return "gearshape"
        case .sounds:
            return "speaker.wave.2"
        }
    }
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
        VStack(alignment: .leading, spacing: 12) {
            timerControls
            tabNavigation
            contentArea
            footerButtons
        }
        #if DEBUG
        .overlay(
            GeometryReader { proxy in
                debugSize(proxy: proxy)
            }
        )
        #endif
        .padding(16)
    }

    // MARK: - Timer Controls

    private var timerControls: some View {
        HStack(spacing: 10) {
            timerButton
            if timer.pendingBreak {
                startBreakButton
            }
        }
    }

    private var timerButton: some View {
        Button {
            timer.startStop()
            TBStatusItem.shared.closePopover(nil)
        } label: {
            Text(timerButtonTitle)
                .font(.system(.body, design: .rounded).monospacedDigit())
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
        }
        .onHover { over in
            buttonHovered = over
        }
        .buttonStyle(timer.isResting ? AnyButtonStyle(GlassGreenButtonStyle()) : AnyButtonStyle(GlassPrimaryButtonStyle()))
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
                .font(.system(.body, design: .rounded))
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(GlassGreenButtonStyle())
    }

    // MARK: - Tab Navigation

    private var tabNavigation: some View {
        HStack(spacing: 6) {
            ForEach(ChildView.allCases, id: \.self) { tab in
                GlassTabButton(
                    icon: tab.icon,
                    label: tab.label,
                    isSelected: activeChildView == tab
                ) {
                    activeChildView = tab
                }
            }
        }
    }

    // MARK: - Content

    private var contentArea: some View {
        VStack {
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
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.primary.opacity(0.05))
        )
        .fixedSize(horizontal: false, vertical: true)
        .transaction { transaction in
            transaction.animation = nil
        }
    }

    // MARK: - Footer

    private var footerButtons: some View {
        VStack(spacing: 4) {
            GlassMenuButton(
                title: NSLocalizedString("TBPopoverView.about.label", comment: "About label"),
                icon: "info.circle",
                shortcut: nil
            ) {
                NSApp.activate(ignoringOtherApps: true)
                NSApp.orderFrontStandardAboutPanel()
            }

            GlassMenuButton(
                title: NSLocalizedString("TBPopoverView.quit.label", comment: "Quit label"),
                icon: "power",
                shortcut: "Q"
            ) {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }
}

// MARK: - AnyButtonStyle

private struct AnyButtonStyle: ButtonStyle {
    private let _makeBody: (Configuration) -> AnyView

    init<S: ButtonStyle>(_ style: S) {
        _makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        _makeBody(configuration)
    }
}

// MARK: - GlassPrimaryButtonStyle

private struct GlassPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        GlassPrimaryButtonContent(configuration: configuration)
    }
}

private struct GlassPrimaryButtonContent: View {
    let configuration: ButtonStyleConfiguration
    @State private var isHovered = false

    var body: some View {
        configuration.label
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(backgroundColor)
                    .shadow(color: .red.opacity(0.3), radius: isHovered ? 8 : 4, y: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
            .onHover { hovering in
                isHovered = hovering
            }
    }

    private var backgroundColor: Color {
        if configuration.isPressed {
            return Color.red.opacity(0.8)
        } else if isHovered {
            return Color.red.opacity(0.9)
        } else {
            return Color.red
        }
    }
}

// MARK: - GlassGreenButtonStyle

private struct GlassGreenButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        GlassGreenButtonContent(configuration: configuration)
    }
}

private struct GlassGreenButtonContent: View {
    let configuration: ButtonStyleConfiguration
    @State private var isHovered = false

    var body: some View {
        configuration.label
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(backgroundColor)
                    .shadow(color: .green.opacity(0.3), radius: isHovered ? 8 : 4, y: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
            .onHover { hovering in
                isHovered = hovering
            }
    }

    private var backgroundColor: Color {
        if configuration.isPressed {
            return Color.green.opacity(0.8)
        } else if isHovered {
            return Color.green.opacity(0.9)
        } else {
            return Color.green
        }
    }
}

// MARK: - GlassSecondaryButtonStyle

private struct GlassSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        GlassSecondaryButtonContent(configuration: configuration)
    }
}

private struct GlassSecondaryButtonContent: View {
    let configuration: ButtonStyleConfiguration
    @State private var isHovered = false

    var body: some View {
        configuration.label
            .foregroundStyle(.primary)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.primary.opacity(0.08))
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(isHovered ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

// MARK: - GlassTabButton

private struct GlassTabButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? .primary : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.primary.opacity(0.08))
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - GlassMenuButton

private struct GlassMenuButton: View {
    let title: String
    let icon: String
    let shortcut: String?
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                Text(title)
                Spacer()
                if let shortcut = shortcut {
                    Text("\u{2318}\(shortcut)")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(isHovered ? Color.primary.opacity(0.08) : Color.clear)
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
