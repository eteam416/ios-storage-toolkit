import SwiftUI
import RevenueCat
import RevenueCatUI

/// Premium paywall screen shown after onboarding.
/// Supports RevenueCat remote paywalls with a local fallback.
struct AegisPaywallView: View {
    @EnvironmentObject private var appState: AppStateManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @State private var selectedPlan: PlanType = .yearly
    @State private var showRestoreAlert = false

    enum PlanType {
        case yearly, lifetime
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AegisSpacing.lg) {
                // Header
                paywallHeader

                // Plan Cards
                planCards

                // CTA Button
                ctaButton

                // Secondary Actions
                secondaryActions

                // Legal Disclosures (Apple-required)
                legalDisclosures
            }
            .padding(.horizontal, AegisSpacing.lg)
            .padding(.bottom, AegisSpacing.xxl)
        }
        .background(AegisColors.backgroundPrimary)
        .task {
            await subscriptionManager.loadOfferings()
        }
        .alert(
            String(localized: "restore_result_title"),
            isPresented: $showRestoreAlert
        ) {
            Button(String(localized: "ok_button"), role: .cancel) {}
        } message: {
            Text(subscriptionManager.purchaseError ?? String(localized: "purchases_restored_success"))
        }
    }

    // MARK: - Header

    private var paywallHeader: some View {
        VStack(spacing: AegisSpacing.md) {
            Image(systemName: "shield.checkered")
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(AegisColors.brandGradient)
                .padding(.top, AegisSpacing.xl)

            Text(String(localized: "paywall_title"))
                .font(AegisTypography.displayMedium)
                .multilineTextAlignment(.center)

            Text(String(localized: "paywall_subtitle"))
                .font(AegisTypography.bodyMedium)
                .foregroundStyle(AegisColors.textSecondary)
                .multilineTextAlignment(.center)

            // Feature list
            VStack(alignment: .leading, spacing: AegisSpacing.sm) {
                PaywallFeatureRow(icon: "shield.lefthalf.filled", text: String(localized: "feature_adblock"))
                PaywallFeatureRow(icon: "eye.slash", text: String(localized: "feature_incognito"))
                PaywallFeatureRow(icon: "magnifyingglass", text: String(localized: "feature_search_engine"))
                PaywallFeatureRow(icon: "bolt", text: String(localized: "feature_speed"))
            }
            .padding(.vertical, AegisSpacing.sm)
        }
    }

    // MARK: - Plan Cards

    private var planCards: some View {
        VStack(spacing: AegisSpacing.sm) {
            // Yearly Plan (highlighted)
            if let yearly = subscriptionManager.yearlyPackage {
                PlanCard(
                    title: String(localized: "yearly_plan_title"),
                    isSelected: selectedPlan == .yearly,
                    badge: String(localized: "free_trial_badge"),
                    priceInfo: {
                        VStack(spacing: AegisSpacing.xxxs) {
                            Text(subscriptionManager.monthlyEquivalent(for: yearly) +
                                 String(localized: "per_month_label"))
                                .font(AegisTypography.paywallPrice)
                                .foregroundStyle(AegisColors.textPrimary)

                            Text(yearly.localizedPriceString +
                                 String(localized: "per_year_label"))
                                .font(AegisTypography.paywallSubprice)
                                .foregroundStyle(AegisColors.textSecondary)
                        }
                    }
                ) {
                    selectedPlan = .yearly
                }
            }

            // Lifetime Plan
            if let lifetime = subscriptionManager.lifetimePackage {
                PlanCard(
                    title: String(localized: "lifetime_plan_title"),
                    isSelected: selectedPlan == .lifetime,
                    priceInfo: {
                        Text(lifetime.localizedPriceString)
                            .font(AegisTypography.paywallPrice)
                            .foregroundStyle(AegisColors.textPrimary)
                    }
                ) {
                    selectedPlan = .lifetime
                }
            }
        }
    }

    // MARK: - CTA Button

    private var ctaButton: some View {
        AegisPrimaryButton(
            title: selectedPlan == .yearly
                ? String(localized: "start_free_trial_cta")
                : String(localized: "purchase_lifetime_cta"),
            action: {
                Task {
                    let package: Package?
                    switch selectedPlan {
                    case .yearly:
                        package = subscriptionManager.yearlyPackage
                    case .lifetime:
                        package = subscriptionManager.lifetimePackage
                    }
                    if let package {
                        await subscriptionManager.purchase(package: package)
                        if subscriptionManager.isProUser {
                            appState.completePaywall()
                        }
                    }
                }
            },
            isLoading: subscriptionManager.isPurchasing
        )
    }

    // MARK: - Secondary Actions

    private var secondaryActions: some View {
        VStack(spacing: AegisSpacing.sm) {
            Button(String(localized: "restore_purchases_button")) {
                Task {
                    await subscriptionManager.restorePurchases()
                    if subscriptionManager.isProUser {
                        appState.completePaywall()
                    } else {
                        showRestoreAlert = true
                    }
                }
            }
            .font(AegisTypography.labelMedium)
            .foregroundStyle(AegisColors.brandAccent)

            // Limited free mode (Apple review friendliness)
            Button(String(localized: "continue_limited_button")) {
                appState.skipPaywall()
            }
            .font(AegisTypography.captionLarge)
            .foregroundStyle(AegisColors.textTertiary)
        }
    }

    // MARK: - Legal Disclosures (Apple Required)

    private var legalDisclosures: some View {
        VStack(spacing: AegisSpacing.xs) {
            Text(String(localized: "subscription_disclosure"))
                .font(AegisTypography.captionSmall)
                .foregroundStyle(AegisColors.textTertiary)
                .multilineTextAlignment(.center)

            HStack(spacing: AegisSpacing.md) {
                Link(String(localized: "privacy_policy_link"),
                     destination: Configuration.privacyPolicyURL)
                Link(String(localized: "terms_link"),
                     destination: Configuration.termsURL)
            }
            .font(AegisTypography.captionSmall)
            .foregroundStyle(AegisColors.brandAccent)
        }
        .padding(.top, AegisSpacing.sm)
    }
}

