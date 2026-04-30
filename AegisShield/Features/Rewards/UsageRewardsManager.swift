import SwiftUI

/// Tracks user engagement: daily streaks, milestones, and achievement badges.
/// Designed to make users feel valued and encourage daily app usage.
@MainActor
final class UsageRewardsManager: ObservableObject {
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var totalDaysUsed: Int = 0
    @Published var totalAdsBlocked: Int = 0
    @Published var totalTrackersBlocked: Int = 0
    @Published var totalPagesViewed: Int = 0
    @Published var unlockedBadges: Set<Badge> = []

    @AppStorage("lastUsageDate") private var lastUsageDateString: String = ""
    @AppStorage("currentStreak") private var savedStreak: Int = 0
    @AppStorage("longestStreak") private var savedLongestStreak: Int = 0
    @AppStorage("totalDaysUsed") private var savedTotalDays: Int = 0
    @AppStorage("totalAdsBlockedLifetime") private var savedAdsBlocked: Int = 0
    @AppStorage("totalTrackersBlockedLifetime") private var savedTrackersBlocked: Int = 0
    @AppStorage("totalPagesViewedLifetime") private var savedPagesViewed: Int = 0
    @AppStorage("unlockedBadgeIDs") private var savedBadgeIDs: String = ""

    // MARK: - Badges

    enum Badge: String, CaseIterable, Identifiable {
        case firstDay = "first_day"
        case weekStreak = "week_streak"
        case monthStreak = "month_streak"
        case adBlocker100 = "ad_blocker_100"
        case adBlocker1000 = "ad_blocker_1000"
        case adBlocker10000 = "ad_blocker_10000"
        case trackerHunter100 = "tracker_hunter_100"
        case trackerHunter1000 = "tracker_hunter_1000"
        case pageExplorer100 = "page_explorer_100"
        case pageExplorer1000 = "page_explorer_1000"
        case privacyChampion = "privacy_champion"
        case speedDemon = "speed_demon"

        var id: String { rawValue }

        var name: String {
            switch self {
            case .firstDay: return String(localized: "badge_first_day")
            case .weekStreak: return String(localized: "badge_week_streak")
            case .monthStreak: return String(localized: "badge_month_streak")
            case .adBlocker100: return String(localized: "badge_ad_blocker_100")
            case .adBlocker1000: return String(localized: "badge_ad_blocker_1000")
            case .adBlocker10000: return String(localized: "badge_ad_blocker_10000")
            case .trackerHunter100: return String(localized: "badge_tracker_hunter_100")
            case .trackerHunter1000: return String(localized: "badge_tracker_hunter_1000")
            case .pageExplorer100: return String(localized: "badge_page_explorer_100")
            case .pageExplorer1000: return String(localized: "badge_page_explorer_1000")
            case .privacyChampion: return String(localized: "badge_privacy_champion")
            case .speedDemon: return String(localized: "badge_speed_demon")
            }
        }

        var description: String {
            switch self {
            case .firstDay: return String(localized: "badge_first_day_desc")
            case .weekStreak: return String(localized: "badge_week_streak_desc")
            case .monthStreak: return String(localized: "badge_month_streak_desc")
            case .adBlocker100: return String(localized: "badge_ad_blocker_100_desc")
            case .adBlocker1000: return String(localized: "badge_ad_blocker_1000_desc")
            case .adBlocker10000: return String(localized: "badge_ad_blocker_10000_desc")
            case .trackerHunter100: return String(localized: "badge_tracker_hunter_100_desc")
            case .trackerHunter1000: return String(localized: "badge_tracker_hunter_1000_desc")
            case .pageExplorer100: return String(localized: "badge_page_explorer_100_desc")
            case .pageExplorer1000: return String(localized: "badge_page_explorer_1000_desc")
            case .privacyChampion: return String(localized: "badge_privacy_champion_desc")
            case .speedDemon: return String(localized: "badge_speed_demon_desc")
            }
        }

        var iconName: String {
            switch self {
            case .firstDay: return "star"
            case .weekStreak: return "flame"
            case .monthStreak: return "flame.fill"
            case .adBlocker100: return "shield"
            case .adBlocker1000: return "shield.fill"
            case .adBlocker10000: return "shield.checkered"
            case .trackerHunter100: return "eye.slash"
            case .trackerHunter1000: return "eye.slash.fill"
            case .pageExplorer100: return "globe"
            case .pageExplorer1000: return "globe.americas.fill"
            case .privacyChampion: return "lock.shield"
            case .speedDemon: return "bolt"
            }
        }

        var color: Color {
            switch self {
            case .firstDay: return .yellow
            case .weekStreak, .monthStreak: return .orange
            case .adBlocker100: return .blue
            case .adBlocker1000: return .indigo
            case .adBlocker10000: return .purple
            case .trackerHunter100: return .teal
            case .trackerHunter1000: return .cyan
            case .pageExplorer100: return .green
            case .pageExplorer1000: return .mint
            case .privacyChampion: return .red
            case .speedDemon: return .yellow
            }
        }
    }

    // MARK: - Initialization

    init() {
        loadState()
    }

    /// Call from the view's .task modifier so badge notifications
    /// fire after onChange handlers are registered.
    func recordInitialUsage() {
        recordDailyUsage()
    }

