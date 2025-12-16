// MARK: - Notifications.swift
// macOS notification service for timer alerts.
// Handles notification delivery and user action responses (e.g., skip break).

import UserNotifications

// MARK: - TBNotification Types

enum TBNotification {
    enum Category: String {
        case restStarted
        case restFinished
    }

    enum Action: String {
        case skipRest
    }
}

// MARK: - Handler Type

typealias TBNotificationHandler = (TBNotification.Action) -> Void

// MARK: - TBNotificationCenter

final class TBNotificationCenter: NSObject, UNUserNotificationCenterDelegate {
    private let center = UNUserNotificationCenter.current()
    private var handler: TBNotificationHandler?

    // MARK: - Initialization

    override init() {
        super.init()
        requestAuthorization()
        center.delegate = self
        registerCategories()
    }

    // MARK: - Setup

    private func requestAuthorization() {
        center.requestAuthorization(options: [.alert]) { _, error in
            if let error = error {
                print("Error requesting notification authorization: \(error)")
            }
        }
    }

    private func registerCategories() {
        let skipRestAction = UNNotificationAction(
            identifier: TBNotification.Action.skipRest.rawValue,
            title: NSLocalizedString("TBTimer.onRestStart.skip.title", comment: "Skip"),
            options: []
        )

        let restStartedCategory = UNNotificationCategory(
            identifier: TBNotification.Category.restStarted.rawValue,
            actions: [skipRestAction],
            intentIdentifiers: []
        )

        let restFinishedCategory = UNNotificationCategory(
            identifier: TBNotification.Category.restFinished.rawValue,
            actions: [],
            intentIdentifiers: []
        )

        center.setNotificationCategories([restStartedCategory, restFinishedCategory])
    }

    // MARK: - Public Methods

    func setActionHandler(handler: @escaping TBNotificationHandler) {
        self.handler = handler
    }

    func send(title: String, body: String, category: TBNotification.Category) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.categoryIdentifier = category.rawValue

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        center.add(request) { error in
            if let error = error {
                print("Error adding notification: \(error)")
            }
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler _: @escaping () -> Void
    ) {
        guard let handler = handler,
              let action = TBNotification.Action(rawValue: response.actionIdentifier) else {
            return
        }
        handler(action)
    }
}
