import SwiftUI

/// Manages search engine selection with country/region-aware defaults.
final class SearchEngineManager: ObservableObject {
    @Published var currentEngine: SearchEngine
    @AppStorage("selectedSearchEngineID") private var savedEngineID: String = ""
    @AppStorage("hasManuallySelectedEngine") private var hasManuallySelected: Bool = false

    init() {
        let savedID = UserDefaults.standard.string(forKey: "selectedSearchEngineID") ?? ""
        if !savedID.isEmpty,
           let saved = SearchEngine.allEngines.first(where: { $0.id == savedID }) {
            self.currentEngine = saved
        } else {
            self.currentEngine = Self.defaultEngine(for: Self.currentCountryCode())
        }
    }

    // MARK: - Engine Selection

    func selectEngine(_ engine: SearchEngine) {
        currentEngine = engine
        savedEngineID = engine.id
        hasManuallySelected = true
    }

    // MARK: - Country Detection

    static func currentCountryCode() -> String {
        Locale.current.region?.identifier ?? "US"
    }

    // MARK: - Country-Aware Defaults

    /// Returns the default search engine for a given country code.
    /// Special handling for mainland China: defaults to Baidu.
    static func defaultEngine(for countryCode: String) -> SearchEngine {
        switch countryCode.uppercased() {
        // Mainland China → Baidu (Google often inaccessible)
        case "CN":
            return .baidu

        // Russia → Yandex
        case "RU":
            return .yandex

        // South Korea → Naver
        case "KR":
            return .naver

        // Japan → Google (most popular in Japan)
        case "JP":
            return .google

        // Czech Republic → Seznam (not in our list, fallback to Google)
        case "CZ":
            return .google

        // Default: Google for most countries
        default:
            return .google
        }
    }

    /// Fallback chain if the primary engine is unreachable.
    static func fallbackChain(for countryCode: String) -> [SearchEngine] {
        switch countryCode.uppercased() {
        case "CN":
            return [.baidu, .bing, .duckDuckGo]
        case "RU":
            return [.yandex, .google, .bing]
        case "KR":
            return [.naver, .google, .bing]
        default:
            return [.google, .bing, .duckDuckGo]
        }
    }

    /// Checks if we should auto-switch to a fallback engine.
    /// For China: if Google is detected as unreachable, auto-default to Baidu.
    func checkAndApplyRegionFallback() async {
        let countryCode = Self.currentCountryCode()

        // Only auto-switch if user hasn't manually selected
        guard !hasManuallySelected else { return }

        if countryCode == "CN" && currentEngine.id == "google" {
            let isGoogleReachable = await checkReachability(url: "https://www.google.com")
            if !isGoogleReachable {
                await MainActor.run {
                    currentEngine = .baidu
                    savedEngineID = SearchEngine.baidu.id
                }
            }
        }
    }

    private func checkReachability(url: String) async -> Bool {
        guard let url = URL(string: url) else { return false }
        var request = URLRequest(url: url, timeoutInterval: 5)
        request.httpMethod = "HEAD"

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
}
