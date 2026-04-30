import SwiftUI

/// A saved article for offline reading.
struct ReadingListItem: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var urlString: String
    var excerpt: String
    var savedAt: Date
    var isRead: Bool
    var estimatedReadingMinutes: Int

    init(title: String, urlString: String, excerpt: String = "", estimatedReadingMinutes: Int = 3) {
        self.id = UUID()
        self.title = title
        self.urlString = urlString
        self.excerpt = excerpt
        self.savedAt = Date()
        self.isRead = false
        self.estimatedReadingMinutes = estimatedReadingMinutes
    }

    var url: URL? { URL(string: urlString) }

    var displayDomain: String {
        url?.host?.replacingOccurrences(of: "www.", with: "") ?? urlString
    }
}

/// Manages a reading list for saving articles to read later.
@MainActor
final class ReadingListManager: ObservableObject {
    @Published var items: [ReadingListItem] = []

    private let storageKey = "readingList"

    init() {
        loadItems()
    }

    var unreadItems: [ReadingListItem] {
        items.filter { !$0.isRead }
    }

    var readItems: [ReadingListItem] {
        items.filter { $0.isRead }
    }

    var unreadCount: Int { unreadItems.count }

    func isSaved(urlString: String) -> Bool {
        items.contains { $0.urlString == urlString }
    }

    func addItem(title: String, urlString: String, excerpt: String = "") {
        guard !isSaved(urlString: urlString) else { return }

        // Estimate reading time: ~200 words/min, ~5 words/line, ~50 lines avg
        let estimatedMinutes = max(1, excerpt.split(separator: " ").count / 200)

        let item = ReadingListItem(
            title: title,
            urlString: urlString,
            excerpt: excerpt,
            estimatedReadingMinutes: max(1, estimatedMinutes)
        )
        items.insert(item, at: 0)
        saveItems()
    }

    func removeItem(_ item: ReadingListItem) {
        items.removeAll { $0.id == item.id }
        saveItems()
    }

    func removeByURL(_ urlString: String) {
        items.removeAll { $0.urlString == urlString }
        saveItems()
    }

    func markAsRead(_ item: ReadingListItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isRead = true
            saveItems()
        }
    }

    func toggleRead(_ item: ReadingListItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isRead.toggle()
            saveItems()
        }
    }

    // MARK: - Persistence

    private func saveItems() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadItems() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let saved = try? JSONDecoder().decode([ReadingListItem].self, from: data) else { return }
        items = saved
    }
}
