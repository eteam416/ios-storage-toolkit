import Foundation

enum Configuration {
    // MARK: - RevenueCat

    /// RevenueCat public API key.
    /// In production, load from a secure build configuration or .xcconfig file.
    static let revenueCatAPIKey = "test_ZdpKBkXDAdCPxTllzOJkfXlUXVv"

    // MARK: - Entitlements

    static let proEntitlementIdentifier = "iOS Browser App Pro"

    // MARK: - Product Identifiers

    static let yearlyProductID = "yearly"
    static let lifetimeProductID = "lifetime"

    // MARK: - Support

    static let supportEmail = "developer.nasar416@gmail.com"
    static let privacyPolicyURL = URL(string: "https://aegisshield.app/privacy")!
    static let termsURL = URL(string: "https://aegisshield.app/terms")!

    // MARK: - Ad Block

    static let adBlockRuleVersion = "1.0.0"

    // MARK: - Analytics

    static let analyticsEnabled = true
    static let crashlyticsEnabled = true
}
