import Foundation

/// Fetches real-time search suggestions from the active search engine's
/// autocomplete API. Debounces requests and cancels stale network calls
/// automatically.
@MainActor
final class SearchSuggestionService: ObservableObject {
    @Published var suggestions: [String] = []
    @Published var isLoading: Bool = false

    private var currentTask: Task<Void, Never>?
    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5
        config.waitsForConnectivity = false
        self.session = URLSession(configuration: config)
    }

    // MARK: - Fetch Suggestions

    /// Debounces input and fetches suggestions from the search engine.
    func fetchSuggestions(for query: String, engine: SearchEngine) {
        currentTask?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmed.count >= 2 else {
            suggestions = []
            isLoading = false
            return
        }

        isLoading = true

        currentTask = Task {
            // Debounce: wait 250ms before firing the request
            try? await Task.sleep(for: .milliseconds(250))
            guard !Task.isCancelled else { return }

            let results = await performFetch(query: trimmed, engine: engine)

            guard !Task.isCancelled else { return }
            suggestions = results
            isLoading = false
        }
    }

    /// Clears suggestions immediately.
    func clear() {
        currentTask?.cancel()
        suggestions = []
        isLoading = false
    }

    // MARK: - Network

    private func performFetch(query: String, engine: SearchEngine) async -> [String] {
        let urlString = suggestionURL(for: query, engine: engine)
        guard let url = URL(string: urlString) else { return [] }

        do {
            let (data, _) = try await session.data(from: url)
            return parseSuggestions(data: data, engine: engine)
        } catch {
            return []
        }
    }

    // MARK: - Suggestion URLs

    /// Returns the autocomplete API URL for each engine.
    private func suggestionURL(for query: String, engine: SearchEngine) -> String {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed.subtracting(CharacterSet(charactersIn: "&=+"))) ?? query
        let lang = Locale.current.language.languageCode?.identifier ?? "en"

        switch engine.id {
        case "google":
            return "https://suggestqueries.google.com/complete/search?client=firefox&q=\(encoded)&hl=\(lang)"

        case "bing":
            return "https://api.bing.com/osjson.aspx?query=\(encoded)&language=\(lang)"

        case "duckduckgo":
            return "https://duckduckgo.com/ac/?q=\(encoded)&type=list"

        case "yahoo":
            return "https://search.yahoo.com/sugg/gossip/gossip-us-ura/?command=\(encoded)&output=sd1&nresults=10"

        case "baidu":
            return "https://suggestion.baidu.com/su?wd=\(encoded)&action=opensearch"

        case "yandex":
            return "https://suggest.yandex.com/suggest-ff.cgi?part=\(encoded)"

        case "ecosia":
            return "https://ac.ecosia.org/?q=\(encoded)&type=list"

        default:
            // Fallback to Google suggestions
            return "https://suggestqueries.google.com/complete/search?client=firefox&q=\(encoded)&hl=\(lang)"
        }
    }

    // MARK: - Parsing

    /// Parses the JSON response. Most engines use the OpenSearch suggestion
    /// format: `["query", ["suggestion1", "suggestion2", ...]]`
    private func parseSuggestions(data: Data, engine: SearchEngine) -> [String] {
        // Yahoo uses a different format
        if engine.id == "yahoo" {
            return parseYahooSuggestions(data: data)
        }

        // DuckDuckGo returns [{"phrase":"..."},...]
        if engine.id == "duckduckgo" {
            return parseDuckDuckGoSuggestions(data: data)
        }

        // OpenSearch format: ["query", ["s1", "s2", ...]]
        return parseOpenSearchSuggestions(data: data)
    }

    private func parseOpenSearchSuggestions(data: Data) -> [String] {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [Any],
              json.count >= 2,
              let suggestions = json[1] as? [String] else {
            return []
        }
        return Array(suggestions.prefix(8))
    }

    private func parseDuckDuckGoSuggestions(data: Data) -> [String] {
        // DuckDuckGo ac endpoint returns: [{"phrase":"suggestion1"}, ...]
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [[String: String]] else {
            // Try OpenSearch format as fallback
            return parseOpenSearchSuggestions(data: data)
        }
        return Array(json.compactMap { $0["phrase"] }.prefix(8))
    }

    private func parseYahooSuggestions(data: Data) -> [String] {
        // Yahoo gossip format: {"r":[{"k":"suggestion"}, ...]}
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let results = json["r"] as? [[String: Any]] else {
            return parseOpenSearchSuggestions(data: data)
        }
        return Array(results.compactMap { $0["k"] as? String }.prefix(8))
    }
}
