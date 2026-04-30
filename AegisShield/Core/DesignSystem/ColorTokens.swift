import SwiftUI

/// Semantic color tokens for AegisShield design system.
/// Provides consistent colors across light (standard) and dark (incognito) themes.
enum AegisColors {
    // MARK: - Brand Colors

    static let brandPrimary = Color(hex: "1A2B5F")
    static let brandAccent = Color(hex: "00D4FF")
    static let brandGradientStart = Color(hex: "1A2B5F")
    static let brandGradientEnd = Color(hex: "00D4FF")

    // MARK: - Background

    static let backgroundPrimary = Color(.systemBackground)
    static let backgroundSecondary = Color(.secondarySystemBackground)
    static let backgroundTertiary = Color(.tertiarySystemBackground)

    // MARK: - Incognito Theme (Black Premium)

    static let incognitoBackground = Color(hex: "0A0A0A")
    static let incognitoSurface = Color(hex: "1A1A1A")
    static let incognitoElevated = Color(hex: "2A2A2A")
    static let incognitoAccent = Color(hex: "00D4FF")
    static let incognitoText = Color.white
    static let incognitoTextSecondary = Color(hex: "A0A0A0")

    // MARK: - Text

    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)

    // MARK: - UI Elements

    static let separator = Color(.separator)
    static let cardBackground = Color(.secondarySystemBackground)
    static let inputBackground = Color(.tertiarySystemBackground)

    // MARK: - Semantic Colors

    static let success = Color(hex: "34C759")
    static let warning = Color(hex: "FF9500")
    static let error = Color(hex: "FF3B30")
    static let info = Color(hex: "007AFF")

    // MARK: - Ad Block Stats

    static let statsAdsBlocked = Color(hex: "FF6B6B")
    static let statsTrackersBlocked = Color(hex: "4ECDC4")
    static let statsBandwidthSaved = Color(hex: "45B7D1")
    static let statsTimeSaved = Color(hex: "96CEB4")

    // MARK: - Paywall

    static let paywallTrialBadge = Color(hex: "34C759")
    static let paywallPlanHighlight = Color(hex: "00D4FF")
    static let paywallPlanBorder = Color(hex: "E0E0E0")
    static let paywallPlanSelectedBorder = Color(hex: "00D4FF")

    // MARK: - Brand Gradient

    static var brandGradient: LinearGradient {
        LinearGradient(
            colors: [brandGradientStart, brandGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Hex Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
