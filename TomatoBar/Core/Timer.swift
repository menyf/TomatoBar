// MARK: - Timer.swift
// Core timer orchestration using SwiftState machine.
// Handles work/rest cycles, URL scheme commands, and keyboard shortcuts.
// Dependencies: State.swift, Player.swift, Notifications.swift, Logger.swift

import KeyboardShortcuts
import SwiftState
import SwiftUI

// MARK: - TBTimer

/// The main timer controller that orchestrates pomodoro work/rest cycles.
final class TBTimer: ObservableObject {

    // MARK: - User Preferences

    @AppStorage("showTimerInMenuBar") var showTimerInMenuBar = true
    @AppStorage("debugMode") var debugMode = false
    @AppStorage("workIntervalLength") var workIntervalLength = 25
    @AppStorage("shortRestIntervalLength") var shortRestIntervalLength = 5
    @AppStorage("longRestIntervalLength") var longRestIntervalLength = 15
    @AppStorage("workIntervalsInSet") var workIntervalsInSet = 4
    /// Hidden preference: time limit before timer auto-stops after being missed
    @AppStorage("overrunTimeLimit") var overrunTimeLimit = -60.0

    // MARK: - Published State

    @Published var timeLeftString: String = ""
    @Published var timer: DispatchSourceTimer?
    @Published var pendingBreak: Bool = false
    @Published var isResting: Bool = false

    // MARK: - Internal Components

    let player = TBPlayer()
    private var stateMachine = TBStateMachine(state: .idle)
    private var notificationCenter = TBNotificationCenter()
    private var consecutiveWorkIntervals: Int = 0
    private var finishTime: Date!
    private let timerFormatter: DateComponentsFormatter

    // MARK: - Initialization

    init() {
        timerFormatter = DateComponentsFormatter()
        timerFormatter.unitsStyle = .positional
        timerFormatter.allowedUnits = [.minute, .second]
        timerFormatter.zeroFormattingBehavior = .pad

        configureStateMachine()
        configureKeyboardShortcut()
        configureNotificationHandler()
        configureURLScheme()
    }

    // MARK: - State Machine Configuration

    private func configureStateMachine() {
        /*
         * State diagram:
         *
         *       startStop        timerFired       startBreak       timerFired
         * idle ---------> work -----------> idle -----------> rest -----------> idle
         *   A               |                 A                 |
         *   |   startStop   |                 |    startStop    |
         *   +---------------+                 +-----------------+
         *                                     |    skipRest     |
         *                                     +-----------------+
         */

        // Basic transitions
        stateMachine.addRoutes(event: .startStop, transitions: [
            .idle => .work,
            .work => .idle,
            .rest => .idle
        ])

        // Timer fired transitions - always go to idle
        stateMachine.addRoutes(event: .timerFired, transitions: [
            .work => .idle,
            .rest => .idle
        ])

        // Manual transitions
        stateMachine.addRoutes(event: .skipRest, transitions: [.rest => .idle])
        stateMachine.addRoutes(event: .startBreak, transitions: [.idle => .rest])

        // State handlers
        stateMachine.addAnyHandler(.any => .work, handler: onWorkStart)
        stateMachine.addAnyHandler(.work => .idle, order: 0, handler: onWorkFinish)
        stateMachine.addAnyHandler(.work => .any, order: 1, handler: onWorkEnd)
        stateMachine.addAnyHandler(.any => .rest, handler: onRestStart)
        stateMachine.addAnyHandler(.rest => .idle, order: 0, handler: onRestFinish)
        stateMachine.addAnyHandler(.any => .idle, handler: onIdleStart)

        // Logging handler
        stateMachine.addAnyHandler(.any => .any) { ctx in
            logger.append(event: TBLogEventTransition(fromContext: ctx))
        }

        // Error handler
        stateMachine.addErrorHandler { ctx in
            fatalError("State machine error: <\(ctx)>")
        }
    }

    private func configureKeyboardShortcut() {
        KeyboardShortcuts.onKeyUp(for: .startStopTimer, action: startStop)
    }

    private func configureNotificationHandler() {
        notificationCenter.setActionHandler { [weak self] action in
            if action == .skipRest, self?.stateMachine.state == .rest {
                self?.skipRest()
            }
        }
    }

