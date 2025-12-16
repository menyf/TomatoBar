// MARK: - State.swift
// State machine type definitions for the pomodoro timer.
// Defines the three timer states and transition events.

import SwiftState

// MARK: - Type Alias

typealias TBStateMachine = StateMachine<TimerState, TimerEvent>

// MARK: - TimerEvent

/// Events that trigger state transitions in the timer.
enum TimerEvent: EventType {
    /// User toggled start/stop
    case startStop
    /// Timer interval completed
    case timerFired
    /// User skipped rest period
    case skipRest
    /// User manually started break (when auto-start is disabled)
    case startBreak
}

// MARK: - TimerState

/// The three possible states of the pomodoro timer.
enum TimerState: StateType {
    /// Timer is stopped, no active session
    case idle
    /// Active work session in progress
    case work
    /// Rest/break period in progress
    case rest
}
