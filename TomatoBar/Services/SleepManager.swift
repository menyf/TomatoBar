// MARK: - SleepManager.swift
// Sleep prevention service using IOKit.
// Prevents Mac from sleeping when timer is active.

import IOKit.pwr_mgt

// MARK: - TBSleepManager

final class TBSleepManager {

    // MARK: - Singleton

    static let shared = TBSleepManager()

    // MARK: - Private State

    private var assertionID: IOPMAssertionID = 0
    private var isPreventingSleep = false

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Methods

    /// Prevents the Mac from sleeping (similar to caffeinate).
    func preventSleep() {
        guard !isPreventingSleep else { return }

        let reason = "TomatoBar timer is running" as CFString
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleSystemSleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &assertionID
        )

        if result == kIOReturnSuccess {
            isPreventingSleep = true
        }
    }

    /// Allows the Mac to sleep normally.
    func allowSleep() {
        guard isPreventingSleep else { return }

        IOPMAssertionRelease(assertionID)
        isPreventingSleep = false
        assertionID = 0
    }
}