    private func configureURLScheme() {
        let aem = NSAppleEventManager.shared()
        aem.setEventHandler(
            self,
            andSelector: #selector(handleGetURLEvent(_:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }

    // MARK: - URL Scheme Handler

    @objc func handleGetURLEvent(
        _ event: NSAppleEventDescriptor,
        withReplyEvent _: NSAppleEventDescriptor
    ) {
        guard let urlString = event.forKeyword(AEKeyword(keyDirectObject))?.stringValue,
              let url = URL(string: urlString),
              let scheme = url.scheme,
              scheme.caseInsensitiveCompare("tomatobar") == .orderedSame,
              let command = url.host?.lowercased() else {
            return
        }

        switch command {
        case "startstop":
            startStop()
        default:
            print("Unknown URL command: \(command)")
        }
    }

    // MARK: - Public Actions

    func startStop() {
        stateMachine <-! .startStop
    }

    func skipRest() {
        stateMachine <-! .skipRest
    }

    func startBreak() {
        stateMachine <-! .startBreak
    }

    func updateTimeLeft() {
        timeLeftString = timerFormatter.string(from: Date(), to: finishTime) ?? ""

        if timer != nil, showTimerInMenuBar {
            TBStatusItem.shared.setTitle(title: timeLeftString)
        } else if pendingBreak {
            TBStatusItem.shared.setTitle(title: NSLocalizedString("TBTimer.pendingBreak.menuBar", comment: "Menu bar text when break is pending"))
        } else {
            TBStatusItem.shared.setTitle(title: nil)
        }
    }

    // MARK: - Timer Management

    private func startTimer(seconds: Int) {
        finishTime = Date().addingTimeInterval(TimeInterval(seconds))

        let queue = DispatchQueue(label: "Timer")
        timer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
        timer?.schedule(deadline: .now(), repeating: .seconds(1), leeway: .never)
        timer?.setEventHandler(handler: onTimerTick)
        timer?.setCancelHandler(handler: onTimerCancel)
        timer?.resume()
    }

    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }

    // MARK: - Timer Event Handlers

    private func onTimerTick() {
        // Cannot publish updates from background thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.updateTimeLeft()
            let timeLeft = self.finishTime.timeIntervalSince(Date())

            if timeLeft <= 0 {
                // Ticks can be missed during machine sleep.
                // Stop the timer if it goes beyond the overrun time limit.
                if timeLeft < self.overrunTimeLimit {
                    self.stateMachine <-! .startStop
                } else {
                    self.stateMachine <-! .timerFired
                }
            }
        }
    }

    private func onTimerCancel() {
        DispatchQueue.main.async { [weak self] in
            self?.updateTimeLeft()
        }
    }

    // MARK: - State Transition Handlers

    private func onWorkStart(context _: TBStateMachine.Context) {
        pendingBreak = false
        TBStatusItem.shared.setIcon(name: .work)
        player.playWindup()
        player.startTicking()
        let seconds = debugMode ? 5 : workIntervalLength * 60
        startTimer(seconds: seconds)
    }

    private func onWorkFinish(context ctx: TBStateMachine.Context) {
        if ctx.event == .timerFired {
            consecutiveWorkIntervals += 1
            pendingBreak = true
            player.playDing()
            notificationCenter.send(
                title: NSLocalizedString("TBTimer.onWorkFinish.title", comment: "Work finished title"),
                body: NSLocalizedString("TBTimer.onWorkFinish.body", comment: "Work finished body"),
                category: .workFinished
            )
        }
    }

    private func onWorkEnd(context _: TBStateMachine.Context) {
        player.stopTicking()
    }

    private func onRestStart(context _: TBStateMachine.Context) {
        pendingBreak = false
        isResting = true

        let isLongRest = consecutiveWorkIntervals >= workIntervalsInSet
        let body: String
        let length: Int
        let iconName: NSImage.Name

        if isLongRest {
            body = NSLocalizedString("TBTimer.onRestStart.long.body", comment: "Long break body")
            length = longRestIntervalLength
            iconName = .longRest
            consecutiveWorkIntervals = 0
        } else {
            body = NSLocalizedString("TBTimer.onRestStart.short.body", comment: "Short break body")
            length = shortRestIntervalLength
            iconName = .shortRest
        }

        notificationCenter.send(
            title: NSLocalizedString("TBTimer.onRestStart.title", comment: "Time's up title"),
            body: body,
            category: .restStarted
        )
        TBStatusItem.shared.setIcon(name: iconName)
        let seconds = debugMode ? 5 : length * 60
        startTimer(seconds: seconds)
    }

    private func onRestFinish(context ctx: TBStateMachine.Context) {
        guard ctx.event != .skipRest else { return }

        player.playDing()
        notificationCenter.send(
            title: NSLocalizedString("TBTimer.onRestFinish.title", comment: "Break is over title"),
            body: NSLocalizedString("TBTimer.onRestFinish.body", comment: "Break is over body"),
            category: .restFinished
        )
    }

    private func onIdleStart(context _: TBStateMachine.Context) {
        stopTimer()
        isResting = false
        TBStatusItem.shared.setIcon(name: .idle)
        if !pendingBreak {
            consecutiveWorkIntervals = 0
        }
    }
}
