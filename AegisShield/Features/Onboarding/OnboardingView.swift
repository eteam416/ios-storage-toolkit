import SwiftUI

/// Onboarding flow: Problem → Solution → Core Benefits → Trust → Premium transition.
struct OnboardingView: View {
    @EnvironmentObject private var appState: AppStateManager
    @State private var currentPage = 0

    private let pages = OnboardingPage.allPages

    var body: some View {
        VStack(spacing: 0) {
            // Skip button
            HStack {
                Spacer()
                Button(String(localized: "skip_button")) {
                    appState.completeOnboarding()
                }
                .font(AegisTypography.labelMedium)
                .foregroundStyle(AegisColors.textSecondary)
                .padding(.trailing, AegisSpacing.lg)
                .padding(.top, AegisSpacing.md)
                .accessibilityLabel(String(localized: "skip_onboarding"))
            }

            // Page content
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: currentPage)

            // Page indicator
            HStack(spacing: AegisSpacing.xs) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage ? AegisColors.brandAccent : AegisColors.textTertiary.opacity(0.3))
                        .frame(width: index == currentPage ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.3), value: currentPage)
                }
            }
            .padding(.bottom, AegisSpacing.lg)

            // Navigation button
            AegisPrimaryButton(
                title: currentPage == pages.count - 1
                    ? String(localized: "get_started_button")
                    : String(localized: "next_button")
            ) {
                if currentPage == pages.count - 1 {
                    appState.completeOnboarding()
                } else {
                    withAnimation {
                        currentPage += 1
                    }
                }
            }
            .padding(.horizontal, AegisSpacing.lg)
            .padding(.bottom, AegisSpacing.xl)
        }
        .background(AegisColors.backgroundPrimary)
    }
}

// MARK: - Onboarding Page View

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: AegisSpacing.xl) {
            Spacer()

            // Illustration
            Image(systemName: page.systemIcon)
                .font(.system(size: 80, weight: .light))
                .foregroundStyle(AegisColors.brandGradient)
                .frame(height: 120)
                .accessibilityHidden(true)

            // Content
            VStack(spacing: AegisSpacing.md) {
                Text(page.title)
                    .font(AegisTypography.displayMedium)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AegisColors.textPrimary)

                Text(page.subtitle)
                    .font(AegisTypography.bodyLarge)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AegisColors.textSecondary)
                    .lineSpacing(4)
            }
            .padding(.horizontal, AegisSpacing.lg)

            Spacer()
            Spacer()
        }
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let systemIcon: String
    let title: String
    let subtitle: String

    static let allPages: [OnboardingPage] = [
        // Page 1: The Problem
        OnboardingPage(
            systemIcon: "exclamationmark.triangle",
            title: String(localized: "onboarding_problem_title"),
            subtitle: String(localized: "onboarding_problem_subtitle")
        ),
        // Page 2: The Solution
        OnboardingPage(
            systemIcon: "shield.checkered",
            title: String(localized: "onboarding_solution_title"),
            subtitle: String(localized: "onboarding_solution_subtitle")
        ),
        // Page 3: Core Benefits
        OnboardingPage(
            systemIcon: "bolt.shield",
            title: String(localized: "onboarding_benefits_title"),
            subtitle: String(localized: "onboarding_benefits_subtitle")
        ),
        // Page 4: Trust
        OnboardingPage(
            systemIcon: "lock.shield",
            title: String(localized: "onboarding_trust_title"),
            subtitle: String(localized: "onboarding_trust_subtitle")
        ),
        // Page 5: Premium Transition
        OnboardingPage(
            systemIcon: "crown",
            title: String(localized: "onboarding_premium_title"),
            subtitle: String(localized: "onboarding_premium_subtitle")
        ),
    ]
}
