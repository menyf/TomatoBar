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

    // MARK: - Body

    var body: some View {
        VStack {
            windupVolumeRow
            dingVolumeRow
            tickingVolumeRow
        }
        .padding(4)
    }

    // MARK: - Subviews

    private var windupVolumeRow: some View {
        HStack {
            Text(NSLocalizedString("SoundsView.isWindupEnabled.label",
                                   comment: "Windup label"))
                .frame(maxWidth: .infinity, alignment: .leading)
            VolumeSlider(volume: $player.windupVolume)
                .frame(width: 110)
        }
    }

    private var dingVolumeRow: some View {
        HStack {
            Text(NSLocalizedString("SoundsView.isDingEnabled.label",
                                   comment: "Ding label"))
                .frame(maxWidth: .infinity, alignment: .leading)
            VolumeSlider(volume: $player.dingVolume)
                .frame(width: 110)
        }
    }

    private var tickingVolumeRow: some View {
        HStack {
            Text(NSLocalizedString("SoundsView.isTickingEnabled.label",
                                   comment: "Ticking label"))
                .frame(maxWidth: .infinity, alignment: .leading)
            VolumeSlider(volume: $player.tickingVolume)
                .frame(width: 110)
        }
    }
}
