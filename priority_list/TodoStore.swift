//
//  TodoStore.swift
//  priority_list
//

import SwiftUI

// MARK: - 象限类型（艾森豪威尔矩阵）
enum QuadrantType: String, CaseIterable, Codable {
    case importantUrgent = "importantUrgent"
    case importantNotUrgent = "importantNotUrgent"
    case notImportantUrgent = "notImportantUrgent"
    case notImportantNotUrgent = "notImportantNotUrgent"

    var title: String {
        switch self {
        case .importantUrgent: return "重要且紧急"
        case .importantNotUrgent: return "重要不紧急"
        case .notImportantUrgent: return "不重要但紧急"
        case .notImportantNotUrgent: return "不重要不紧急"
        }
    }

    var color: Color {
        switch self {
        case .importantUrgent: return .red
        case .importantNotUrgent: return .orange
        case .notImportantUrgent: return .purple
        case .notImportantNotUrgent: return .green
        }
    }
}

// MARK: - 待办项
struct TodoItem: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var quadrant: QuadrantType
    var createdAt: Date

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, quadrant: QuadrantType, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.quadrant = quadrant
        self.createdAt = createdAt
    }
}

// MARK: - 数据存储与持久化
@Observable
final class TodoStore {
    var items: [TodoItem] = [] {
        didSet { save() }
    }

    private let key = "priority_list_todos"

    init() {
        load()
    }

    func tasks(for quadrant: QuadrantType) -> [TodoItem] {
        items.filter { $0.quadrant == quadrant }
    }

    func toggleCompletion(_ item: TodoItem) {
        guard let i = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[i].isCompleted.toggle()
    }

    func delete(_ item: TodoItem) {
        items.removeAll { $0.id == item.id }
    }

    func add(title: String, quadrant: QuadrantType) {
        let new = TodoItem(title: title, quadrant: quadrant)
        items.append(new)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([TodoItem].self, from: data) else { return }
        items = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
