// MARK: - TasksView.swift
// Task management view for tracking work items during pomodoro sessions.
// Includes task list, add/remove functionality, and completion tracking.

import SwiftUI

// MARK: - TaskRowView

struct TaskRowView: View {
    let task: TBTask
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            toggleButton
            titleText
            deleteButton
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.primary.opacity(0.05))
        )
    }

    // MARK: - Subviews

    private var toggleButton: some View {
        Button(action: onToggle) {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 16))
                .foregroundColor(task.isCompleted ? .accentColor : .secondary)
        }
        .buttonStyle(.plain)
    }

    private var titleText: some View {
        Text(task.title)
            .strikethrough(task.isCompleted)
            .foregroundColor(task.isCompleted ? .secondary : .primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var deleteButton: some View {
        Button(action: onDelete) {
            Image(systemName: "trash")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
        .opacity(0.6)
    }
}

// MARK: - TasksView

struct TasksView: View {
    @EnvironmentObject var taskManager: TBTaskManager
    @State private var newTaskTitle = ""

    // MARK: - Body

    var body: some View {
        VStack(spacing: 6) {
            addTaskRow
            taskListContent
        }
        .padding(4)
    }

    // MARK: - Subviews

    private var addTaskRow: some View {
        HStack(spacing: 6) {
            TextField(
                NSLocalizedString("TasksView.newTask.placeholder", comment: "New task placeholder"),
                text: $newTaskTitle,
                onCommit: addTask
            )
            .textFieldStyle(.roundedBorder)

            Button(action: addTask) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
            .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.bottom, 4)
    }

    @ViewBuilder
    private var taskListContent: some View {
        if taskManager.tasks.isEmpty {
            emptyStateView
        } else {
            taskListView
            taskFooter
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 4) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 24))
                .foregroundColor(.secondary.opacity(0.5))
            Text(NSLocalizedString("TasksView.empty.label", comment: "No tasks label"))
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    private var taskListView: some View {
        VStack(spacing: 4) {
            ForEach(taskManager.tasks) { task in
                TaskRowView(
                    task: task,
                    onToggle: { taskManager.toggleTask(task) },
                    onDelete: { taskManager.removeTask(task) }
                )
            }
        }
    }

    private var taskFooter: some View {
        HStack {
            Text("\(taskManager.tasks.filter { $0.isCompleted }.count)/\(taskManager.tasks.count)")
                .font(.system(size: 11))
                .foregroundColor(.secondary)

            Spacer()

            Button(action: taskManager.removeAllTasks) {
                Text(NSLocalizedString("TasksView.clearAll.label", comment: "Clear all label"))
                    .font(.system(size: 11))
                    .foregroundColor(.red.opacity(0.8))
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 2)
    }

    // MARK: - Actions

    private func addTask() {
        taskManager.addTask(newTaskTitle)
        newTaskTitle = ""
    }
}
