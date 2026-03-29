internal import SwiftUI

struct ContentView: View {
    @StateObject private var vm = TaskViewModel()
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            Group {
                if vm.tasks.isEmpty {
                    EmptyTasksView()
                } else {
                    List {
                        ForEach(vm.tasks) { task in
                            TaskRowView(task: task) {
                                vm.toggleDone(task)
                            }
                        }
                        .onDelete(perform: vm.delete)
                    }
                }
            }
            .navigationTitle("Task Manager")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add task")
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddTaskView(vm: vm, isPresented: $showingAdd)
            }
        }
    }
}

struct TaskRowView: View {
    let task: Task
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Done toggle
            Button(action: onToggle) {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isDone ? .green : .secondary)
                    .font(.title3)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(task.isDone ? "Mark as not done" : "Mark as done")

            // Title and priority
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .strikethrough(task.isDone, color: .secondary)
                    .foregroundStyle(task.isDone ? .secondary : .primary)
                    .fontWeight(.medium)

                HStack(spacing: 4) {
                    Image(systemName: task.priority.icon)
                    Text(task.priority.rawValue)
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(task.priority.color)
            }

            Spacer()
        }
        .padding(.vertical, 6)
        .opacity(task.isDone ? 0.6 : 1.0)
    }
}

struct EmptyTasksView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("No tasks yet")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Tap + to add your first task")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AddTaskView: View {
    @ObservedObject var vm: TaskViewModel
    @Binding var isPresented: Bool
    @State private var title = ""
    @State private var priority: Priority = .medium

    var body: some View {
        NavigationStack {
            Form {
                Section("Task details") {
                    TextField("What needs doing?", text: $title)
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases, id: \.self) { p in
                            HStack {
                                Image(systemName: p.icon)
                                    .foregroundStyle(p.color)
                                Text(p.rawValue)
                            }
                            .tag(p)
                        }
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        vm.addTask(title: title, priority: priority)
                        isPresented = false
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
