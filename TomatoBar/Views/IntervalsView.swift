// MARK: - IntervalsView.swift
// Settings view for configuring work/rest interval durations.
// Allows users to customize pomodoro timing and auto-start behavior.
// Updated for macOS 26 Tahoe with Liquid Glass design.

import SwiftUI

struct IntervalsView: View {
    @EnvironmentObject var timer: TBTimer

    // MARK: - Properties

    private let minStr = NSLocalizedString("IntervalsView.min", comment: "min")

    // MARK: - Body

    var body: some View {
        VStack(spacing: 8) {
            GlassSettingsRow(
                icon: "briefcase.fill",
                iconColor: .red,
                label: NSLocalizedString("IntervalsView.workIntervalLength.label",
                                         comment: "Work interval label")
            ) {
                GlassStepper(value: $timer.workIntervalLength, range: 1...60) {
                    Text(String.localizedStringWithFormat(minStr, timer.workIntervalLength))
                        .monospacedDigit()
                }
            }

            GlassSettingsRow(
                icon: "cup.and.saucer.fill",
                iconColor: .green,
                label: NSLocalizedString("IntervalsView.shortRestIntervalLength.label",
                                         comment: "Short rest interval label")
            ) {
                GlassStepper(value: $timer.shortRestIntervalLength, range: 1...60) {
                    Text(String.localizedStringWithFormat(minStr, timer.shortRestIntervalLength))
                        .monospacedDigit()
                }
            }

            GlassSettingsRow(
                icon: "moon.fill",
                iconColor: .blue,
                label: NSLocalizedString("IntervalsView.longRestIntervalLength.label",
                                         comment: "Long rest interval label"),
                help: NSLocalizedString("IntervalsView.longRestIntervalLength.help",
                                        comment: "Long rest interval hint")
            ) {
                GlassStepper(value: $timer.longRestIntervalLength, range: 1...60) {
                    Text(String.localizedStringWithFormat(minStr, timer.longRestIntervalLength))
                        .monospacedDigit()
                }
            }

            GlassSettingsRow(
                icon: "arrow.trianglehead.2.clockwise.rotate.90",
                iconColor: .orange,
                label: NSLocalizedString("IntervalsView.workIntervalsInSet.label",
                                         comment: "Work intervals in a set label"),
                help: NSLocalizedString("IntervalsView.workIntervalsInSet.help",
                                        comment: "Work intervals in set hint")
            ) {
                GlassStepper(value: $timer.workIntervalsInSet, range: 1...10) {
                    Text("\(timer.workIntervalsInSet)")
                        .monospacedDigit()
                }
            }
        }
    }
}

// MARK: - GlassSettingsRow

private struct GlassSettingsRow<Content: View>: View {
    let icon: String
    let iconColor: Color
    let label: String
    var help: String? = nil
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 16)

            Text(label)
                .font(.system(size: 12))
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 4)

            content()
                .fixedSize()
        }
        .help(help ?? "")
    }
}

// MARK: - GlassStepper

private struct GlassStepper<Label: View>: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    @ViewBuilder let label: () -> Label

    var body: some View {
        HStack(spacing: 4) {
            label()
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .frame(minWidth: 44, alignment: .trailing)

            HStack(spacing: 0) {
                Button {
                    if value > range.lowerBound {
                        value -= 1
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 9, weight: .bold))
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
                .disabled(value <= range.lowerBound)
                .opacity(value <= range.lowerBound ? 0.3 : 1.0)

                Divider()
                    .frame(height: 12)

                Button {
                    if value < range.upperBound {
                        value += 1
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 9, weight: .bold))
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
                .disabled(value >= range.upperBound)
                .opacity(value >= range.upperBound ? 0.3 : 1.0)
            }
            .background(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(Color.primary.opacity(0.06))
            )
        }
    }
}
