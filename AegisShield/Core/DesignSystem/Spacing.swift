import SwiftUI

/// Consistent spacing and sizing tokens.
enum AegisSpacing {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64

    // MARK: - Component-Specific

    static let cardPadding: CGFloat = 16
    static let cardCornerRadius: CGFloat = 16
    static let buttonCornerRadius: CGFloat = 14
    static let inputCornerRadius: CGFloat = 12

    static let toolbarHeight: CGFloat = 44
    static let tabBarHeight: CGFloat = 50
    static let smartBarHeight: CGFloat = 44

    /// Minimum touch target per Apple HIG (44x44 points).
    static let minTouchTarget: CGFloat = 44

    static let iconSizeSmall: CGFloat = 20
    static let iconSizeMedium: CGFloat = 24
    static let iconSizeLarge: CGFloat = 32
    static let iconSizeXL: CGFloat = 48
}
