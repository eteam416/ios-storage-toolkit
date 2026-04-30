import SwiftUI

/// First-launch language selection screen.
/// Auto-detects device locale, allows manual override.
struct LanguageSelectionView: View {
    @EnvironmentObject private var appState: AppStateManager
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var searchText = ""

    private var filteredLanguages: [LanguageManager.SupportedLanguage] {
        if searchText.isEmpty {
            return LanguageManager.supportedLanguages
        }
        return LanguageManager.supportedLanguages.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.englishName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: AegisSpacing.sm) {
                Image(systemName: "globe")
                    .font(.system(size: 48))
                    .foregroundStyle(AegisColors.brandGradient)

                Text(String(localized: "language_title"))
                    .font(AegisTypography.displaySmall)
                    .multilineTextAlignment(.center)

                Text(String(localized: "language_subtitle"))
                    .font(AegisTypography.bodyMedium)
                    .foregroundStyle(AegisColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, AegisSpacing.xxl)
            .padding(.horizontal, AegisSpacing.lg)

            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AegisColors.textTertiary)
                TextField(String(localized: "search_language"), text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(AegisSpacing.sm)
            .background(AegisColors.inputBackground)
            .clipShape(RoundedRectangle(cornerRadius: AegisSpacing.inputCornerRadius))
            .padding(.horizontal, AegisSpacing.lg)
            .padding(.top, AegisSpacing.lg)

            // Language list
            ScrollView {
                LazyVStack(spacing: AegisSpacing.xs) {
                    ForEach(filteredLanguages) { language in
                        LanguageRow(
                            language: language,
                            isSelected: language.id == languageManager.selectedLanguage.id
                        ) {
                            languageManager.selectLanguage(language)
                        }
                    }
                }
                .padding(.horizontal, AegisSpacing.lg)
                .padding(.vertical, AegisSpacing.md)
            }

            // Continue button
            AegisPrimaryButton(
                title: String(localized: "continue_button"),
                action: {
                    appState.completeLanguageSelection()
                }
            )
            .padding(.horizontal, AegisSpacing.lg)
            .padding(.bottom, AegisSpacing.xl)
        }
        .background(AegisColors.backgroundPrimary)
    }
}

// MARK: - Language Row

private struct LanguageRow: View {
    let language: LanguageManager.SupportedLanguage
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: AegisSpacing.xxxs) {
                    Text(language.name)
                        .font(AegisTypography.bodyLarge)
                        .foregroundStyle(AegisColors.textPrimary)

                    if language.name != language.englishName {
                        Text(language.englishName)
                            .font(AegisTypography.captionLarge)
                            .foregroundStyle(AegisColors.textSecondary)
                    }
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AegisColors.brandAccent)
                        .font(.title3)
                }

                if language.isRTL {
                    Text("RTL")
                        .font(AegisTypography.captionSmall)
                        .foregroundStyle(AegisColors.textTertiary)
                        .padding(.horizontal, AegisSpacing.xs)
                        .padding(.vertical, AegisSpacing.xxxs)
                        .background(AegisColors.inputBackground)
                        .clipShape(Capsule())
                }
            }
            .padding(AegisSpacing.sm)
            .background(
                isSelected ? AegisColors.brandAccent.opacity(0.08) : Color.clear
            )
            .clipShape(RoundedRectangle(cornerRadius: AegisSpacing.inputCornerRadius))
        }
        .accessibilityLabel("\(language.englishName)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
