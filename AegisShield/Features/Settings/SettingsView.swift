import SwiftUI
import RevenueCat
import RevenueCatUI

/// Settings screen with all required sections.
struct SettingsView: View {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var searchEngineManager: SearchEngineManager
    @EnvironmentObject private var adBlockManager: AdBlockManager
    @EnvironmentObject private var analyticsManager: AnalyticsManager

    @Environment(\.dismiss) private var dismiss

    @State private var showLanguagePicker = false
    @State private var showSearchEnginePicker = false
    @State private var showClearDataConfirmation = false
    @State private var showCustomerCenter = false
    @State private var showRestoreAlert = false

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Subscription Section
                subscriptionSection

                // MARK: - Browsing Section
                browsingSection

                // MARK: - Privacy Section
                privacySection

                // MARK: - Preferences Section
                preferencesSection

                // MARK: - Support Section
                supportSection

                // MARK: - Legal Section
                legalSection

                // MARK: - About Section
                aboutSection
            }
            .navigationTitle(String(localized: "settings_title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "done_button")) {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showLanguagePicker) {
            languagePickerSheet
        }
        .sheet(isPresented: $showSearchEnginePicker) {
            searchEnginePickerSheet
        }
        .sheet(isPresented: $showCustomerCenter) {
            CustomerCenterView()
        }
        .alert(
            String(localized: "clear_data_title"),
            isPresented: $showClearDataConfirmation
        ) {
            Button(String(localized: "clear_button"), role: .destructive) {
                clearBrowsingData()
            }
            Button(String(localized: "cancel_button"), role: .cancel) {}
        } message: {
            Text(String(localized: "clear_data_message"))
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

    // MARK: - Subscription Section

    private var subscriptionSection: some View {
        Section(String(localized: "subscription_section")) {
            // Subscription status
            HStack {
                Text(String(localized: "status_label"))
                Spacer()
                Text(subscriptionManager.isProUser
                     ? String(localized: "pro_active_label")
                     : String(localized: "free_label"))
                    .foregroundStyle(subscriptionManager.isProUser ? AegisColors.success : AegisColors.textSecondary)
            }

            // Restore Purchases
            Button(String(localized: "restore_purchases_button")) {
                Task {
                    await subscriptionManager.restorePurchases()
                    showRestoreAlert = true
                }
            }

            // Manage Subscription
            Button(String(localized: "manage_subscription_button")) {
                Task {
                    await subscriptionManager.openSubscriptionManagement()
                }
            }

            // Customer Center (RevenueCat)
            Button(String(localized: "subscription_help_button")) {
                showCustomerCenter = true
            }
        }
    }

    // MARK: - Browsing Section

    private var browsingSection: some View {
        Section(String(localized: "browsing_section")) {
            // Search Engine
            Button {
                showSearchEnginePicker = true
            } label: {
                HStack {
                    Label(String(localized: "search_engine_label"), systemImage: "magnifyingglass")
                    Spacer()
                    Text(searchEngineManager.currentEngine.name)
                        .foregroundStyle(AegisColors.textSecondary)
                    Image(systemName: "chevron.right")
                        .foregroundStyle(AegisColors.textTertiary)
                        .font(.caption)
                }
            }
            .foregroundStyle(AegisColors.textPrimary)

            // Ad Blocking
            Toggle(isOn: $adBlockManager.isEnabled) {
                Label(String(localized: "adblock_toggle_label"), systemImage: "shield.lefthalf.filled")
            }
        }
    }

    // MARK: - Privacy Section

    private var privacySection: some View {
        Section(String(localized: "privacy_section")) {
            Button {
                showClearDataConfirmation = true
            } label: {
                Label(String(localized: "clear_browsing_data_button"), systemImage: "trash")
                    .foregroundStyle(AegisColors.error)
            }

            // Reset ad block stats
            Button {
                adBlockManager.resetStats()
            } label: {
                Label(String(localized: "reset_stats_button"), systemImage: "arrow.counterclockwise")
            }
        }
    }

    // MARK: - Preferences Section

    private var preferencesSection: some View {
        Section(String(localized: "preferences_section")) {
            // Language
            Button {
                showLanguagePicker = true
            } label: {
                HStack {
                    Label(String(localized: "language_label"), systemImage: "globe")
                    Spacer()
                    Text(languageManager.selectedLanguage.name)
                        .foregroundStyle(AegisColors.textSecondary)
                    Image(systemName: "chevron.right")
                        .foregroundStyle(AegisColors.textTertiary)
                        .font(.caption)
                }
            }
            .foregroundStyle(AegisColors.textPrimary)
        }
    }

    // MARK: - Support Section

    private var supportSection: some View {
        Section(String(localized: "support_section")) {
            Link(destination: URL(string: "mailto:\(Configuration.supportEmail)")!) {
                Label(String(localized: "contact_support_button"), systemImage: "envelope")
            }
        }
    }

    // MARK: - Legal Section

    private var legalSection: some View {
        Section(String(localized: "legal_section")) {
            Link(destination: Configuration.privacyPolicyURL) {
                Label(String(localized: "privacy_policy_label"), systemImage: "hand.raised")
            }

            Link(destination: Configuration.termsURL) {
                Label(String(localized: "terms_label"), systemImage: "doc.text")
            }
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section(String(localized: "about_section")) {
            HStack {
                Text(String(localized: "version_label"))
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                    .foregroundStyle(AegisColors.textSecondary)
            }

            HStack {
                Text(String(localized: "build_label"))
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                    .foregroundStyle(AegisColors.textSecondary)
            }
        }
    }

    // MARK: - Clear Browsing Data

    private func clearBrowsingData() {
        Task {
            let dataStore = WKWebsiteDataStore.default()
            let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
            let date = Date(timeIntervalSince1970: 0)
            await dataStore.removeData(ofTypes: dataTypes, modifiedSince: date)
        }
    }

    // MARK: - Language Picker Sheet

    private var languagePickerSheet: some View {
        NavigationStack {
            List(LanguageManager.supportedLanguages) { language in
                Button {
                    languageManager.selectLanguage(language)
                    showLanguagePicker = false
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(language.name)
                            if language.name != language.englishName {
                                Text(language.englishName)
                                    .font(.caption)
                                    .foregroundStyle(AegisColors.textSecondary)
                            }
                        }
                        Spacer()
                        if language.id == languageManager.selectedLanguage.id {
                            Image(systemName: "checkmark")
                                .foregroundStyle(AegisColors.brandAccent)
                        }
                    }
                }
                .foregroundStyle(AegisColors.textPrimary)
            }
            .navigationTitle(String(localized: "select_language_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "cancel_button")) {
                        showLanguagePicker = false
                    }
                }
            }
        }
    }

    // MARK: - Search Engine Picker Sheet

    private var searchEnginePickerSheet: some View {
        NavigationStack {
            List(SearchEngine.allEngines) { engine in
                Button {
                    searchEngineManager.selectEngine(engine)
                    showSearchEnginePicker = false
                } label: {
                    HStack {
                        Image(systemName: engine.iconName)
                            .frame(width: 24)
                        Text(engine.name)
                        Spacer()
                        if engine.id == searchEngineManager.currentEngine.id {
                            Image(systemName: "checkmark")
                                .foregroundStyle(AegisColors.brandAccent)
                        }
                    }
                }
                .foregroundStyle(AegisColors.textPrimary)
            }
            .navigationTitle(String(localized: "select_search_engine_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "cancel_button")) {
                        showSearchEnginePicker = false
                    }
                }
            }
        }
    }
}
