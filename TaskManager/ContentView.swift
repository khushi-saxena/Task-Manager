internal import SwiftUI

struct ContentView: View {
    @StateObject private var vm = TaskViewModel()
    @State private var newTitle = ""
    @State private var newPriority: Priority = .medium
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.tasks) { task in
                    HStack(spacing: 12) {
                        // Done toggle
                        Button {
                            vm.toggleDone(task)
                        } label: {
                            Image(systemName: task.isDone
                                  ? "checkmark.circle.fill"
                                  : "circle")
                                .foregroundStyle(task.isDone ? .green : .gray)
                                .font(.title3)
                        }
                        .buttonStyle(.plain)

                        // Title
                        VStack(alignment: .leading, spacing: 2) {
                            Text(task.title)
                                .strikethrough(task.isDone)
                                .foregroundStyle(task.isDone
                                                 ? .secondary : .primary)
                            Text("\(task.priority.icon) \(task.priority.rawValue)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: vm.delete)
            }
            .navigationTitle("Task Manager")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
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
                            Text("\(p.icon) \(p.rawValue)").tag(p)
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
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
