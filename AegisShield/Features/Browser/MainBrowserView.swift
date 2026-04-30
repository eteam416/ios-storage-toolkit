import SwiftUI

/// Main browser view with tab management, smart bar, and toolbar.
struct MainBrowserView: View {
    @StateObject private var tabManager = TabManager()
    @EnvironmentObject private var searchEngineManager: SearchEngineManager
    @EnvironmentObject private var adBlockManager: AdBlockManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @EnvironmentObject private var bookmarkManager: BookmarkManager
    @EnvironmentObject private var historyManager: HistoryManager
    @EnvironmentObject private var readingListManager: ReadingListManager
    @EnvironmentObject private var rewardsManager: UsageRewardsManager

    @State private var showTabGrid = false
    @State private var showMenu = false
    @State private var showSettings = false
    @State private var showShareSheet = false
    @State private var showBookmarks = false
    @State private var showHistory = false
    @State private var showReadingList = false
    @State private var showNotes = false
    @State private var showReaderMode = false
    @State private var showRewards = false
    @State private var showBadgeUnlock = false
    @State private var showHome = true

    var body: some View {
        let isIncognito = tabManager.isIncognitoMode

        ZStack {
            // Background
            (isIncognito ? AegisColors.incognitoBackground : AegisColors.backgroundPrimary)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Incognito indicator
                if isIncognito {
                    incognitoIndicator
                }

                // Smart Bar
                if let tab = tabManager.activeTab {
                    SmartBarView(
                        urlString: Binding(
                            get: { tab.viewModel.urlString },
                            set: { tab.viewModel.urlString = $0 }
                        ),
                        isIncognito: isIncognito,
                        isLoading: tab.viewModel.isLoading,
                        isSecure: tab.viewModel.isSecure,
                        progress: tab.viewModel.estimatedProgress
                    ) { query in
                        showHome = false
                        tab.viewModel.loadURL(query, searchEngine: searchEngineManager.currentEngine)
                    }
                    .padding(.horizontal, AegisSpacing.sm)
                    .padding(.vertical, AegisSpacing.xs)
                }

                // Content area
                ZStack {
                    if showHome, let tab = tabManager.activeTab, tab.viewModel.currentURL == nil {
                        HomeView(
                            onQuickLink: { url in
                                showHome = false
                                tabManager.activeTab?.viewModel.loadURL(
                                    url,
                                    searchEngine: searchEngineManager.currentEngine
                                )
                            }
                        )
                    } else if let tab = tabManager.activeTab {
                        WebViewRepresentable(
                            viewModel: tab.viewModel,
                            isIncognito: tab.isIncognito
                        )
                    }

                    // Error overlay
                    if let error = tabManager.activeTab?.viewModel.errorMessage {
                        errorOverlay(error)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Bottom Toolbar
                if let tab = tabManager.activeTab {
                    BrowserToolbar(
                        viewModel: tab.viewModel,
                        tabManager: tabManager,
                        isIncognito: isIncognito,
                        onShowTabs: { showTabGrid = true },
                        onShowMenu: { showMenu = true },
                        onShare: { showShareSheet = true }
                    )
                }
            }
        }
        .sheet(isPresented: $showTabGrid) {
            TabGridView(tabManager: tabManager)
        }
        .sheet(isPresented: $showMenu) {
            BrowserMenuView(
                tabManager: tabManager,
                onNewTab: {
                    tabManager.createNewTab(isIncognito: tabManager.isIncognitoMode)
                    showHome = true
                    showMenu = false
                },
                onSettings: {
                    showMenu = false
                    showSettings = true
                },
                onReload: {
                    tabManager.activeTab?.viewModel.reload()
                    showMenu = false
                },
                onBookmarks: {
                    showMenu = false
                    showBookmarks = true
                },
                onHistory: {
                    showMenu = false
                    showHistory = true
                },
                onReadingList: {
                    showMenu = false
                    showReadingList = true
                },
                onNotes: {
                    showMenu = false
                    showNotes = true
                },
                onReaderMode: {
                    showMenu = false
                    showReaderMode = true
                },
                onRewards: {
                    showMenu = false
                    showRewards = true
                },
                onAddBookmark: {
                    if let tab = tabManager.activeTab,
                       let urlString = tab.viewModel.currentURL?.absoluteString {
                        let title = tab.viewModel.pageTitle ?? urlString
                        if bookmarkManager.isBookmarked(urlString: urlString) {
                            bookmarkManager.removeBookmark(urlString: urlString)
                        } else {
                            bookmarkManager.addBookmark(title: title, urlString: urlString)
                        }
                    }
                    showMenu = false
                },
                onAddToReadingList: {
                    if let tab = tabManager.activeTab,
                       let urlString = tab.viewModel.currentURL?.absoluteString {
                        let title = tab.viewModel.pageTitle ?? urlString
                        readingListManager.addItem(title: title, urlString: urlString)
                    }
                    showMenu = false
                },
                currentPageBookmarked: tabManager.activeTab.flatMap {
                    $0.viewModel.currentURL?.absoluteString
                }.map { bookmarkManager.isBookmarked(urlString: $0) } ?? false,
                isIncognito: tabManager.isIncognitoMode
            )
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showBookmarks) {
            BookmarksView { urlString in
                showHome = false
                tabManager.activeTab?.viewModel.loadURL(urlString, searchEngine: searchEngineManager.currentEngine)
            }
        }
        .sheet(isPresented: $showHistory) {
            HistoryView { urlString in
                showHome = false
                tabManager.activeTab?.viewModel.loadURL(urlString, searchEngine: searchEngineManager.currentEngine)
            }
        }
        .sheet(isPresented: $showReadingList) {
            ReadingListView { urlString in
                showHome = false
                tabManager.activeTab?.viewModel.loadURL(urlString, searchEngine: searchEngineManager.currentEngine)
            }
        }
        .sheet(isPresented: $showNotes) {
            NotesView(
                currentURL: tabManager.activeTab?.viewModel.currentURL?.absoluteString,
                currentTitle: tabManager.activeTab?.viewModel.pageTitle,
                onOpenURL: { urlString in
                    showHome = false
                    tabManager.activeTab?.viewModel.loadURL(urlString, searchEngine: searchEngineManager.currentEngine)
                }
            )
        }
        .sheet(isPresented: $showReaderMode) {
            if let url = tabManager.activeTab?.viewModel.currentURL {
                ReaderModeView(
                    url: url,
                    title: tabManager.activeTab?.viewModel.pageTitle ?? ""
                )
            }
        }
        .sheet(isPresented: $showRewards) {
            RewardsView()
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = tabManager.activeTab?.viewModel.currentURL {
                ShareSheet(items: [url])
            }
        }
        .overlay {
            if showBadgeUnlock, let badge = rewardsManager.pendingBadgeNotifications.first {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showBadgeUnlock = false
                        rewardsManager.consumeBadgeNotification()
                    }

                BadgeUnlockOverlay(badge: badge) {
                    showBadgeUnlock = false
                    rewardsManager.consumeBadgeNotification()
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onChange(of: rewardsManager.pendingBadgeNotifications) { _, newValue in
            if !newValue.isEmpty && !showBadgeUnlock {
                withAnimation(.spring(response: 0.5)) {
                    showBadgeUnlock = true
                }
            }
        }
        .task {
            rewardsManager.recordInitialUsage()
        }
    }

    private var incognitoIndicator: some View {
        HStack(spacing: AegisSpacing.xs) {
            Image(systemName: "eye.slash.fill")
                .font(.caption)
            Text(String(localized: "incognito_mode_label"))
                .font(AegisTypography.captionSmall)
        }
        .foregroundStyle(AegisColors.incognitoAccent)
        .padding(.vertical, AegisSpacing.xxs)
        .padding(.horizontal, AegisSpacing.sm)
        .background(AegisColors.incognitoSurface)
        .clipShape(Capsule())
        .padding(.top, AegisSpacing.xxs)
    }

    @ViewBuilder
    private func errorOverlay(_ message: String) -> some View {
        VStack(spacing: AegisSpacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(AegisColors.warning)

            Text(String(localized: "page_load_error_title"))
                .font(AegisTypography.headlineSmall)

            Text(message)
                .font(AegisTypography.bodySmall)
                .foregroundStyle(AegisColors.textSecondary)
                .multilineTextAlignment(.center)

            AegisPrimaryButton(title: String(localized: "try_again_button")) {
                tabManager.activeTab?.viewModel.reload()
            }
            .frame(width: 200)
        }
        .padding(AegisSpacing.xl)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Browser Menu

struct BrowserMenuView: View {
    @ObservedObject var tabManager: TabManager
    let onNewTab: () -> Void
    let onSettings: () -> Void
    let onReload: () -> Void
    let onBookmarks: () -> Void
    let onHistory: () -> Void
    let onReadingList: () -> Void
    let onNotes: () -> Void
    let onReaderMode: () -> Void
    let onRewards: () -> Void
    let onAddBookmark: () -> Void
    let onAddToReadingList: () -> Void
    let currentPageBookmarked: Bool
    let isIncognito: Bool

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var adBlockManager: AdBlockManager
    @EnvironmentObject private var readingListManager: ReadingListManager
    @EnvironmentObject private var rewardsManager: UsageRewardsManager

    var body: some View {
        NavigationStack {
            List {
                // Quick actions for current page
                Section {
                    menuButton(
                        icon: currentPageBookmarked ? "bookmark.fill" : "bookmark",
                        title: currentPageBookmarked
                            ? String(localized: "remove_bookmark_menu")
                            : String(localized: "add_bookmark_menu")
                    ) {
                        onAddBookmark()
                    }

                    menuButton(
                        icon: "text.book.closed",
                        title: String(localized: "add_to_reading_list_menu")
                    ) {
                        onAddToReadingList()
                    }

                    menuButton(
                        icon: "doc.plaintext",
                        title: String(localized: "reader_mode_menu")
                    ) {
                        onReaderMode()
                    }
                }

                // Navigation
                Section {
                    menuButton(icon: "plus", title: String(localized: "new_tab_menu")) {
                        onNewTab()
                    }

                    menuButton(
                        icon: isIncognito ? "eye" : "eye.slash",
                        title: isIncognito
                            ? String(localized: "exit_incognito_menu")
                            : String(localized: "enter_incognito_menu")
                    ) {
                        tabManager.toggleIncognitoMode()
                        dismiss()
                    }

                    menuButton(icon: "arrow.clockwise", title: String(localized: "reload_menu")) {
                        onReload()
                    }
                }

                // Library
                Section(String(localized: "library_section")) {
                    menuButton(icon: "bookmark", title: String(localized: "bookmarks_menu")) {
                        onBookmarks()
                    }

                    menuButton(icon: "clock", title: String(localized: "history_menu")) {
                        onHistory()
                    }

                    menuButton(icon: "book", title: String(localized: "reading_list_menu")) {
                        onReadingList()
                    }
                    .badge(readingListManager.unreadCount)

                    menuButton(icon: "note.text", title: String(localized: "notes_menu")) {
                        onNotes()
                    }
                }

                // Engagement
                Section {
                    Button {
                        onRewards()
                    } label: {
                        HStack {
                            Label(String(localized: "rewards_menu"), systemImage: "flame.fill")
                            Spacer()
                            HStack(spacing: AegisSpacing.xxs) {
                                Image(systemName: "flame")
                                    .foregroundStyle(.orange)
                                Text("\(rewardsManager.currentStreak)")
                                    .font(AegisTypography.labelSmall)
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                }

                // Settings
                Section {
                    menuButton(icon: "gearshape", title: String(localized: "settings_menu")) {
                        onSettings()
                    }
                }

                if isIncognito {
                    Section {
                        menuButton(
                            icon: "trash",
                            title: String(localized: "close_all_incognito_menu")
                        ) {
                            tabManager.closeAllIncognitoTabs()
                            dismiss()
                        }
                        .foregroundStyle(AegisColors.error)
                    }
                }
            }
            .navigationTitle(String(localized: "menu_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "done_button")) {
                        dismiss()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func menuButton(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
