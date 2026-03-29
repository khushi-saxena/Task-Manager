import Foundation
import Combine

enum Filter: String, CaseIterable {
    case all    = "All"
    case active = "Active"
    case done   = "Done"
}

class TaskViewModel: ObservableObject {
    
    @Published var tasks: [Task] = [
        Task(title: "Apply to 3 iOS roles", priority: .high),
        Task(title: "Finish SwiftUI Day 4",  priority: .high),
        Task(title: "Push project to GitHub", priority: .medium),
        Task(title: "Buy coffee",             priority: .low)
    ]
    @Published var filter: Filter = .all

    var filtered: [Task] {
        switch filter {
        case .all:    return tasks
        case .active: return tasks.filter { !$0.isDone }
        case .done:   return tasks.filter {  $0.isDone }
        }
    }

    var stats: (total: Int, done: Int) {
        (tasks.count, tasks.filter { $0.isDone }.count)
    }

    func addTask(title: String, priority: Priority) {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        tasks.append(Task(title: title, priority: priority))
    }

    func toggleDone(_ task: Task) {
        if let i = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[i].isDone.toggle()
        }
    }

    func delete(at offsets: IndexSet) {
        let source = filtered
        offsets.forEach { i in
            if let j = tasks.firstIndex(where: { $0.id == source[i].id }) {
                tasks.remove(at: j)
            }
        }
    }
}

