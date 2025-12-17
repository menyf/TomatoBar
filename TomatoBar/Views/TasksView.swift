// MARK: - TasksView.swift
// Task management view for tracking work items during pomodoro sessions.
// Includes task list, add/remove functionality, and completion tracking.
// Updated for macOS 26 Tahoe with Liquid Glass design.

import SwiftUI

// MARK: - TaskRowView

struct TaskRowView: View {
    let task: TBTask
    let onToggle: () -> Void
    let onDelete: () -> Void

    @State private var isHovered = false

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            toggleButton
            titleText
            deleteButton
                .opacity(isHovered ? 1 : 0)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.primary.opacity(0.04))
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }

    // MARK: - Subviews

    private var toggleButton: some View {
        Button(action: onToggle) {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(task.isCompleted ? .red : .secondary)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
    }

    private var titleText: some View {
        Text(attributedTitle)
            .strikethrough(task.isCompleted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var attributedTitle: AttributedString {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let range = NSRange(task.title.startIndex..., in: task.title)
        let matches = detector?.matches(in: task.title, options: [], range: range) ?? []

        // If no URLs, return plain text
        if matches.isEmpty {
            var result = AttributedString(task.title)
            result.foregroundColor = task.isCompleted ? .secondary : .primary
            return result
        }

        // Build attributed string, replacing URLs with [url]
        var result = AttributedString()
        var currentIndex = task.title.startIndex

        for match in matches {
            guard let url = match.url,
                  let matchRange = Range(match.range, in: task.title) else { continue }

            // Add text before the URL
            if currentIndex < matchRange.lowerBound {
                var textPart = AttributedString(String(task.title[currentIndex..<matchRange.lowerBound]))
                textPart.foregroundColor = task.isCompleted ? .secondary : .primary
                result += textPart
            }

            // Add clickable [url] link
            var linkPart = AttributedString("url")
            linkPart.link = url
            linkPart.foregroundColor = .blue
            result += AttributedString("[")
            result += linkPart
            result += AttributedString("]")

            currentIndex = matchRange.upperBound
        }

        // Add remaining text after last URL
        if currentIndex < task.title.endIndex {
            var textPart = AttributedString(String(task.title[currentIndex...]))
            textPart.foregroundColor = task.isCompleted ? .secondary : .primary
            result += textPart
        }

        return result
    }

    private var deleteButton: some View {
        Button(action: onDelete) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - TasksView

struct TasksView: View {
    @EnvironmentObject var taskManager: TBTaskManager
    @State private var newTaskTitle = ""
    @FocusState private var isInputFocused: Bool

    // MARK: - Body

    var body: some View {
        VStack(spacing: 8) {
            addTaskRow
            taskListContent
        }
    }

    // MARK: - Subviews

    private var addTaskRow: some View {
        HStack(spacing: 8) {
            TextField(
                NSLocalizedString("TasksView.newTask.placeholder", comment: "New task placeholder"),
                text: $newTaskTitle,
                onCommit: addTask
            )
            .textFieldStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.primary.opacity(0.04))
            )
            .focused($isInputFocused)

            Button(action: addTask) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.red.opacity(0.9))
            }
            .buttonStyle(.plain)
            .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
        }
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
        VStack(spacing: 6) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 24, weight: .light))
                .foregroundStyle(.tertiary)
            Text(NSLocalizedString("TasksView.empty.label", comment: "No tasks label"))
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }

    private var taskListView: some View {
        ScrollView {
            VStack(spacing: 6) {
                ForEach(sortedTasks) { task in
                    TaskRowView(
                        task: task,
                        onToggle: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                taskManager.toggleTask(task)
                            }
                        },
                        onDelete: { taskManager.removeTask(task) }
                    )
                }
            }
        }
        .frame(maxHeight: 200)
    }

    private var sortedTasks: [TBTask] {
        taskManager.tasks.sorted { !$0.isCompleted && $1.isCompleted }
    }

    private var taskFooter: some View {
        HStack {
            HStack(spacing: 4) {
                Text("\(taskManager.tasks.filter { $0.isCompleted }.count)")
                    .foregroundStyle(.secondary)
                Text("/")
                    .foregroundStyle(.tertiary)
                Text("\(taskManager.tasks.count)")
                    .foregroundStyle(.secondary)
            }
            .font(.system(size: 12, weight: .medium, design: .rounded))

            Spacer()

            Button(action: taskManager.removeAllTasks) {
                HStack(spacing: 4) {
                    Image(systemName: "trash")
                        .font(.system(size: 10))
                    Text(NSLocalizedString("TasksView.clearAll.label", comment: "Clear all label"))
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.red.opacity(0.8))
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 4)
    }

    // MARK: - Actions

    private func addTask() {
        taskManager.addTask(newTaskTitle)
        newTaskTitle = ""
    }
}
