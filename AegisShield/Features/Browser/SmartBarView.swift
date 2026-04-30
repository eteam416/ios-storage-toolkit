import SwiftUI

/// Unified address/search bar with real-time search suggestions.
struct SmartBarView: View {
    @Binding var urlString: String
    @EnvironmentObject private var searchEngineManager: SearchEngineManager
    @ObservedObject var suggestionService: SearchSuggestionService
    let isIncognito: Bool
    let isLoading: Bool
    let isSecure: Bool
    let progress: Double
    let onSubmit: (String) -> Void

    @State private var isEditing = false
    @FocusState private var isFocused: Bool
    @State private var editingText = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: AegisSpacing.xs) {
                // Security indicator
                if !isEditing {
                    securityIcon
                }

                // URL/Search field
                TextField(
                    String(localized: "smart_bar_placeholder"),
                    text: $editingText
                )
                .font(AegisTypography.urlBar)
                .foregroundStyle(isIncognito ? AegisColors.incognitoText : AegisColors.textPrimary)
                .textFieldStyle(.plain)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.webSearch)
                .submitLabel(.go)
                .focused($isFocused)
                .onSubmit {
                    submitQuery(editingText)
                }
                .onTapGesture {
                    isEditing = true
                    editingText = urlString
                    isFocused = true
                }
                .accessibilityLabel(String(localized: "address_bar"))
                .accessibilityHint(String(localized: "address_bar_hint"))

                // Clear / Reload button
                if isEditing && !editingText.isEmpty {
                    Button {
                        editingText = ""
                        suggestionService.clear()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AegisColors.textTertiary)
                    }
                    .accessibilityLabel(String(localized: "clear_text"))
                }

                if isEditing {
                    Button(String(localized: "cancel_button")) {
                        isEditing = false
                        isFocused = false
                        editingText = urlString
                        suggestionService.clear()
                    }
                    .font(AegisTypography.labelMedium)
                    .foregroundStyle(isIncognito ? AegisColors.incognitoAccent : AegisColors.brandAccent)
                }
            }
            .padding(.horizontal, AegisSpacing.sm)
            .frame(height: AegisSpacing.smartBarHeight)
            .background(
                isIncognito ? AegisColors.incognitoElevated : AegisColors.inputBackground
            )
            .clipShape(RoundedRectangle(cornerRadius: AegisSpacing.inputCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AegisSpacing.inputCornerRadius)
                    .stroke(
                        isFocused
                            ? (isIncognito ? AegisColors.incognitoAccent : AegisColors.brandAccent)
                            : Color.clear,
                        lineWidth: 1.5
                    )
            )

            // Loading progress bar
            if isLoading && progress < 1.0 {
                GeometryReader { geo in
                    Rectangle()
                        .fill(isIncognito ? AegisColors.incognitoAccent : AegisColors.brandAccent)
                        .frame(width: geo.size.width * progress, height: 2)
                        .animation(.linear(duration: 0.2), value: progress)
                }
                .frame(height: 2)
            }

            // Search suggestions dropdown
            if isEditing && !suggestionService.suggestions.isEmpty && !isIncognito {
                suggestionsDropdown
            }
        }
        .onChange(of: urlString) { _, newValue in
            if !isEditing {
                editingText = newValue
            }
        }
        .onChange(of: editingText) { _, newValue in
            if isEditing && !isIncognito {
                suggestionService.fetchSuggestions(
                    for: newValue,
                    engine: searchEngineManager.currentEngine
                )
            }
        }
    }

    // MARK: - Suggestions Dropdown

    private var suggestionsDropdown: some View {
        VStack(spacing: 0) {
            ForEach(suggestionService.suggestions, id: \.self) { suggestion in
                Button {
                    submitQuery(suggestion)
                } label: {
                    HStack(spacing: AegisSpacing.sm) {
                        Image(systemName: "magnifyingglass")
                            .font(.caption)
                            .foregroundStyle(AegisColors.textTertiary)
                            .frame(width: 20)

                        Text(suggestion)
                            .font(AegisTypography.bodySmall)
                            .foregroundStyle(AegisColors.textPrimary)
                            .lineLimit(1)

                        Spacer()

                        // Auto-fill button
                        Button {
                            editingText = suggestion
                        } label: {
                            Image(systemName: "arrow.up.left")
                                .font(.caption2)
                                .foregroundStyle(AegisColors.textTertiary)
                        }
                    }
                    .padding(.horizontal, AegisSpacing.md)
                    .padding(.vertical, AegisSpacing.xs)
                }
                .accessibilityLabel(String(localized: "suggestion_label \(suggestion)"))

                if suggestion != suggestionService.suggestions.last {
                    Divider()
                        .padding(.leading, AegisSpacing.md + 20 + AegisSpacing.sm)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AegisColors.backgroundPrimary)
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        )
        .padding(.top, 2)
        .transition(.opacity.combined(with: .move(edge: .top)))
        .animation(.easeOut(duration: 0.2), value: suggestionService.suggestions)
    }

    // MARK: - Helpers

    private func submitQuery(_ text: String) {
        onSubmit(text)
        isEditing = false
        isFocused = false
        suggestionService.clear()
    }

    @ViewBuilder
    private var securityIcon: some View {
        if isSecure {
            Image(systemName: "lock.fill")
                .font(.caption)
                .foregroundStyle(AegisColors.success)
                .accessibilityLabel(String(localized: "secure_connection"))
        } else if !urlString.isEmpty && urlString != "about:blank" {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.caption)
                .foregroundStyle(AegisColors.warning)
                .accessibilityLabel(String(localized: "insecure_connection"))
        } else {
            Image(systemName: "magnifyingglass")
                .font(.caption)
                .foregroundStyle(AegisColors.textTertiary)
        }
    }
}
