import SwiftUI
import WebKit

/// UIViewRepresentable wrapper for WKWebView with ad-blocking support.
struct WebViewRepresentable: UIViewRepresentable {
    @ObservedObject var viewModel: BrowserViewModel
    @EnvironmentObject var adBlockManager: AdBlockManager

    let isIncognito: Bool

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()

        // Incognito: use non-persistent data store
        if isIncognito {
            configuration.websiteDataStore = .nonPersistent()
        } else {
            configuration.websiteDataStore = .default()
        }

        // Media playback configuration
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        // Apply ad-block rules to user content controller
        let userContentController = WKUserContentController()
        for ruleList in adBlockManager.compiledRuleLists {
            userContentController.add(ruleList)
        }
        configuration.userContentController = userContentController

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true

        // Custom user agent for social site compatibility
        webView.customUserAgent = buildUserAgent(webView: webView)

        viewModel.updateFromWebView(webView)

        // Observe loading state
        context.coordinator.observeWebView(webView)

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Re-apply rule lists if they changed
        let currentRules = Set(webView.configuration.userContentController
            .contentRuleLists.map { ObjectIdentifier($0) })
        let newRules = Set(adBlockManager.compiledRuleLists.map { ObjectIdentifier($0) })

        if currentRules != newRules {
            webView.configuration.userContentController.removeAllContentRuleLists()
            for ruleList in adBlockManager.compiledRuleLists {
                webView.configuration.userContentController.add(ruleList)
            }
        }
    }

    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(viewModel: viewModel, adBlockManager: adBlockManager)
    }

    private func buildUserAgent(webView: WKWebView) -> String {
        // Use a standard Safari user agent for maximum compatibility
        // This ensures Google/Facebook/X/Instagram/TikTok login flows work
        let osVersion = UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")
        return "Mozilla/5.0 (iPhone; CPU iPhone OS \(osVersion) like Mac OS X) "
            + "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
    }
}

// MARK: - WebView Coordinator

final class WebViewCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
    let viewModel: BrowserViewModel
    let adBlockManager: AdBlockManager
    private var observations: [NSKeyValueObservation] = []

    init(viewModel: BrowserViewModel, adBlockManager: AdBlockManager) {
        self.viewModel = viewModel
        self.adBlockManager = adBlockManager
    }

    func observeWebView(_ webView: WKWebView) {
        observations = [
            webView.observe(\.title) { [weak self] webView, _ in
                Task { @MainActor in
                    self?.viewModel.updateFromWebView(webView)
                }
            },
            webView.observe(\.url) { [weak self] webView, _ in
                Task { @MainActor in
                    self?.viewModel.updateFromWebView(webView)
                }
            },
            webView.observe(\.isLoading) { [weak self] webView, _ in
                Task { @MainActor in
                    self?.viewModel.updateFromWebView(webView)
                }
            },
            webView.observe(\.estimatedProgress) { [weak self] webView, _ in
                Task { @MainActor in
                    self?.viewModel.estimatedProgress = webView.estimatedProgress
                }
            },
            webView.observe(\.canGoBack) { [weak self] webView, _ in
                Task { @MainActor in
                    self?.viewModel.updateFromWebView(webView)
                }
            },
            webView.observe(\.canGoForward) { [weak self] webView, _ in
                Task { @MainActor in
                    self?.viewModel.updateFromWebView(webView)
                }
            },
        ]
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        Task { @MainActor in
            viewModel.updateFromWebView(webView)
            adBlockManager.recordPageLoad()
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Task { @MainActor in
            viewModel.updateFromWebView(webView)
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Task { @MainActor in
            viewModel.errorMessage = error.localizedDescription
            viewModel.updateFromWebView(webView)
        }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        Task { @MainActor in
            let nsError = error as NSError
            // Ignore cancelled navigation (user tapped another link)
            if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
                return
            }
            viewModel.errorMessage = error.localizedDescription
            viewModel.updateFromWebView(webView)
        }
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        // Handle special URL schemes (tel:, mailto:, etc.)
        if let scheme = url.scheme, ["tel", "mailto", "sms", "facetime"].contains(scheme) {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
            return
        }

        // Handle App Store links
        if let host = url.host, host.contains("apps.apple.com") || host.contains("itunes.apple.com") {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }

    // MARK: - WKUIDelegate

    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        // Handle target="_blank" links by loading in current view
        if navigationAction.targetFrame == nil || !(navigationAction.targetFrame?.isMainFrame ?? false) {
            webView.load(navigationAction.request)
        }
        return nil
    }

    func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }

    func webView(
        _ webView: WKWebView,
        runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping (Bool) -> Void
    ) {
        completionHandler(true)
    }
}

// MARK: - WKUserContentController Extension

extension WKUserContentController {
    var contentRuleLists: [WKContentRuleList] {
        // WKUserContentController doesn't expose added rule lists directly.
        // We track them via AdBlockManager.compiledRuleLists instead.
        return []
    }
}
