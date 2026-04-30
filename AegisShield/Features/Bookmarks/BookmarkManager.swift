import SwiftUI

/// A single bookmark entry.
struct Bookmark: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var urlString: String
    var favicon: String?
    var folderID: UUID?
    var createdAt: Date
    var isFavorite: Bool

    init(title: String, urlString: String, favicon: String? = nil, folderID: UUID? = nil, isFavorite: Bool = false) {
        self.id = UUID()
        self.title = title
        self.urlString = urlString
        self.favicon = favicon
        self.folderID = folderID
        self.createdAt = Date()
        self.isFavorite = isFavorite
    }

    var url: URL? { URL(string: urlString) }

    var displayDomain: String {
        url?.host?.replacingOccurrences(of: "www.", with: "") ?? urlString
    }
}

/// A bookmark folder for organization.
struct BookmarkFolder: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var iconName: String
    var createdAt: Date

    init(name: String, iconName: String = "folder") {
        self.id = UUID()
        self.name = name
        self.iconName = iconName
        self.createdAt = Date()
    }
}

/// Manages bookmarks and bookmark folders with persistence.
@MainActor
final class BookmarkManager: ObservableObject {
    @Published var bookmarks: [Bookmark] = []
    @Published var folders: [BookmarkFolder] = []

    private let bookmarksKey = "savedBookmarks"
    private let foldersKey = "savedFolders"

    init() {
        loadBookmarks()
        loadFolders()
    }

    // MARK: - Bookmark Operations

    var favorites: [Bookmark] {
        bookmarks.filter { $0.isFavorite }
    }

    func bookmarks(in folder: BookmarkFolder?) -> [Bookmark] {
        bookmarks.filter { $0.folderID == folder?.id }
    }

    var unfolderedBookmarks: [Bookmark] {
        bookmarks.filter { $0.folderID == nil }
    }

    func isBookmarked(urlString: String) -> Bool {
        bookmarks.contains { $0.urlString == urlString }
    }

    func addBookmark(title: String, urlString: String, favicon: String? = nil, folderID: UUID? = nil, isFavorite: Bool = false) {
        guard !isBookmarked(urlString: urlString) else { return }
        let bookmark = Bookmark(title: title, urlString: urlString, favicon: favicon, folderID: folderID, isFavorite: isFavorite)
        bookmarks.insert(bookmark, at: 0)
        saveBookmarks()
    }

    func removeBookmark(urlString: String) {
        bookmarks.removeAll { $0.urlString == urlString }
        saveBookmarks()
    }

    func removeBookmark(_ bookmark: Bookmark) {
        bookmarks.removeAll { $0.id == bookmark.id }
        saveBookmarks()
    }

    func toggleFavorite(_ bookmark: Bookmark) {
        if let index = bookmarks.firstIndex(where: { $0.id == bookmark.id }) {
            bookmarks[index].isFavorite.toggle()
            saveBookmarks()
        }
    }

    func moveBookmark(_ bookmark: Bookmark, to folder: BookmarkFolder?) {
        if let index = bookmarks.firstIndex(where: { $0.id == bookmark.id }) {
            bookmarks[index].folderID = folder?.id
            saveBookmarks()
        }
    }

    func updateBookmark(_ bookmark: Bookmark, title: String, urlString: String) {
        if let index = bookmarks.firstIndex(where: { $0.id == bookmark.id }) {
            bookmarks[index].title = title
            bookmarks[index].urlString = urlString
            saveBookmarks()
        }
    }

    // MARK: - Folder Operations

    func addFolder(name: String, iconName: String = "folder") {
        let folder = BookmarkFolder(name: name, iconName: iconName)
        folders.append(folder)
        saveFolders()
    }

    func removeFolder(_ folder: BookmarkFolder) {
        // Move bookmarks out of folder before deleting
        for i in bookmarks.indices where bookmarks[i].folderID == folder.id {
            bookmarks[i].folderID = nil
        }
        folders.removeAll { $0.id == folder.id }
        saveFolders()
        saveBookmarks()
    }

    func renameFolder(_ folder: BookmarkFolder, to name: String) {
        if let index = folders.firstIndex(where: { $0.id == folder.id }) {
            folders[index].name = name
            saveFolders()
        }
    }

    // MARK: - Persistence

    private func saveBookmarks() {
        if let data = try? JSONEncoder().encode(bookmarks) {
            UserDefaults.standard.set(data, forKey: bookmarksKey)
        }
    }

    private func loadBookmarks() {
        guard let data = UserDefaults.standard.data(forKey: bookmarksKey),
              let saved = try? JSONDecoder().decode([Bookmark].self, from: data) else { return }
        bookmarks = saved
    }

    private func saveFolders() {
        if let data = try? JSONEncoder().encode(folders) {
            UserDefaults.standard.set(data, forKey: foldersKey)
        }
    }

    private func loadFolders() {
        guard let data = UserDefaults.standard.data(forKey: foldersKey),
              let saved = try? JSONDecoder().decode([BookmarkFolder].self, from: data) else { return }
        folders = saved
    }
}
