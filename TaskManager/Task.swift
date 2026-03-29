import Foundation
import SwiftUI

enum Priority: String, CaseIterable {
    case low    = "Low"
    case medium = "Medium"
    case high   = "High"

    var icon: String {
        switch self {
        case .low:    return "arrow.down.circle.fill"
        case .medium: return "minus.circle.fill"
        case .high:   return "exclamationmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .low:    return .blue
        case .medium: return .orange
        case .high:   return .red
        }
    }
}

struct Task: Identifiable {
    let id = UUID()
    var title: String
    var priority: Priority
    var isDone: Bool = false
}
