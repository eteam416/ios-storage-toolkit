import SwiftUI
// Note: Import FirebaseAnalytics and FirebaseCrashlytics in production build.
// Commented out here to allow compilation without Firebase configured.
// import FirebaseAnalytics
// import FirebaseCrashlytics
// import FirebaseCore

/// Privacy-safe analytics manager.
/// Tracks only product-improvement signals. No PII, no full URLs, no data selling.
///
/// Design Principles:
/// - Minimal collection: only what's needed to improve the product
/// - No PII: never log user-identifiable information
/// - No full URLs: only domain categories (e.g., "social", "news", "shopping")
/// - Consent-aware: respect user preferences and regional regulations
/// - Transparent: event schema is documented and auditable
@MainActor
final class AnalyticsManager: ObservableObject {
    @Published var isAnalyticsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isAnalyticsEnabled, forKey: "analyticsEnabled")
        }
    }

    init() {
        self.isAnalyticsEnabled = UserDefaults.standard.object(forKey: "analyticsEnabled") as? Bool ?? true
    }

    // MARK: - Firebase Configuration

    static func configureFirebase() {
        // In production, call FirebaseApp.configure() here.
        // Requires GoogleService-Info.plist in the bundle.
        // FirebaseApp.configure()
    }

    // MARK: - Event Logging

    func logEvent(_ event: AnalyticsEvent) {
        guard isAnalyticsEnabled else { return }
        guard Configuration.analyticsEnabled else { return }

        // In production, use Firebase Analytics:
        // Analytics.logEvent(event.name, parameters: event.parameters)

        #if DEBUG
        print("[Analytics] \(event.name): \(event.parameters ?? [:])")
        #endif
    }

    // MARK: - Crash Reporting

    func logError(_ error: Error, context: String) {
        guard Configuration.crashlyticsEnabled else { return }
        // In production:
        // Crashlytics.crashlytics().record(error: error, userInfo: ["context": context])

        #if DEBUG
        print("[Crashlytics] \(context): \(error.localizedDescription)")
        #endif
    }

    // MARK: - Predefined Events

    func logAppLaunch() {
        logEvent(.appLaunch)
    }

    func logOnboardingComplete() {
        logEvent(.onboardingComplete)
    }

    func logPaywallViewed() {
        logEvent(.paywallViewed)
    }

    func logPurchaseStarted(productID: String) {
        logEvent(.purchaseStarted(productID: productID))
    }

    func logPurchaseCompleted(productID: String) {
        logEvent(.purchaseCompleted(productID: productID))
    }

    func logSearchEngineChanged(engineID: String) {
        logEvent(.searchEngineChanged(engineID: engineID))
    }

    func logAdBlockStats(adsBlocked: Int, trackersBlocked: Int) {
        logEvent(.adBlockStats(adsBlocked: adsBlocked, trackersBlocked: trackersBlocked))
    }

    func logIncognitoSessionStarted() {
        logEvent(.incognitoSessionStarted)
    }

    func logPageLoadPerformance(durationMS: Int, domainCategory: String) {
        logEvent(.pageLoadPerformance(durationMS: durationMS, domainCategory: domainCategory))
    }

    func logLanguageSelected(languageCode: String) {
        logEvent(.languageSelected(languageCode: languageCode))
    }

    func logTabCount(count: Int) {
        logEvent(.tabCount(count: count))
    }
}

// MARK: - Analytics Event Schema

/// Typed event definitions with documented purpose and retention rationale.
///
/// | Event Name | Parameters | Purpose | Retention Rationale |
/// |---|---|---|---|
/// | app_launch | - | Track daily active users | Core product metric |
/// | onboarding_complete | - | Measure onboarding funnel | Conversion optimization |
/// | paywall_viewed | - | Track paywall impressions | Revenue optimization |
/// | purchase_started | product_id | Track purchase funnel | Revenue metric |
/// | purchase_completed | product_id | Track conversions | Revenue metric |
/// | search_engine_changed | engine_id | Understand user preferences | Feature prioritization |
/// | adblock_stats | ads_blocked, trackers_blocked | Measure feature value | Product validation |
/// | incognito_session_started | - | Track feature usage | Feature prioritization |
/// | page_load_performance | duration_ms, domain_category | Monitor performance | Quality assurance |
/// | language_selected | language_code | Understand user base | Localization priority |
/// | tab_count | count | Understand usage patterns | UX optimization |
enum AnalyticsEvent {
    case appLaunch
    case onboardingComplete
    case paywallViewed
    case purchaseStarted(productID: String)
    case purchaseCompleted(productID: String)
    case searchEngineChanged(engineID: String)
    case adBlockStats(adsBlocked: Int, trackersBlocked: Int)
    case incognitoSessionStarted
    case pageLoadPerformance(durationMS: Int, domainCategory: String)
    case languageSelected(languageCode: String)
    case tabCount(count: Int)

    var name: String {
        switch self {
        case .appLaunch: return "app_launch"
        case .onboardingComplete: return "onboarding_complete"
        case .paywallViewed: return "paywall_viewed"
        case .purchaseStarted: return "purchase_started"
        case .purchaseCompleted: return "purchase_completed"
        case .searchEngineChanged: return "search_engine_changed"
        case .adBlockStats: return "adblock_stats"
        case .incognitoSessionStarted: return "incognito_session_started"
        case .pageLoadPerformance: return "page_load_performance"
        case .languageSelected: return "language_selected"
        case .tabCount: return "tab_count"
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .appLaunch, .onboardingComplete, .paywallViewed, .incognitoSessionStarted:
            return nil
        case .purchaseStarted(let productID):
            return ["product_id": productID]
        case .purchaseCompleted(let productID):
            return ["product_id": productID]
        case .searchEngineChanged(let engineID):
            return ["engine_id": engineID]
        case .adBlockStats(let adsBlocked, let trackersBlocked):
            return ["ads_blocked": adsBlocked, "trackers_blocked": trackersBlocked]
        case .pageLoadPerformance(let durationMS, let domainCategory):
            return ["duration_ms": durationMS, "domain_category": domainCategory]
        case .languageSelected(let languageCode):
            return ["language_code": languageCode]
        case .tabCount(let count):
            return ["count": count]
        }
    }
}
