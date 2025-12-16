// MARK: - Player.swift
// Audio playback service for timer sounds.
// Handles windup, ding, and ticking sound effects with volume control.

import AVFoundation
import SwiftUI

// MARK: - TBPlayer

final class TBPlayer: ObservableObject {

    // MARK: - Audio Players

    private let windupSound: AVAudioPlayer
    private let dingSound: AVAudioPlayer
    private let tickingSound: AVAudioPlayer

    // MARK: - Volume Settings

    @AppStorage("windupVolume") var windupVolume: Double = 1.0 {
        didSet { setVolume(windupSound, windupVolume) }
    }

    @AppStorage("dingVolume") var dingVolume: Double = 1.0 {
        didSet { setVolume(dingSound, dingVolume) }
    }

    @AppStorage("tickingVolume") var tickingVolume: Double = 1.0 {
        didSet { setVolume(tickingSound, tickingVolume) }
    }

    // MARK: - Initialization

    init() {
        guard let windupAsset = NSDataAsset(name: "windup"),
              let dingAsset = NSDataAsset(name: "ding"),
              let tickingAsset = NSDataAsset(name: "ticking") else {
            fatalError("Missing audio assets")
        }

        let wav = AVFileType.wav.rawValue
        do {
            windupSound = try AVAudioPlayer(data: windupAsset.data, fileTypeHint: wav)
            dingSound = try AVAudioPlayer(data: dingAsset.data, fileTypeHint: wav)
            tickingSound = try AVAudioPlayer(data: tickingAsset.data, fileTypeHint: wav)
        } catch {
            fatalError("Error initializing audio players: \(error)")
        }

        windupSound.prepareToPlay()
        dingSound.prepareToPlay()
        tickingSound.numberOfLoops = -1
        tickingSound.prepareToPlay()

        setVolume(windupSound, windupVolume)
        setVolume(dingSound, dingVolume)
        setVolume(tickingSound, tickingVolume)
    }

    // MARK: - Private Helpers

    private func setVolume(_ sound: AVAudioPlayer, _ volume: Double) {
        sound.setVolume(Float(volume), fadeDuration: 0)
    }

    // MARK: - Playback Control

    func playWindup() {
        windupSound.play()
    }

    func playDing() {
        dingSound.play()
    }

    func startTicking() {
        tickingSound.play()
    }

    func stopTicking() {
        tickingSound.stop()
    }
}
