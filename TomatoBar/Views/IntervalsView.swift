// MARK: - IntervalsView.swift
// Settings view for configuring work/rest interval durations.
// Allows users to customize pomodoro timing and auto-start behavior.

import SwiftUI

struct IntervalsView: View {
    @EnvironmentObject var timer: TBTimer

    // MARK: - Properties

    private let minStr = NSLocalizedString("IntervalsView.min", comment: "min")

    // MARK: - Body

    var body: some View {
        VStack {
            workIntervalStepper
            shortRestStepper
            longRestStepper
            workIntervalsInSetStepper
            autoStartBreakToggle
        }
        .padding(4)
    }

    // MARK: - Subviews

    private var workIntervalStepper: some View {
        Stepper(value: $timer.workIntervalLength, in: 1...60) {
            HStack {
                Text(NSLocalizedString("IntervalsView.workIntervalLength.label",
                                        comment: "Work interval label"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(String.localizedStringWithFormat(minStr, timer.workIntervalLength))
            }
        }
    }

    private var shortRestStepper: some View {
        Stepper(value: $timer.shortRestIntervalLength, in: 1...60) {
            HStack {
                Text(NSLocalizedString("IntervalsView.shortRestIntervalLength.label",
                                        comment: "Short rest interval label"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(String.localizedStringWithFormat(minStr, timer.shortRestIntervalLength))
            }
        }
    }

    private var longRestStepper: some View {
        Stepper(value: $timer.longRestIntervalLength, in: 1...60) {
            HStack {
                Text(NSLocalizedString("IntervalsView.longRestIntervalLength.label",
                                        comment: "Long rest interval label"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(String.localizedStringWithFormat(minStr, timer.longRestIntervalLength))
            }
        }
        .help(NSLocalizedString("IntervalsView.longRestIntervalLength.help",
                                comment: "Long rest interval hint"))
    }

    private var workIntervalsInSetStepper: some View {
        Stepper(value: $timer.workIntervalsInSet, in: 1...10) {
            HStack {
                Text(NSLocalizedString("IntervalsView.workIntervalsInSet.label",
                                        comment: "Work intervals in a set label"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(timer.workIntervalsInSet)")
            }
        }
        .help(NSLocalizedString("IntervalsView.workIntervalsInSet.help",
                                comment: "Work intervals in set hint"))
    }

    private var autoStartBreakToggle: some View {
        Toggle(isOn: $timer.autoStartBreak) {
            Text(NSLocalizedString("IntervalsView.autoStartBreak.label",
                                   comment: "Auto start break label"))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .toggleStyle(.switch)
    }
}
