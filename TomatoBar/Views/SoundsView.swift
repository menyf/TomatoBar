// MARK: - SoundsView.swift
// Sound settings view for adjusting volume levels of
// windup, ding, and ticking sounds.
// Updated for macOS 26 Tahoe with Liquid Glass design.

import SwiftUI

// MARK: - SoundsView

struct SoundsView: View {
    @EnvironmentObject var player: TBPlayer

    // MARK: - Body

    var body: some View {
        VStack(spacing: 8) {
            GlassSoundRow(
                icon: "arrow.clockwise.circle.fill",
                iconColor: .orange,
                label: NSLocalizedString("SoundsView.isWindupEnabled.label",
                                         comment: "Windup label"),
                volume: $player.windupVolume
            )

            GlassSoundRow(
                icon: "bell.fill",
                iconColor: .yellow,
                label: NSLocalizedString("SoundsView.isDingEnabled.label",
                                         comment: "Ding label"),
                volume: $player.dingVolume
            )

            GlassSoundRow(
                icon: "metronome.fill",
                iconColor: .blue,
                label: NSLocalizedString("SoundsView.isTickingEnabled.label",
                                         comment: "Ticking label"),
                volume: $player.tickingVolume
            )
        }
    }
}

// MARK: - GlassSoundRow

private struct GlassSoundRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    @Binding var volume: Double

    private var volumeIcon: String {
        if volume == 0 {
            return "speaker.slash.fill"
        } else if volume < 1.0 {
            return "speaker.wave.1.fill"
        } else {
            return "speaker.wave.2.fill"
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 16)

            Text(label)
                .font(.system(size: 12))
                .frame(width: 50, alignment: .leading)

            Image(systemName: volumeIcon)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.tertiary)
                .frame(width: 14)

            Slider(value: $volume, in: 0...2)
                .controlSize(.small)

            Button {
                volume = 1.0
            } label: {
                Text(String(format: "%.1f", volume))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                    .frame(width: 28, alignment: .trailing)
            }
            .buttonStyle(.plain)
            .help("Click to reset to 1.0")
        }
    }
}
