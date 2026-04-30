import SwiftUI

/// Typography scale following Apple Human Interface Guidelines with Dynamic Type support.
enum AegisTypography {
    // MARK: - Display

    static let displayLarge = Font.system(size: 34, weight: .bold, design: .rounded)
    static let displayMedium = Font.system(size: 28, weight: .bold, design: .rounded)
    static let displaySmall = Font.system(size: 22, weight: .bold, design: .rounded)

    // MARK: - Headline

    static let headlineLarge = Font.system(.title, design: .rounded, weight: .semibold)
    static let headlineMedium = Font.system(.title2, design: .rounded, weight: .semibold)
    static let headlineSmall = Font.system(.title3, design: .rounded, weight: .semibold)

    // MARK: - Body

    static let bodyLarge = Font.system(.body, design: .default, weight: .regular)
    static let bodyMedium = Font.system(.callout, design: .default, weight: .regular)
    static let bodySmall = Font.system(.subheadline, design: .default, weight: .regular)

    // MARK: - Label

    static let labelLarge = Font.system(.callout, design: .default, weight: .medium)
    static let labelMedium = Font.system(.footnote, design: .default, weight: .medium)
    static let labelSmall = Font.system(.caption, design: .default, weight: .medium)

    // MARK: - Caption

    static let captionLarge = Font.system(.footnote, design: .default, weight: .regular)
    static let captionSmall = Font.system(.caption2, design: .default, weight: .regular)

    // MARK: - Special

    static let monoSmall = Font.system(.caption, design: .monospaced, weight: .medium)
    static let urlBar = Font.system(.body, design: .default, weight: .regular)
    static let tabTitle = Font.system(.caption, design: .default, weight: .medium)
    static let statNumber = Font.system(size: 28, weight: .bold, design: .rounded)
    static let statLabel = Font.system(.caption2, design: .default, weight: .medium)
    static let paywallPrice = Font.system(size: 32, weight: .bold, design: .rounded)
    static let paywallSubprice = Font.system(.subheadline, design: .default, weight: .regular)
}
