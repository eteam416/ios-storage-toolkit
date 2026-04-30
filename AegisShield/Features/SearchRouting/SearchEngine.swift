import Foundation

/// Represents a search engine with its query URL template.
struct SearchEngine: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let urlTemplate: String
    let iconName: String
    let homepageURL: String

    func searchURL(for query: String) -> URL {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed.subtracting(CharacterSet(charactersIn: "&=+"))) ?? query
        let urlString = urlTemplate.replacingOccurrences(of: "{query}", with: encoded)
        return URL(string: urlString) ?? URL(string: "https://www.google.com/search?q=\(encoded)")!
    }

    // MARK: - Predefined Engines

    static let google = SearchEngine(
        id: "google",
        name: "Google",
        urlTemplate: "https://www.google.com/search?q={query}",
        iconName: "magnifyingglass",
        homepageURL: "https://www.google.com"
    )

    static let bing = SearchEngine(
        id: "bing",
        name: "Bing",
        urlTemplate: "https://www.bing.com/search?q={query}",
        iconName: "magnifyingglass",
        homepageURL: "https://www.bing.com"
    )

    static let duckDuckGo = SearchEngine(
        id: "duckduckgo",
        name: "DuckDuckGo",
        urlTemplate: "https://duckduckgo.com/?q={query}",
        iconName: "shield",
        homepageURL: "https://duckduckgo.com"
    )

    static let yahoo = SearchEngine(
        id: "yahoo",
        name: "Yahoo",
        urlTemplate: "https://search.yahoo.com/search?p={query}",
        iconName: "y.circle",
        homepageURL: "https://www.yahoo.com"
    )

    static let baidu = SearchEngine(
        id: "baidu",
        name: "Baidu",
        urlTemplate: "https://www.baidu.com/s?wd={query}",
        iconName: "b.circle",
        homepageURL: "https://www.baidu.com"
    )

    static let yandex = SearchEngine(
        id: "yandex",
        name: "Yandex",
        urlTemplate: "https://yandex.com/search/?text={query}",
        iconName: "y.circle",
        homepageURL: "https://ya.ru"
    )

    static let naver = SearchEngine(
        id: "naver",
        name: "Naver",
        urlTemplate: "https://search.naver.com/search.naver?query={query}",
        iconName: "n.circle",
        homepageURL: "https://www.naver.com"
    )

    static let ecosia = SearchEngine(
        id: "ecosia",
        name: "Ecosia",
        urlTemplate: "https://www.ecosia.org/search?q={query}",
        iconName: "leaf",
        homepageURL: "https://www.ecosia.org"
    )

    static let allEngines: [SearchEngine] = [
        .google, .bing, .duckDuckGo, .yahoo,
        .baidu, .yandex, .naver, .ecosia,
    ]
}