// MARK: - Feature Row

private struct PaywallFeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: AegisSpacing.sm) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(AegisColors.brandAccent)
                .frame(width: AegisSpacing.iconSizeMedium)

            Text(text)
                .font(AegisTypography.bodyMedium)
                .foregroundStyle(AegisColors.textPrimary)
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Plan Card

private struct PlanCard<PriceContent: View>: View {
    let title: String
    let isSelected: Bool
    var badge: String? = nil
    @ViewBuilder let priceInfo: () -> PriceContent
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: AegisSpacing.sm) {
                HStack {
                    Text(title)
                        .font(AegisTypography.headlineSmall)
                        .foregroundStyle(AegisColors.textPrimary)

                    Spacer()

                    if let badge {
                        Text(badge)
                            .font(AegisTypography.captionSmall)
                            .foregroundStyle(.white)
                            .padding(.horizontal, AegisSpacing.xs)
                            .padding(.vertical, AegisSpacing.xxxs)
                            .background(AegisColors.paywallTrialBadge)
                            .clipShape(Capsule())
                    }

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? AegisColors.brandAccent : AegisColors.textTertiary)
                }

                priceInfo()
            }
            .padding(AegisSpacing.cardPadding)
            .background(AegisColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AegisSpacing.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AegisSpacing.cardCornerRadius)
                    .stroke(
                        isSelected ? AegisColors.paywallPlanSelectedBorder : AegisColors.paywallPlanBorder,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .accessibilityLabel("\(title)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - RevenueCat Remote Paywall Presenter

/// Presents RevenueCat's remote paywall UI.
/// Use this when a remote paywall is configured in the RevenueCat dashboard.
struct RevenueCatPaywallPresenter: View {
    @EnvironmentObject private var appState: AppStateManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager

    var body: some View {
        PaywallView(
            displayCloseButton: true
        )
        .onPurchaseCompleted { _ in
            Task {
                await subscriptionManager.loadEntitlements()
                if subscriptionManager.isProUser {
                    appState.completePaywall()
                }
            }
        }
        .onRestoreCompleted { _ in
            Task {
                await subscriptionManager.loadEntitlements()
                if subscriptionManager.isProUser {
                    appState.completePaywall()
                }
            }
        }
    }
}
