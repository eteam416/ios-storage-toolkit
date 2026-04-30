import SwiftUI

/// Bottom toolbar with navigation controls, tabs, and menu.
struct BrowserToolbar: View {
    @ObservedObject var viewModel: BrowserViewModel
    @ObservedObject var tabManager: TabManager
    let isIncognito: Bool
    let onShowTabs: () -> Void
    let onShowMenu: () -> Void
    let onShare: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            // Back
            toolbarButton(
                icon: "chevron.left",
                label: String(localized: "go_back"),
                isEnabled: viewModel.canGoBack
            ) {
                viewModel.goBack()
            }

            // Forward
            toolbarButton(
                icon: "chevron.right",
                label: String(localized: "go_forward"),
                isEnabled: viewModel.canGoForward
            ) {
                viewModel.goForward()
            }

            // Share
            toolbarButton(
                icon: "square.and.arrow.up",
                label: String(localized: "share_page"),
                isEnabled: viewModel.currentURL != nil
            ) {
                onShare()
            }

            // Tabs
            Button(action: onShowTabs) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(
                            isIncognito ? AegisColors.incognitoText : AegisColors.textPrimary,
                            lineWidth: 1.5
                        )
                        .frame(width: 22, height: 22)

                    Text("\(tabManager.tabCount)")
                        .font(AegisTypography.tabTitle)
                        .foregroundStyle(
                            isIncognito ? AegisColors.incognitoText : AegisColors.textPrimary
                        )
                }
                .frame(maxWidth: .infinity)
                .frame(height: AegisSpacing.minTouchTarget)
            }
            .accessibilityLabel(String(localized: "tabs_count", defaultValue: "\(tabManager.tabCount) tabs"))

            // Menu
            toolbarButton(
                icon: "ellipsis",
                label: String(localized: "more_options"),
                isEnabled: true
            ) {
                onShowMenu()
            }
        }
        .padding(.horizontal, AegisSpacing.xs)
        .frame(height: AegisSpacing.tabBarHeight)
        .background(
            isIncognito ? AegisColors.incognitoSurface : AegisColors.backgroundPrimary
        )
    }

    @ViewBuilder
    private func toolbarButton(
        icon: String,
        label: String,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(
                    isEnabled
                        ? (isIncognito ? AegisColors.incognitoText : AegisColors.textPrimary)
                        : AegisColors.textTertiary
                )
                .frame(maxWidth: .infinity)
                .frame(height: AegisSpacing.minTouchTarget)
        }
        .disabled(!isEnabled)
        .accessibilityLabel(label)
    }
}
