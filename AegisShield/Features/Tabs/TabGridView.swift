import SwiftUI

/// Grid view for managing open tabs.
struct TabGridView: View {
    @ObservedObject var tabManager: TabManager
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible(), spacing: AegisSpacing.sm),
        GridItem(.flexible(), spacing: AegisSpacing.sm),
    ]

    var body: some View {
        let isIncognito = tabManager.isIncognitoMode

        NavigationStack {
            VStack(spacing: 0) {
                // Mode Picker
                Picker("", selection: $tabManager.isIncognitoMode) {
                    Text(String(localized: "normal_tabs_label")).tag(false)
                    Text(String(localized: "incognito_tabs_label")).tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, AegisSpacing.lg)
                .padding(.vertical, AegisSpacing.sm)

                // Tab Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: AegisSpacing.sm) {
                        ForEach(tabManager.activeTabs) { tab in
                            TabGridCell(
                                tab: tab,
                                isActive: tab.id == tabManager.activeTabID,
                                isIncognito: tab.isIncognito,
                                onTap: {
                                    tabManager.switchToTab(tab)
                                    dismiss()
                                },
                                onClose: {
                                    tabManager.closeTab(tab)
                                }
                            )
                        }
                    }
                    .padding(AegisSpacing.sm)
                }

                // New Tab button
                Button {
                    tabManager.createNewTab(isIncognito: isIncognito)
                    dismiss()
                } label: {
                    Label(
                        String(localized: "new_tab_button"),
                        systemImage: "plus"
                    )
                    .font(AegisTypography.labelLarge)
                    .foregroundStyle(isIncognito ? AegisColors.incognitoAccent : AegisColors.brandAccent)
                    .frame(maxWidth: .infinity)
                    .frame(height: AegisSpacing.minTouchTarget)
                }
                .padding(.bottom, AegisSpacing.sm)
            }
            .background(
                isIncognito ? AegisColors.incognitoBackground : AegisColors.backgroundPrimary
            )
            .navigationTitle(String(localized: "tabs_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "done_button")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Tab Grid Cell

private struct TabGridCell: View {
    let tab: BrowserTab
    let isActive: Bool
    let isIncognito: Bool
    let onTap: () -> Void
    let onClose: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: AegisSpacing.xs) {
                // Tab header with close button
                HStack {
                    if tab.viewModel.isSecure {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundStyle(AegisColors.success)
                    }

                    Text(tab.title)
                        .font(AegisTypography.tabTitle)
                        .foregroundStyle(
                            isIncognito ? AegisColors.incognitoText : AegisColors.textPrimary
                        )
                        .lineLimit(1)

                    Spacer()

                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.caption2)
                            .foregroundStyle(AegisColors.textTertiary)
                            .frame(width: 24, height: 24)
                    }
                    .accessibilityLabel(String(localized: "close_tab"))
                }

                // URL preview
                Text(tab.displayURL)
                    .font(AegisTypography.captionSmall)
                    .foregroundStyle(AegisColors.textTertiary)
                    .lineLimit(1)

                // Placeholder for page preview
                Rectangle()
                    .fill(
                        isIncognito ? AegisColors.incognitoElevated : AegisColors.inputBackground
                    )
                    .frame(height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        if isIncognito {
                            Image(systemName: "eye.slash")
                                .foregroundStyle(AegisColors.incognitoTextSecondary)
                        }
                    }
            }
            .padding(AegisSpacing.sm)
            .background(
                isIncognito ? AegisColors.incognitoSurface : AegisColors.cardBackground
            )
            .clipShape(RoundedRectangle(cornerRadius: AegisSpacing.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AegisSpacing.cardCornerRadius)
                    .stroke(
                        isActive
                            ? (isIncognito ? AegisColors.incognitoAccent : AegisColors.brandAccent)
                            : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .accessibilityLabel("\(tab.title)")
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }
}
