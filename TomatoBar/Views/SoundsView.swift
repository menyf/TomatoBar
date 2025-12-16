// MARK: - SoundsView.swift
// Sound settings view for adjusting volume levels of
// windup, ding, and ticking sounds.

import SwiftUI

// MARK: - VolumeSlider

struct VolumeSlider: View {
    @Binding var volume: Double

    var body: some View {
        Slider(value: $volume, in: 0...2) {
            Text(String(format: "%.1f", volume))
        }
        .gesture(
            TapGesture(count: 2).onEnded {
                volume = 1.0
            }
        )
    }
}

// MARK: - SoundsView

struct SoundsView: View {
    @EnvironmentObject var player: TBPlayer

    // MARK: - Properties

    private let columns = [
        GridItem(.flexible()),
        GridItem(.fixed(110))
    ]

    // MARK: - Body

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 4) {
            Text(NSLocalizedString("SoundsView.isWindupEnabled.label",
                                   comment: "Windup label"))
            VolumeSlider(volume: $player.windupVolume)

            Text(NSLocalizedString("SoundsView.isDingEnabled.label",
                                   comment: "Ding label"))
            VolumeSlider(volume: $player.dingVolume)

            Text(NSLocalizedString("SoundsView.isTickingEnabled.label",
                                   comment: "Ticking label"))
            VolumeSlider(volume: $player.tickingVolume)
        }
        .padding(4)
        Spacer().frame(minHeight: 0)
    }
}
