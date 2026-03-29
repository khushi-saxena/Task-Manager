internal import SwiftUI

struct ContentView: View {
    @StateObject private var vm = TaskViewModel()
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Stats bar
                StatsBar(done: vm.stats.done, total: vm.stats.total)

                // Filter picker
                Picker("Filter", selection: $vm.filter) {
                    ForEach(Filter.allCases, id: \.self) { f in
                        Text(f.rawValue).tag(f)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 10)

                // Task list
                if vm.filtered.isEmpty {
                    EmptyState(filter: vm.filter)
                } else {
                    List {
                        ForEach(vm.filtered) { task in
                            TaskRow(task: task) {
                                vm.toggleDone(task)
                            }
                        }
                        .onDelete(perform: vm.delete)
                    }
                    .listStyle(.insetGrouped)
                    .animation(.default, value: vm.filtered.map(\.id))
                }
            }
            .navigationTitle("My Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                        .tint(.indigo)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .tint(.indigo)
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddTaskView(vm: vm, isPresented: $showingAdd)
            }
        }
    }
}

// MARK: - Stats Bar
struct StatsBar: View {
    let done: Int
    let total: Int

    var progress: Double {
        total == 0 ? 0 : Double(done) / Double(total)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(done) of \(total) completed")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.subheadline.bold())
                    .foregroundStyle(.indigo)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.indigo)
                        .frame(width: geo.size.width * progress, height: 6)
                        .animation(.spring(response: 0.4), value: progress)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}

// MARK: - Task Row
struct TaskRow: View {
    let task: Task
    let onToggle: () -> Void

    var priorityColor: Color {
        switch task.priority {
        case .low:    return .green
        case .medium: return .orange
        case .high:   return .red
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            // Priority stripe
            RoundedRectangle(cornerRadius: 3)
                .fill(priorityColor)
                .frame(width: 4, height: 40)

            // Toggle button
            Button(action: onToggle) {
                Image(systemName: task.isDone
                      ? "checkmark.circle.fill"
                      : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isDone ? .indigo : Color(.systemGray3))
                    .animation(.spring(response: 0.3), value: task.isDone)
            }
            .buttonStyle(.plain)

            // Content
            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.body)
                    .strikethrough(task.isDone, color: .secondary)
                    .foregroundStyle(task.isDone ? .secondary : .primary)

                Text(task.priority.rawValue)
                    .font(.caption)
                    .foregroundStyle(priorityColor)
                    .fontWeight(.medium)
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture(perform: onToggle)
    }
}

// MARK: - Empty State
struct EmptyState: View {
    let filter: Filter

    var message: (icon: String, text: String) {
        switch filter {
        case .all:    return ("checklist", "No tasks yet. Tap + to add one.")
        case .active: return ("checkmark.circle", "All tasks done!")
        case .done:   return ("circle.dashed", "Nothing completed yet.")
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: message.icon)
                .font(.system(size: 48))
                .foregroundStyle(.indigo.opacity(0.4))
            Text(message.text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }
}

// MARK: - Add Task Sheet
struct AddTaskView: View {
    @ObservedObject var vm: TaskViewModel
    @Binding var isPresented: Bool
    @State private var title = ""
    @State private var priority: Priority = .medium

    var body: some View {
        NavigationStack {
            Form {
                Section("What needs doing?") {
                    TextField("Task title", text: $title)
                }
                Section("Priority") {
                    ForEach(Priority.allCases, id: \.self) { p in
                        HStack {
                            PriorityDot(priority: p)
                            Text(p.rawValue)
                            Spacer()
                            if priority == p {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.indigo)
                                    .fontWeight(.medium)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { priority = p }
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                        .tint(.secondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        vm.addTask(title: title, priority: priority)
                        isPresented = false
                    }
                    .tint(.indigo)
                    .fontWeight(.medium)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Priority Dot
struct PriorityDot: View {
    let priority: Priority

    var color: Color {
        switch priority {
        case .low:    return .green
        case .medium: return .orange
        case .high:   return .red
        }
    }

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 10, height: 10)
    }
}

#Preview {
    ContentView()
}
