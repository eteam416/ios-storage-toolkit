import SwiftUI

/// Home screen with quick shortcuts and privacy dashboard.
struct HomeView: View {
    @EnvironmentObject private var adBlockManager: AdBlockManager
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var searchEngineManager: SearchEngineManager
    let onQuickLink: (String) -> Void

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: AegisSpacing.lg) {
                // Privacy Dashboard
                privacyDashboard

                // Quick Shortcuts
                quickShortcuts

                // Search engine indicator
                searchEngineInfo
            }
            .padding(.horizontal, AegisSpacing.md)
            .padding(.vertical, AegisSpacing.lg)
        }
        .background(AegisColors.backgroundPrimary)
    }

    // MARK: - Privacy Dashboard

    private var privacyDashboard: some View {
        VStack(alignment: .leading, spacing: AegisSpacing.sm) {
            Text(String(localized: "privacy_dashboard_title"))
                .font(AegisTypography.headlineSmall)
                .foregroundStyle(AegisColors.textPrimary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AegisSpacing.sm) {
                StatCard(
                    title: String(localized: "ads_blocked_stat"),
                    value: "\(adBlockManager.stats.totalAdsBlocked)",
                    icon: "shield.lefthalf.filled",
                    color: AegisColors.statsAdsBlocked,
                    subtitle: String(localized: "exact_count_label")
                )

                StatCard(
                    title: String(localized: "trackers_blocked_stat"),
                    value: "\(adBlockManager.stats.totalTrackersBlocked)",
                    icon: "eye.slash",
                    color: AegisColors.statsTrackersBlocked,
                    subtitle: String(localized: "exact_count_label")
                )

                StatCard(
                    title: String(localized: "bandwidth_saved_stat"),
                    value: adBlockManager.stats.formattedBandwidthSaved,
                    icon: "arrow.down.circle",
                    color: AegisColors.statsBandwidthSaved,
                    subtitle: String(localized: "estimated_label")
                )

                StatCard(
                    title: String(localized: "time_saved_stat"),
                    value: adBlockManager.stats.formattedTimeSaved,
                    icon: "clock",
                    color: AegisColors.statsTimeSaved,
                    subtitle: String(localized: "estimated_label")
                )
            }
        }
    }

    // MARK: - Quick Shortcuts

    private var quickShortcuts: some View {
        VStack(alignment: .leading, spacing: AegisSpacing.sm) {
            Text(String(localized: "quick_shortcuts_title"))
                .font(AegisTypography.headlineSmall)
                .foregroundStyle(AegisColors.textPrimary)

            LazyVGrid(columns: columns, spacing: AegisSpacing.md) {
                ForEach(
                    QuickShortcut.shortcuts(
                        for: languageManager.selectedLanguage.id
                    )
                ) { shortcut in
                    QuickShortcutButton(shortcut: shortcut) {
                        onQuickLink(shortcut.url)
                    }
                }
            }
        }
    }

    // MARK: - Search Engine Info

    private var searchEngineInfo: some View {
        HStack(spacing: AegisSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .font(.caption)
                .foregroundStyle(AegisColors.textTertiary)

            Text(String(localized: "default_search_engine_label"))
                .font(AegisTypography.captionLarge)
                .foregroundStyle(AegisColors.textTertiary)

            Text(searchEngineManager.currentEngine.name)
                .font(AegisTypography.labelMedium)
                .foregroundStyle(AegisColors.brandAccent)
        }
        .padding(.top, AegisSpacing.sm)
    }
}

// MARK: - Quick Shortcut Model

struct QuickShortcut: Identifiable {
    let id = UUID()
    let name: String
    let url: String
    let icon: String
    let color: Color

