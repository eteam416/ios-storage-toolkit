import WebKit

/// Manages browser identity to appear as a real browser to websites.
/// Prevents anti-bot systems from blocking login/signup flows and ensures
/// social login providers (Google, Facebook, Apple, etc.) work correctly.
enum BrowserIdentityManager {

    // MARK: - User Agent

    /// Builds a Safari-compatible User-Agent string that matches the device.
    static func userAgent() -> String {
        let osVersion = UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")
        return "Mozilla/5.0 (iPhone; CPU iPhone OS \(osVersion) like Mac OS X) "
            + "AppleWebKit/605.1.15 (KHTML, like Gecko) "
            + "Version/18.0 Mobile/15E148 Safari/604.1"
    }

    // MARK: - Anti-Detection JavaScript

    /// JavaScript injected into every page to mask WebView fingerprints.
    /// Websites use these properties to detect in-app browsers and may
    /// block login flows if they identify one.
    static let antiDetectionScript: String = """
    (function() {
        // 1. Remove WebView detection flags
        Object.defineProperty(navigator, 'webdriver', {
            get: () => false,
            configurable: true
        });

        // 2. Override standalone display mode check
        //    In-app WebViews report 'standalone'; real Safari does not.
        if (window.matchMedia) {
            const originalMatchMedia = window.matchMedia;
            window.matchMedia = function(query) {
                if (query === '(display-mode: standalone)') {
                    return {
                        matches: false,
                        media: query,
                        onchange: null,
                        addListener: function() {},
                        removeListener: function() {},
                        addEventListener: function() {},
                        removeEventListener: function() {},
                        dispatchEvent: function() { return false; }
                    };
                }
                return originalMatchMedia.call(window, query);
            };
        }

        // 3. Ensure standard navigator properties exist
        if (!navigator.credentials) {
            Object.defineProperty(navigator, 'credentials', {
                get: () => ({
                    create: () => Promise.reject(new Error('Not supported')),
                    get: () => Promise.reject(new Error('Not supported')),
                    preventSilentAccess: () => Promise.resolve(),
                    store: () => Promise.resolve()
                }),
                configurable: true
            });
        }

        // 4. Ensure standard browser APIs are present
        if (!window.chrome) {
            Object.defineProperty(window, 'chrome', {
                get: () => ({
                    runtime: {},
                    loadTimes: function() { return {}; },
                    csi: function() { return {}; }
                }),
                configurable: true
            });
        }

        // 5. Remove __gCrWeb injected by iOS WKWebView
        try {
            if (window.__gCrWeb) { delete window.__gCrWeb; }
            if (window.__crWeb) { delete window.__crWeb; }
            if (window.__firefox__) { delete window.__firefox__; }
        } catch(e) {}

        // 6. Ensure plugins array looks normal (empty in mobile Safari)
        Object.defineProperty(navigator, 'plugins', {
            get: () => [],
            configurable: true
        });

        // 7. Ensure languages are present
        if (!navigator.languages || navigator.languages.length === 0) {
            Object.defineProperty(navigator, 'languages', {
                get: () => ['en-US', 'en'],
                configurable: true
            });
        }
    })();
    """

    /// Creates a WKUserScript that runs the anti-detection code at document
    /// start in all frames.
    static func antiDetectionUserScript() -> WKUserScript {
        WKUserScript(
            source: antiDetectionScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
    }

    // MARK: - Social Login Domains

    /// Domains used by social login providers. Navigation to these should
    /// always be allowed and never intercepted by download or ad-block logic.
    static let socialLoginDomains: Set<String> = [
        // Google
        "accounts.google.com",
        "accounts.youtube.com",
        "myaccount.google.com",
        "oauth2.googleapis.com",
        "www.googleapis.com",

        // Facebook / Meta
        "www.facebook.com",
        "m.facebook.com",
        "web.facebook.com",
        "facebook.com",

        // Apple
        "appleid.apple.com",

        // X / Twitter
        "api.twitter.com",
        "twitter.com",
        "x.com",

        // Microsoft
        "login.microsoftonline.com",
        "login.live.com",
        "login.windows.net",

        // GitHub
        "github.com",

        // Instagram
        "www.instagram.com",
        "instagram.com",

        // TikTok
        "www.tiktok.com",

        // LinkedIn
        "www.linkedin.com",

        // Discord
        "discord.com",
    ]

    /// Returns `true` when the given URL points to a known social-login or
    /// OAuth provider, so the navigation should be allowed through without
    /// ad-block interference.
    /// Top-level domains of known OAuth providers where path-based
    /// detection is appropriate.
    private static let oauthProviderTLDs: Set<String> = [
        "google.com", "googleapis.com", "youtube.com",
        "facebook.com", "apple.com", "twitter.com", "x.com",
        "microsoftonline.com", "live.com", "windows.net",
        "github.com", "instagram.com", "tiktok.com",
        "linkedin.com", "discord.com",
    ]

    static func isSocialLoginURL(_ url: URL) -> Bool {
        guard let host = url.host?.lowercased() else { return false }

        // Direct domain match
        if socialLoginDomains.contains(host) { return true }

        // Only apply path-based matching to known OAuth provider domains
        let isKnownProvider = oauthProviderTLDs.contains(where: {
            host == $0 || host.hasSuffix(".\($0)")
        })
        guard isKnownProvider else { return false }

        // Check path components (not substrings) for OAuth patterns
        let pathComponents = url.pathComponents.map { $0.lowercased() }
        let oauthPaths: Set<String> = [
            "oauth", "oauth2", "authorize", "login", "signin",
            "auth", "connect", "callback", "consent"
        ]
        return !pathComponents.isDisjoint(with: oauthPaths)
    }
}
