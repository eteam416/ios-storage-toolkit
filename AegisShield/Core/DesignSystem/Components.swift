import SwiftUI

// MARK: - Primary Button

struct AegisPrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isFullWidth: Bool = true

    var body: some View {
        Button(action: action) {
            HStack(spacing: AegisSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                }
                Text(title)
                    .font(AegisTypography.labelLarge)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: AegisSpacing.minTouchTarget)
            .background(AegisColors.brandGradient)
            .clipShape(RoundedRectangle(cornerRadius: AegisSpacing.buttonCornerRadius))
        }
        .disabled(isLoading)
        .accessibilityLabel(title)
        .accessibilityHint(isLoading ? String(localized: "loading") : "")
    }
}

// MARK: - Secondary Button

struct AegisSecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AegisTypography.labelLarge)
                .foregroundStyle(AegisColors.brandPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: AegisSpacing.minTouchTarget)
                .background(
                    RoundedRectangle(cornerRadius: AegisSpacing.buttonCornerRadius)
                        .stroke(AegisColors.brandPrimary, lineWidth: 1.5)
                )
        }
        .accessibilityLabel(title)
    }
}

// MARK: - Card View

struct AegisCard<Content: View>: View {
    let content: Content
    var isSelected: Bool = false

    init(isSelected: Bool = false, @ViewBuilder content: () -> Content) {
        self.isSelected = isSelected
        self.content = content()
    }

    var body: some View {
        content
            .padding(AegisSpacing.cardPadding)
            .background(AegisColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AegisSpacing.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AegisSpacing.cardCornerRadius)
                    .stroke(
                        isSelected ? AegisColors.paywallPlanSelectedBorder : Color.clear,
                        lineWidth: 2
                    )
            )
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var subtitle: String? = nil

    var body: some View {
        VStack(spacing: AegisSpacing.xs) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(AegisTypography.statNumber)
                .foregroundStyle(color)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            Text(title)
                .font(AegisTypography.statLabel)
                .foregroundStyle(AegisColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            if let subtitle {
                Text(subtitle)
                    .font(AegisTypography.captionSmall)
                    .foregroundStyle(AegisColors.textTertiary)
                    .italic()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(AegisSpacing.sm)
        .background(AegisColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AegisSpacing.cardCornerRadius))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

// MARK: - Incognito Variants

struct IncognitoPrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AegisTypography.labelLarge)
                .foregroundStyle(AegisColors.incognitoBackground)
                .frame(maxWidth: .infinity)
                .frame(height: AegisSpacing.minTouchTarget)
                .background(AegisColors.incognitoAccent)
                .clipShape(RoundedRectangle(cornerRadius: AegisSpacing.buttonCornerRadius))
        }
        .accessibilityLabel(title)
    }
}
