import SwiftUI

/// Bookmarks browser with folders, favorites, and search.
struct BookmarksView: View {
    @EnvironmentObject private var bookmarkManager: BookmarkManager
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var showAddFolder = false
    @State private var newFolderName = ""
    @State private var selectedFolder: BookmarkFolder?
    let onOpenURL: (String) -> Void

    private var filteredBookmarks: [Bookmark] {
        if searchText.isEmpty {
            return selectedFolder == nil
                ? bookmarkManager.unfolderedBookmarks
                : bookmarkManager.bookmarks(in: selectedFolder)
        }
        return bookmarkManager.bookmarks.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.urlString.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                // Favorites section
                if selectedFolder == nil && searchText.isEmpty && !bookmarkManager.favorites.isEmpty {
                    Section(String(localized: "favorites_section")) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AegisSpacing.sm) {
                                ForEach(bookmarkManager.favorites) { bookmark in
                                    favoriteCell(bookmark)
                                }
                            }
                            .padding(.vertical, AegisSpacing.xxs)
                        }
                    }
                }

                // Folders section
                if selectedFolder == nil && searchText.isEmpty && !bookmarkManager.folders.isEmpty {
                    Section(String(localized: "folders_section")) {
                        ForEach(bookmarkManager.folders) { folder in
                            Button {
                                selectedFolder = folder
                            } label: {
                                HStack {
                                    Image(systemName: folder.iconName)
                                        .foregroundStyle(AegisColors.brandAccent)
                                        .frame(width: 24)
                                    Text(folder.name)
                                        .foregroundStyle(AegisColors.textPrimary)
                                    Spacer()
                                    Text("\(bookmarkManager.bookmarks(in: folder).count)")
                                        .foregroundStyle(AegisColors.textTertiary)
                                        .font(AegisTypography.captionSmall)
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(AegisColors.textTertiary)
                                        .font(.caption)
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    bookmarkManager.removeFolder(folder)
                                } label: {
                                    Label(String(localized: "delete_button"), systemImage: "trash")
                                }
                            }
                        }
                    }
                }

                // Bookmarks section
                Section(selectedFolder?.name ?? String(localized: "all_bookmarks_section")) {
                    if filteredBookmarks.isEmpty {
                        Text(String(localized: "no_bookmarks_message"))
                            .font(AegisTypography.bodySmall)
                            .foregroundStyle(AegisColors.textTertiary)
                    } else {
                        ForEach(filteredBookmarks) { bookmark in
                            bookmarkRow(bookmark)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: String(localized: "search_bookmarks_placeholder"))
            .navigationTitle(selectedFolder?.name ?? String(localized: "bookmarks_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if selectedFolder != nil {
                        Button(String(localized: "back_button")) {
                            selectedFolder = nil
                        }
                    } else {
                        Button(String(localized: "done_button")) {
                            dismiss()
                        }
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showAddFolder = true
                        } label: {
                            Label(String(localized: "new_folder_button"), systemImage: "folder.badge.plus")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert(String(localized: "new_folder_title"), isPresented: $showAddFolder) {
                TextField(String(localized: "folder_name_placeholder"), text: $newFolderName)
                Button(String(localized: "cancel_button"), role: .cancel) { newFolderName = "" }
                Button(String(localized: "create_button")) {
                    if !newFolderName.isEmpty {
                        bookmarkManager.addFolder(name: newFolderName)
                        newFolderName = ""
                    }
                }
            }
        }
    }

    // MARK: - Favorite Cell

    private func favoriteCell(_ bookmark: Bookmark) -> some View {
        Button {
            onOpenURL(bookmark.urlString)
            dismiss()
        } label: {
            VStack(spacing: AegisSpacing.xxs) {
                ZStack {
                    Circle()
                        .fill(AegisColors.brandAccent.opacity(0.12))
                        .frame(width: 48, height: 48)
                    Text(String(bookmark.displayDomain.prefix(2)).uppercased())
                        .font(AegisTypography.labelMedium)
                        .foregroundStyle(AegisColors.brandAccent)
                }
                Text(bookmark.title)
                    .font(AegisTypography.captionSmall)
                    .foregroundStyle(AegisColors.textPrimary)
                    .lineLimit(1)
                    .frame(width: 64)
            }
        }
    }

    // MARK: - Bookmark Row

    private func bookmarkRow(_ bookmark: Bookmark) -> some View {
        Button {
            onOpenURL(bookmark.urlString)
            dismiss()
        } label: {
            HStack(spacing: AegisSpacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AegisColors.brandAccent.opacity(0.08))
                        .frame(width: 36, height: 36)
                    Text(String(bookmark.displayDomain.prefix(1)).uppercased())
                        .font(AegisTypography.labelMedium)
                        .foregroundStyle(AegisColors.brandAccent)
                }

                VStack(alignment: .leading, spacing: AegisSpacing.xxxs) {
                    Text(bookmark.title)
                        .font(AegisTypography.bodyMedium)
                        .foregroundStyle(AegisColors.textPrimary)
                        .lineLimit(1)
                    Text(bookmark.displayDomain)
                        .font(AegisTypography.captionSmall)
                        .foregroundStyle(AegisColors.textTertiary)
                        .lineLimit(1)
                }

                Spacer()

                if bookmark.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                }
            }
        }
        .contextMenu {
            Button {
                bookmarkManager.toggleFavorite(bookmark)
            } label: {
                Label(
                    bookmark.isFavorite
                        ? String(localized: "remove_favorite_button")
                        : String(localized: "add_favorite_button"),
                    systemImage: bookmark.isFavorite ? "star.slash" : "star"
                )
            }

            Divider()

            Button(role: .destructive) {
                bookmarkManager.removeBookmark(bookmark)
            } label: {
                Label(String(localized: "delete_button"), systemImage: "trash")
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                bookmarkManager.removeBookmark(bookmark)
            } label: {
                Label(String(localized: "delete_button"), systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                bookmarkManager.toggleFavorite(bookmark)
            } label: {
                Label(
                    String(localized: "favorite_button"),
                    systemImage: bookmark.isFavorite ? "star.slash" : "star.fill"
                )
            }
            .tint(.yellow)
        }
    }
}
