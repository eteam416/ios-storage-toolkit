import SwiftUI
import WebKit
import Combine

/// View model for a single browser tab.
@MainActor
final class BrowserViewModel: ObservableObject {
    @Published var urlString: String = ""
    @Published var pageTitle: String = ""
    @Published var isLoading: Bool = false
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var estimatedProgress: Double = 0
    @Published var currentURL: URL?
    @Published var errorMessage: String?
    @Published var isSecure: Bool = false

    let id = UUID()
    let isIncognito: Bool
    weak var webView: WKWebView?

    private var cancellables = Set<AnyCancellable>()

    init(isIncognito: Bool = false) {
        self.isIncognito = isIncognito
    }

    // MARK: - Navigation

    func loadURL(_ urlString: String, searchEngine: SearchEngine) {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let url: URL
        if let parsed = URL(string: trimmed), parsed.scheme != nil,
           trimmed.contains(".") {
            url = parsed
        } else if trimmed.contains(".") && !trimmed.contains(" ") {
            url = URL(string: "https://\(trimmed)") ?? searchEngine.searchURL(for: trimmed)
        } else {
            url = searchEngine.searchURL(for: trimmed)
        }

        errorMessage = nil
        webView?.load(URLRequest(url: url))
    }

    func goBack() {
        webView?.goBack()
    }

    func goForward() {
        webView?.goForward()
    }

    func reload() {
        webView?.reload()
    }

    func stopLoading() {
        webView?.stopLoading()
    }

    func loadHomePage() {
        let homeURL = URL(string: "about:blank")!
        webView?.load(URLRequest(url: homeURL))
    }

    // MARK: - State Updates from WebView

    func updateFromWebView(_ webView: WKWebView) {
        self.webView = webView
        pageTitle = webView.title ?? ""
        isLoading = webView.isLoading
        canGoBack = webView.canGoBack
        canGoForward = webView.canGoForward
        currentURL = webView.url
        urlString = webView.url?.absoluteString ?? ""
        isSecure = webView.url?.scheme == "https"
    }
}
