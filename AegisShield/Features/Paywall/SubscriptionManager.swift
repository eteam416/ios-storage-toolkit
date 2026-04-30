import SwiftUI
import RevenueCat

/// Manages subscriptions via RevenueCat SDK.
/// Handles entitlement checking, purchases, and restoration.
@MainActor
final class SubscriptionManager: ObservableObject {
    @Published var isProUser: Bool = false
    @Published var currentOffering: Offering?
    @Published var customerInfo: CustomerInfo?
    @Published var purchaseError: String?
    @Published var isLoading: Bool = false
    @Published var isPurchasing: Bool = false

    // MARK: - Entitlement Checking

    /// Loads current entitlements from RevenueCat.
    func loadEntitlements() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let info = try await Purchases.shared.customerInfo()
            customerInfo = info
            isProUser = info.entitlements[Configuration.proEntitlementIdentifier]?.isActive == true
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    /// Fetches available offerings (products).
    func loadOfferings() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            currentOffering = offerings.current
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    // MARK: - Purchases

    /// Purchases a specific package.
    func purchase(package: Package) async {
        isPurchasing = true
        purchaseError = nil
        defer { isPurchasing = false }

        do {
            let result = try await Purchases.shared.purchase(package: package)

            if !result.userCancelled {
                customerInfo = result.customerInfo
                isProUser = result.customerInfo.entitlements[Configuration.proEntitlementIdentifier]?.isActive == true
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    /// Restores previous purchases.
    func restorePurchases() async {
        isLoading = true
        purchaseError = nil
        defer { isLoading = false }

        do {
            let info = try await Purchases.shared.restorePurchases()
            customerInfo = info
            isProUser = info.entitlements[Configuration.proEntitlementIdentifier]?.isActive == true

            if !isProUser {
                purchaseError = String(localized: "no_purchases_to_restore")
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    // MARK: - Subscription Management

    /// Opens the Apple subscription management page.
    func openSubscriptionManagement() async {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first else { return }

        do {
            try await AppStore.showManageSubscriptions(in: windowScene)
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    // MARK: - Helpers

    /// Returns the yearly package if available.
    var yearlyPackage: Package? {
        currentOffering?.availablePackages.first { $0.identifier == Configuration.yearlyProductID }
            ?? currentOffering?.annual
    }

    /// Returns the lifetime package if available.
    var lifetimePackage: Package? {
        currentOffering?.availablePackages.first { $0.identifier == Configuration.lifetimeProductID }
            ?? currentOffering?.lifetime
    }

    /// Formatted monthly equivalent price for yearly plan.
    func monthlyEquivalent(for package: Package) -> String {
        let yearlyPrice = package.storeProduct.price as Decimal
        let monthly = yearlyPrice / 12
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = package.storeProduct.priceFormatter?.locale ?? .current
        return formatter.string(from: monthly as NSDecimalNumber) ?? ""
    }
}
