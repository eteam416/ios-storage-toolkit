import SwiftUI
import RevenueCat

@main
struct AegisShieldApp: App {
    @StateObject private var appState = AppStateManager()
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var searchEngineManager = SearchEngineManager()
    @StateObject private var adBlockManager = AdBlockManager()
    @StateObject private var bookmarkManager = BookmarkManager()
    @StateObject private var historyManager = HistoryManager()
    @StateObject private var readingListManager = ReadingListManager()
    @StateObject private var notesManager = NotesManager()
    @StateObject private var rewardsManager = UsageRewardsManager()
    @StateObject private var analyticsManager = AnalyticsManager()

    init() {
        configureRevenueCat()
        configureFirebase()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(subscriptionManager)
                .environmentObject(languageManager)
                .environmentObject(searchEngineManager)
                .environmentObject(adBlockManager)
                .environmentObject(bookmarkManager)
                .environmentObject(historyManager)
                .environmentObject(readingListManager)
                .environmentObject(notesManager)
                .environmentObject(rewardsManager)
                .environmentObject(analyticsManager)
                .environment(\.locale, languageManager.currentLocale)
                .environment(\.layoutDirection, languageManager.layoutDirection)
                .task {
                    await adBlockManager.compileRules()
                    await subscriptionManager.loadEntitlements()
                }
        }
    }

    private func configureRevenueCat() {
        Purchases.logLevel = .warn
        Purchases.configure(
            with: .init(withAPIKey: Configuration.revenueCatAPIKey)
        )
    }

    private func configureFirebase() {
        AnalyticsManager.configureFirebase()
    }
}