    static func shortcuts(for languageCode: String) -> [QuickShortcut] {
        switch languageCode {
        case "zh-Hans":
            return chineseShortcuts
        case "ja":
            return japaneseShortcuts
        case "ko":
            return koreanShortcuts
        case "ar":
            return arabicShortcuts
        case "ru":
            return russianShortcuts
        case "hi":
            return indianShortcuts
        default:
            return defaultShortcuts
        }
    }

    static let defaultShortcuts: [QuickShortcut] = [
        QuickShortcut(name: "Google", url: "https://www.google.com", icon: "magnifyingglass", color: .blue),
        QuickShortcut(name: "YouTube", url: "https://www.youtube.com", icon: "play.rectangle", color: .red),
        QuickShortcut(name: "Wikipedia", url: "https://www.wikipedia.org", icon: "book", color: .gray),
        QuickShortcut(name: "Reddit", url: "https://www.reddit.com", icon: "bubble.left.and.bubble.right", color: .orange),
        QuickShortcut(name: "X", url: "https://x.com", icon: "at", color: .black),
        QuickShortcut(name: "Facebook", url: "https://www.facebook.com", icon: "person.2", color: .blue),
        QuickShortcut(name: "Instagram", url: "https://www.instagram.com", icon: "camera", color: .purple),
        QuickShortcut(name: "Amazon", url: "https://www.amazon.com", icon: "cart", color: .orange),
    ]

    static let chineseShortcuts: [QuickShortcut] = [
        QuickShortcut(name: "Baidu", url: "https://www.baidu.com", icon: "magnifyingglass", color: .blue),
        QuickShortcut(name: "Bilibili", url: "https://www.bilibili.com", icon: "play.rectangle", color: .cyan),
        QuickShortcut(name: "Weibo", url: "https://www.weibo.com", icon: "bubble.left", color: .red),
        QuickShortcut(name: "Zhihu", url: "https://www.zhihu.com", icon: "questionmark.circle", color: .blue),
        QuickShortcut(name: "Taobao", url: "https://www.taobao.com", icon: "cart", color: .orange),
        QuickShortcut(name: "JD", url: "https://www.jd.com", icon: "bag", color: .red),
        QuickShortcut(name: "Douyin", url: "https://www.douyin.com", icon: "music.note", color: .black),
        QuickShortcut(name: "WeChat", url: "https://weixin.qq.com", icon: "message", color: .green),
    ]

    static let japaneseShortcuts: [QuickShortcut] = [
        QuickShortcut(name: "Yahoo! Japan", url: "https://www.yahoo.co.jp", icon: "magnifyingglass", color: .red),
        QuickShortcut(name: "YouTube", url: "https://www.youtube.com", icon: "play.rectangle", color: .red),
        QuickShortcut(name: "Amazon JP", url: "https://www.amazon.co.jp", icon: "cart", color: .orange),
        QuickShortcut(name: "Rakuten", url: "https://www.rakuten.co.jp", icon: "bag", color: .red),
        QuickShortcut(name: "X", url: "https://x.com", icon: "at", color: .black),
        QuickShortcut(name: "Wikipedia", url: "https://ja.wikipedia.org", icon: "book", color: .gray),
        QuickShortcut(name: "NHK", url: "https://www3.nhk.or.jp", icon: "newspaper", color: .blue),
        QuickShortcut(name: "LINE", url: "https://line.me", icon: "message", color: .green),
    ]

    static let koreanShortcuts: [QuickShortcut] = [
        QuickShortcut(name: "Naver", url: "https://www.naver.com", icon: "magnifyingglass", color: .green),
        QuickShortcut(name: "YouTube", url: "https://www.youtube.com", icon: "play.rectangle", color: .red),
        QuickShortcut(name: "Daum", url: "https://www.daum.net", icon: "newspaper", color: .blue),
        QuickShortcut(name: "Coupang", url: "https://www.coupang.com", icon: "cart", color: .red),
        QuickShortcut(name: "KakaoTalk", url: "https://www.kakaocorp.com", icon: "message", color: .yellow),
        QuickShortcut(name: "Instagram", url: "https://www.instagram.com", icon: "camera", color: .purple),
        QuickShortcut(name: "X", url: "https://x.com", icon: "at", color: .black),
        QuickShortcut(name: "Wikipedia", url: "https://ko.wikipedia.org", icon: "book", color: .gray),
    ]

