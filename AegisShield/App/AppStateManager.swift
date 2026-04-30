import SwiftUI
import Combine

/// Manages the global application state and first-launch flow routing.
final class AppStateManager: ObservableObject {
    enum AppScreen {
        case splash
        case languageSelection
        case onboarding
        case paywall
        case home
    }

    @Published var currentScreen: AppScreen = .splash
    @Published var hasCompletedFirstLaunch: Bool

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasSeenPaywall") private var hasSeenPaywall = false
    @AppStorage("selectedLanguageCode") private var selectedLanguageCode: String = ""

    init() {
        self.hasCompletedFirstLaunch = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }

    /// Determines the next screen in the first-launch flow.
    func advanceFromSplash() {
        if hasCompletedOnboarding && hasSeenPaywall {
            currentScreen = .home
        } else if selectedLanguageCode.isEmpty {
            currentScreen = .languageSelection
        } else if !hasCompletedOnboarding {
            currentScreen = .onboarding
        } else {
            currentScreen = .paywall
        }
    }

    func completeLanguageSelection() {
        currentScreen = .onboarding
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        hasCompletedFirstLaunch = true
        currentScreen = .paywall
    }

    func completePaywall() {
        hasSeenPaywall = true
        currentScreen = .home
    }

    func skipPaywall() {
        hasSeenPaywall = true
        currentScreen = .home
    }

    /// Reset for testing purposes.
    func resetFirstLaunchState() {
        hasCompletedOnboarding = false
        hasSeenPaywall = false
        selectedLanguageCode = ""
        hasCompletedFirstLaunch = false
        currentScreen = .splash
    }
}
