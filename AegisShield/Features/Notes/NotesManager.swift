import SwiftUI

/// A quick note taken while browsing.
struct BrowsingNote: Identifiable, Codable, Hashable {
    let id: UUID
    var content: String
    var associatedURL: String?
    var associatedTitle: String?
    var createdAt: Date
    var updatedAt: Date
    var color: NoteColor

    enum NoteColor: String, Codable, CaseIterable {
        case yellow, blue, green, pink, orange, purple

        var swiftUIColor: Color {
            switch self {
            case .yellow: return .yellow
            case .blue: return .blue
            case .green: return .green
            case .pink: return .pink
            case .orange: return .orange
            case .purple: return .purple
            }
        }

        var backgroundColor: Color {
            swiftUIColor.opacity(0.1)
        }
    }

    init(content: String, associatedURL: String? = nil, associatedTitle: String? = nil, color: NoteColor = .yellow) {
        self.id = UUID()
        self.content = content
        self.associatedURL = associatedURL
        self.associatedTitle = associatedTitle
        self.createdAt = Date()
        self.updatedAt = Date()
        self.color = color
    }

    var displayDomain: String? {
        guard let urlString = associatedURL, let url = URL(string: urlString) else { return nil }
        return url.host?.replacingOccurrences(of: "www.", with: "")
    }

    var preview: String {
        String(content.prefix(100))
    }
}

/// Manages quick notes taken while browsing.
@MainActor
final class NotesManager: ObservableObject {
    @Published var notes: [BrowsingNote] = []

    private let storageKey = "browsingNotes"

    init() {
        loadNotes()
    }

    var noteCount: Int { notes.count }

    func addNote(content: String, associatedURL: String? = nil, associatedTitle: String? = nil, color: BrowsingNote.NoteColor = .yellow) {
        let note = BrowsingNote(
            content: content,
            associatedURL: associatedURL,
            associatedTitle: associatedTitle,
            color: color
        )
        notes.insert(note, at: 0)
        saveNotes()
    }

    func updateNote(_ note: BrowsingNote, content: String) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].content = content
            notes[index].updatedAt = Date()
            saveNotes()
        }
    }

    func updateNoteColor(_ note: BrowsingNote, color: BrowsingNote.NoteColor) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].color = color
            saveNotes()
        }
    }

    func deleteNote(_ note: BrowsingNote) {
        notes.removeAll { $0.id == note.id }
        saveNotes()
    }

    func notesForURL(_ urlString: String) -> [BrowsingNote] {
        notes.filter { $0.associatedURL == urlString }
    }

    // MARK: - Persistence

    private func saveNotes() {
        if let data = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadNotes() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let saved = try? JSONDecoder().decode([BrowsingNote].self, from: data) else { return }
        notes = saved
    }
}