    // MARK: - Daily Usage

    func recordDailyUsage() {
        let today = dateString(for: Date())

        if lastUsageDateString == today {
            return
        }

        let yesterday = dateString(for: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date())

        if lastUsageDateString == yesterday {
            currentStreak += 1
        } else if !lastUsageDateString.isEmpty {
            currentStreak = 1
        } else {
            currentStreak = 1
        }

        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }

        totalDaysUsed += 1
        lastUsageDateString = today

        checkBadges()
        saveState()
    }

    // MARK: - Stats Update

    func recordAdsBlocked(_ count: Int) {
        totalAdsBlocked += count
        checkBadges()
        saveState()
    }

    func recordTrackersBlocked(_ count: Int) {
        totalTrackersBlocked += count
        checkBadges()
        saveState()
    }

    func recordPageView() {
        totalPagesViewed += 1
        checkBadges()
        saveState()
    }

    // MARK: - Badge Checking

    @Published var pendingBadgeNotifications: [Badge] = []

    /// Pops the next badge from the notification queue.
    func consumeBadgeNotification() {
        guard !pendingBadgeNotifications.isEmpty else { return }
        pendingBadgeNotifications.removeFirst()
    }

    private func checkBadges() {
        var newBadges: [Badge] = []

        if totalDaysUsed >= 1 && !unlockedBadges.contains(.firstDay) {
            newBadges.append(.firstDay)
        }
        if currentStreak >= 7 && !unlockedBadges.contains(.weekStreak) {
            newBadges.append(.weekStreak)
        }
        if currentStreak >= 30 && !unlockedBadges.contains(.monthStreak) {
            newBadges.append(.monthStreak)
        }
        if totalAdsBlocked >= 100 && !unlockedBadges.contains(.adBlocker100) {
            newBadges.append(.adBlocker100)
        }
        if totalAdsBlocked >= 1000 && !unlockedBadges.contains(.adBlocker1000) {
            newBadges.append(.adBlocker1000)
        }
        if totalAdsBlocked >= 10000 && !unlockedBadges.contains(.adBlocker10000) {
            newBadges.append(.adBlocker10000)
        }
        if totalTrackersBlocked >= 100 && !unlockedBadges.contains(.trackerHunter100) {
            newBadges.append(.trackerHunter100)
        }
        if totalTrackersBlocked >= 1000 && !unlockedBadges.contains(.trackerHunter1000) {
            newBadges.append(.trackerHunter1000)
        }
        if totalPagesViewed >= 100 && !unlockedBadges.contains(.pageExplorer100) {
            newBadges.append(.pageExplorer100)
        }
        if totalPagesViewed >= 1000 && !unlockedBadges.contains(.pageExplorer1000) {
            newBadges.append(.pageExplorer1000)
        }
        if totalDaysUsed >= 14 && totalAdsBlocked >= 500 && !unlockedBadges.contains(.privacyChampion) {
            newBadges.append(.privacyChampion)
        }
        if totalPagesViewed >= 200 && currentStreak >= 3 && !unlockedBadges.contains(.speedDemon) {
            newBadges.append(.speedDemon)
        }

        for badge in newBadges {
            unlockedBadges.insert(badge)
            pendingBadgeNotifications.append(badge)
        }
    }

    // MARK: - Milestones

    var nextMilestone: String {
        if totalAdsBlocked < 100 {
            return String(localized: "milestone_100_ads")
        } else if totalAdsBlocked < 1000 {
            return String(localized: "milestone_1000_ads")
        } else if currentStreak < 7 {
            return String(localized: "milestone_7_day_streak")
        } else if currentStreak < 30 {
            return String(localized: "milestone_30_day_streak")
        } else {
            return String(localized: "milestone_legend")
        }
    }

    var progressToNextMilestone: Double {
        if totalAdsBlocked < 100 {
            return Double(totalAdsBlocked) / 100.0
        } else if totalAdsBlocked < 1000 {
            return Double(totalAdsBlocked) / 1000.0
        } else if currentStreak < 7 {
            return Double(currentStreak) / 7.0
        } else if currentStreak < 30 {
            return Double(currentStreak) / 30.0
        }
        return 1.0
    }

    // MARK: - Helpers

    private func dateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter.string(from: date)
    }

    // MARK: - Persistence

    private func saveState() {
        savedStreak = currentStreak
        savedLongestStreak = longestStreak
        savedTotalDays = totalDaysUsed
        savedAdsBlocked = totalAdsBlocked
        savedTrackersBlocked = totalTrackersBlocked
        savedPagesViewed = totalPagesViewed
        savedBadgeIDs = unlockedBadges.map { $0.rawValue }.joined(separator: ",")
    }

    private func loadState() {
        currentStreak = savedStreak
        longestStreak = savedLongestStreak
        totalDaysUsed = savedTotalDays
        totalAdsBlocked = savedAdsBlocked
        totalTrackersBlocked = savedTrackersBlocked
        totalPagesViewed = savedPagesViewed

        if !savedBadgeIDs.isEmpty {
            unlockedBadges = Set(savedBadgeIDs.split(separator: ",").compactMap { Badge(rawValue: String($0)) })
        }
    }
}
