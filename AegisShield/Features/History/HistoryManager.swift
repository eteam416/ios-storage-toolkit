import SwiftUI

/// A single browsing history entry.
struct HistoryEntry: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let urlString: String
    let visitedAt: Date

    init(title: String, urlString: String) {
        self.id = UUID()
        self.title = title
        self.urlString = urlString
        self.visitedAt = Date()
    }

    var url: URL? { URL(string: urlString) }

    var displayDomain: String {
        url?.host?.replacingOccurrences(of: "www.", with: "") ?? urlString
    }
}

/// Manages browsing history with search and date grouping.
@MainActor
final class HistoryManager: ObservableObject {
    @Published var entries: [HistoryEntry] = []

    private let storageKey = "browsingHistory"
    private let maxEntries = 5000

    init() {
        loadHistory()
    }

    // MARK: - Add Entry

    func addEntry(title: String, urlString: String) {
        // Skip empty or about: URLs
        guard !urlString.isEmpty, !urlString.hasPrefix("about:") else { return }

        // Remove duplicate if same URL was recently visited
        if let lastEntry = entries.first, lastEntry.urlString == urlString {
            return
        }

        let entry = HistoryEntry(title: title, urlString: urlString)
        entries.insert(entry, at: 0)

        // Cap history size
        if entries.count > maxEntries {
            entries = Array(entries.prefix(maxEntries))
        }

        saveHistory()
    }

    // MARK: - Search

    func search(_ query: String) -> [HistoryEntry] {
        guard !query.isEmpty else { return entries }
        return entries.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.urlString.localizedCaseInsensitiveContains(query)
        }
    }

    // MARK: - Grouped by Date

    func groupedByDate() -> [(String, [HistoryEntry])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: entries) { entry -> String in
            if calendar.isDateInToday(entry.visitedAt) {
                return String(localized: "today_label")
            } else if calendar.isDateInYesterday(entry.visitedAt) {
                return String(localized: "yesterday_label")
            } else if calendar.isDate(entry.visitedAt, equalTo: Date(), toGranularity: .weekOfYear) {
                return String(localized: "this_week_label")
            } else if calendar.isDate(entry.visitedAt, equalTo: Date(), toGranularity: .month) {
                return String(localized: "this_month_label")
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM yyyy"
                return formatter.string(from: entry.visitedAt)
            }
        }

        let order = [
            String(localized: "today_label"),
            String(localized: "yesterday_label"),
            String(localized: "this_week_label"),
            String(localized: "this_month_label"),
        ]

        return grouped.sorted { a, b in
            let aIndex = order.firstIndex(of: a.key) ?? Int.max
            let bIndex = order.firstIndex(of: b.key) ?? Int.max
            return aIndex < bIndex
        }
    }

    // MARK: - Most Visited

    func mostVisited(limit: Int = 8) -> [(String, String, Int)] {
        var domainCounts: [String: (title: String, url: String, count: Int)] = [:]

        for entry in entries {
            let domain = entry.displayDomain
            if let existing = domainCounts[domain] {
                domainCounts[domain] = (existing.title, existing.url, existing.count + 1)
            } else {
                domainCounts[domain] = (entry.title, entry.urlString, 1)
            }
        }

        return domainCounts.values
            .sorted { $0.count > $1.count }
            .prefix(limit)
            .map { ($0.title, $0.url, $0.count) }
    }

    // MARK: - Delete

    func deleteEntry(_ entry: HistoryEntry) {
        entries.removeAll { $0.id == entry.id }
        saveHistory()
    }

    func clearHistory() {
        entries.removeAll()
        saveHistory()
    }

    func clearToday() {
        let calendar = Calendar.current
        entries.removeAll { calendar.isDateInToday($0.visitedAt) }
        saveHistory()
    }

    // MARK: - Stats

    var totalPageViews: Int { entries.count }

    var uniqueDomains: Int {
        Set(entries.map { $0.displayDomain }).count
    }

    // MARK: - Persistence

    private func saveHistory() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let saved = try? JSONDecoder().decode([HistoryEntry].self, from: data) else { return }
        entries = saved
    }
}
