import Foundation

enum Priority: String, CaseIterable {
    case low    = "Low"
    case medium = "Medium"
    case high   = "High"

    var icon: String {
        switch self {
        case .low:    return "low"
        case .medium: return "medium"
        case .high:   return "high"
        }
    }
}

struct Task: Identifiable {
    let id = UUID()
    var title: String
    var priority: Priority
    var isDone: Bool = false
}
