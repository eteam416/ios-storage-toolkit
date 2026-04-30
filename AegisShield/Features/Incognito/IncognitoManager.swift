import SwiftUI
import WebKit

/// Manages incognito browsing sessions with complete data isolation.
@MainActor
final class IncognitoManager: ObservableObject {
    @Published var isActive: Bool = false
    @Published var sessionCount: Int = 0

    /// Creates a WKWebView configuration for incognito mode.
    /// Uses WKWebsiteDataStore.nonPersistent() to ensure no data survives session close.
    static func createIncognitoConfiguration() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        return config
    }

    /// Clears all data from a specific non-persistent data store.
    /// Called when closing an incognito session for extra safety.
    func clearSessionData(for dataStore: WKWebsiteDataStore) async {
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        let records = await dataStore.dataRecords(ofTypes: dataTypes)

        if !records.isEmpty {
            await dataStore.removeData(
                ofTypes: dataTypes,
                for: records
            )
        }
    }

    func startSession() {
        isActive = true
        sessionCount += 1
    }

    func endSession() {
        isActive = false
    }
}
