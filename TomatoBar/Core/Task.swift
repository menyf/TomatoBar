// MARK: - Task.swift
// Task model and persistence manager for tracking work items.
// Tasks are stored in UserDefaults as JSON.

import SwiftUI

// MARK: - TBTask

/// A single task item that can be tracked during pomodoro sessions.
struct TBTask: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

// MARK: - TBTaskManager

/// Manages the list of tasks with persistence to UserDefaults.
final class TBTaskManager: ObservableObject {

    // MARK: - Properties

    @Published var tasks: [TBTask] = [] {
        didSet { saveTasks() }
    }

    private let tasksKey = "tasks"

    // MARK: - Initialization

    init() {
        loadTasks()
    }

    // MARK: - Persistence

    private func loadTasks() {
        guard let data = UserDefaults.standard.data(forKey: tasksKey),
              let decoded = try? JSONDecoder().decode([TBTask].self, from: data) else {
            return
        }
        tasks = decoded
    }

    private func saveTasks() {
        guard let encoded = try? JSONEncoder().encode(tasks) else { return }
        UserDefaults.standard.set(encoded, forKey: tasksKey)
    }

    // MARK: - Task Operations

    func addTask(_ title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        tasks.append(TBTask(title: trimmed))
    }

    func removeTask(_ task: TBTask) {
        tasks.removeAll { $0.id == task.id }
    }

    func removeAllTasks() {
        tasks.removeAll()
    }

    func toggleTask(_ task: TBTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isCompleted.toggle()
    }
}
