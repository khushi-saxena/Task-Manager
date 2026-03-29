import Foundation
import Combine
internal import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = [
        Task(title: "Apply to 3 iOS roles", priority: .high),
        Task(title: "Finish SwiftUI Day 4", priority: .high),
        Task(title: "Push project to GitHub", priority: .medium),
        Task(title: "Buy coffee", priority: .low)
    ]

    func addTask(title: String, priority: Priority) {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        tasks.append(Task(title: title, priority: priority))
    }

    func toggleDone(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isDone.toggle()
        }
    }

    func delete(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
}
