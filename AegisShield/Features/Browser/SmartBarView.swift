import SwiftUI

/// Unified address/search bar with smart suggestions.
struct SmartBarView: View {
    @Binding var urlString: String
    @EnvironmentObject private var searchEngineManager: SearchEngineManager
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
                    onSubmit(editingText)
                    isEditing = false
                    isFocused = false
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
        }
        .onChange(of: urlString) { _, newValue in
            if !isEditing {
                editingText = newValue
            }
        }
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