    static let arabicShortcuts: [QuickShortcut] = [
        QuickShortcut(name: "Google", url: "https://www.google.com", icon: "magnifyingglass", color: .blue),
        QuickShortcut(name: "YouTube", url: "https://www.youtube.com", icon: "play.rectangle", color: .red),
        QuickShortcut(name: "X", url: "https://x.com", icon: "at", color: .black),
        QuickShortcut(name: "Instagram", url: "https://www.instagram.com", icon: "camera", color: .purple),
        QuickShortcut(name: "Souq", url: "https://www.amazon.sa", icon: "cart", color: .orange),
        QuickShortcut(name: "Al Jazeera", url: "https://www.aljazeera.net", icon: "newspaper", color: .orange),
        QuickShortcut(name: "Wikipedia", url: "https://ar.wikipedia.org", icon: "book", color: .gray),
        QuickShortcut(name: "Facebook", url: "https://www.facebook.com", icon: "person.2", color: .blue),
    ]

    static let russianShortcuts: [QuickShortcut] = [
        QuickShortcut(name: "Yandex", url: "https://ya.ru", icon: "magnifyingglass", color: .red),
        QuickShortcut(name: "YouTube", url: "https://www.youtube.com", icon: "play.rectangle", color: .red),
        QuickShortcut(name: "VK", url: "https://vk.com", icon: "person.2", color: .blue),
        QuickShortcut(name: "Mail.ru", url: "https://mail.ru", icon: "envelope", color: .blue),
        QuickShortcut(name: "Ozon", url: "https://www.ozon.ru", icon: "cart", color: .blue),
        QuickShortcut(name: "Telegram", url: "https://web.telegram.org", icon: "paperplane", color: .blue),
        QuickShortcut(name: "Wikipedia", url: "https://ru.wikipedia.org", icon: "book", color: .gray),
        QuickShortcut(name: "Habr", url: "https://habr.com", icon: "doc.text", color: .teal),
    ]

    static let indianShortcuts: [QuickShortcut] = [
        QuickShortcut(name: "Google", url: "https://www.google.co.in", icon: "magnifyingglass", color: .blue),
        QuickShortcut(name: "YouTube", url: "https://www.youtube.com", icon: "play.rectangle", color: .red),
        QuickShortcut(name: "Flipkart", url: "https://www.flipkart.com", icon: "cart", color: .yellow),
        QuickShortcut(name: "Amazon IN", url: "https://www.amazon.in", icon: "bag", color: .orange),
        QuickShortcut(name: "Instagram", url: "https://www.instagram.com", icon: "camera", color: .purple),
        QuickShortcut(name: "X", url: "https://x.com", icon: "at", color: .black),
        QuickShortcut(name: "Wikipedia", url: "https://hi.wikipedia.org", icon: "book", color: .gray),
        QuickShortcut(name: "Facebook", url: "https://www.facebook.com", icon: "person.2", color: .blue),
    ]
}

// MARK: - Quick Shortcut Button

private struct QuickShortcutButton: View {
    let shortcut: QuickShortcut
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AegisSpacing.xs) {
                ZStack {
                    Circle()
                        .fill(shortcut.color.opacity(0.12))
                        .frame(width: AegisSpacing.iconSizeXL, height: AegisSpacing.iconSizeXL)

                    Image(systemName: shortcut.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(shortcut.color)
                }

                Text(shortcut.name)
                    .font(AegisTypography.captionSmall)
                    .foregroundStyle(AegisColors.textPrimary)
                    .lineLimit(1)
            }
        }
        .accessibilityLabel(shortcut.name)
    }
}
