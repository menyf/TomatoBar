// MARK: - Logger.swift
// JSON event logger for tracking app usage and state transitions.
// Logs are written to ~/Library/Caches/TomatoBar.log

import Foundation

// MARK: - Log Event Protocol

protocol TBLogEvent: Encodable {
    var type: String { get }
    var timestamp: Date { get }
}

// MARK: - Log Events

final class TBLogEventAppStart: TBLogEvent {
    let type = "appstart"
    let timestamp = Date()
}

final class TBLogEventTransition: TBLogEvent {
    let type = "transition"
    let timestamp = Date()

    private let event: String
    private let fromState: String
    private let toState: String

    init(fromContext ctx: TBStateMachine.Context) {
        event = "\(ctx.event!)"
        fromState = "\(ctx.fromState)"
        toState = "\(ctx.toState)"
    }
}

// MARK: - Constants

private let logFileName = "TomatoBar.log"
private let lineEnd = "\n".data(using: .utf8)!

// MARK: - Global Logger Instance

let logger = TBLogger()

// MARK: - TBLogger

final class TBLogger {
    private let logHandle: FileHandle?
    private let encoder: JSONEncoder

    // MARK: - Initialization

    init() {
        encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        encoder.dateEncodingStrategy = .secondsSince1970

        let fileManager = FileManager.default
        let logPath = fileManager
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent(logFileName)
            .path

        if !fileManager.fileExists(atPath: logPath) {
            guard fileManager.createFile(atPath: logPath, contents: nil) else {
                print("Cannot create log file")
                logHandle = nil
                return
            }
        }

        logHandle = FileHandle(forUpdatingAtPath: logPath)
        if logHandle == nil {
            print("Cannot open log file")
        }
    }

    // MARK: - Public Methods

    func append(event: TBLogEvent) {
        guard let logHandle = logHandle else { return }

        do {
            let jsonData = try encoder.encode(event)
            try logHandle.seekToEnd()
            try logHandle.write(contentsOf: jsonData + lineEnd)
            try logHandle.synchronize()
        } catch {
            print("Cannot write to log file: \(error)")
        }
    }
}
