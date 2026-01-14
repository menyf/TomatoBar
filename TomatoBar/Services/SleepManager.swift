// MARK: - SleepManager.swift
// Sleep prevention service using IOKit.
// Prevents Mac from sleeping when enabled.

import IOKit.pwr_mgt

// MARK: - TBSleepManager

final class TBSleepManager {

    // MARK: - Singleton

    static let shared = TBSleepManager()

    // MARK: - Private State

    private var displayAssertionID: IOPMAssertionID = 0
    private var systemAssertionID: IOPMAssertionID = 0
    private var isPreventingSleep = false

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Methods

    /// Prevents the Mac from sleeping (similar to caffeinate -d -i).
    func preventSleep() {
        guard !isPreventingSleep else { return }

        let reason = "TomatoBar is keeping your Mac awake" as CFString

        // Prevent display from sleeping (like caffeinate -d)
        let displayResult = IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &displayAssertionID
        )

        // Prevent system from idle sleeping (like caffeinate -i)
        let systemResult = IOPMAssertionCreateWithName(
            kIOPMAssertionTypeNoIdleSleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &systemAssertionID
        )

        if displayResult == kIOReturnSuccess || systemResult == kIOReturnSuccess {
            isPreventingSleep = true
        }
    }

    /// Allows the Mac to sleep normally.
    func allowSleep() {
        guard isPreventingSleep else { return }

        if displayAssertionID != 0 {
            IOPMAssertionRelease(displayAssertionID)
            displayAssertionID = 0
        }

        if systemAssertionID != 0 {
            IOPMAssertionRelease(systemAssertionID)
            systemAssertionID = 0
        }

        isPreventingSleep = false
    }
}
