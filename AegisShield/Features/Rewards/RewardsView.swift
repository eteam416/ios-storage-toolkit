import SwiftUI

/// Usage rewards dashboard showing streaks, badges, and milestones.
struct RewardsView: View {
    @EnvironmentObject private var rewardsManager: UsageRewardsManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AegisSpacing.lg) {
                    // Streak card
                    streakCard

                    // Next milestone progress
                    milestoneCard

                    // Stats overview
                    statsGrid

                    // Badges grid
                    badgesSection
                }
                .padding(AegisSpacing.md)
            }
            .background(AegisColors.backgroundSecondary)
            .navigationTitle(String(localized: "rewards_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "done_button")) { dismiss() }
                }
            }
        }
    }

    // MARK: - Streak Card

    private var streakCard: some View {
        VStack(spacing: AegisSpacing.sm) {
            // Flame icon with streak count
            HStack(spacing: AegisSpacing.xs) {
                Image(systemName: rewardsManager.currentStreak > 0 ? "flame.fill" : "flame")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        rewardsManager.currentStreak >= 7
                            ? .orange
                            : (rewardsManager.currentStreak > 0 ? .yellow : AegisColors.textTertiary)
                    )
                    .symbolEffect(.bounce, value: rewardsManager.currentStreak)

                VStack(alignment: .leading) {
                    Text("\(rewardsManager.currentStreak)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(AegisColors.textPrimary)

                    Text(String(localized: "day_streak_label"))
                        .font(AegisTypography.captionSmall)
                        .foregroundStyle(AegisColors.textSecondary)
                }
            }

            // Best streak
            Text(String(localized: "best_streak_label \(rewardsManager.longestStreak)"))
                .font(AegisTypography.captionSmall)
                .foregroundStyle(AegisColors.textTertiary)

            // Streak calendar (last 7 days)
            HStack(spacing: AegisSpacing.xs) {
                ForEach(0..<7, id: \.self) { dayOffset in
                    let dayActive = dayOffset < rewardsManager.currentStreak
                    Circle()
                        .fill(dayActive ? AegisColors.brandAccent : AegisColors.inputBackground)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Text(dayLabel(dayOffset))
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(dayActive ? .white : AegisColors.textTertiary)
                        )
                }
            }
        }
        .padding(AegisSpacing.lg)
        .background(AegisColors.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: AegisSpacing.cardCornerRadius))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    // MARK: - Milestone Card

    private var milestoneCard: some View {
        VStack(spacing: AegisSpacing.sm) {
            HStack {
                Text(String(localized: "next_milestone_label"))
                    .font(AegisTypography.labelMedium)
                    .foregroundStyle(AegisColors.textPrimary)
                Spacer()
                Text(rewardsManager.nextMilestone)
                    .font(AegisTypography.captionSmall)
                    .foregroundStyle(AegisColors.brandAccent)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AegisColors.inputBackground)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [AegisColors.brandPrimary, AegisColors.brandAccent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * rewardsManager.progressToNextMilestone)
                        .animation(.spring(response: 0.6), value: rewardsManager.progressToNextMilestone)
                }
            }
            .frame(height: 12)

            Text("\(Int(rewardsManager.progressToNextMilestone * 100))%")
                .font(AegisTypography.captionSmall)
                .foregroundStyle(AegisColors.textTertiary)
        }
        .padding(AegisSpacing.lg)
        .background(AegisColors.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: AegisSpacing.cardCornerRadius))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
        ], spacing: AegisSpacing.sm) {
            statCell(
                value: "\(rewardsManager.totalDaysUsed)",
                label: String(localized: "total_days_stat"),
                icon: "calendar",
                color: .blue
            )
            statCell(
                value: "\(rewardsManager.totalPagesViewed)",
                label: String(localized: "pages_visited_stat"),
                icon: "globe",
                color: .green
            )
            statCell(
                value: "\(rewardsManager.totalAdsBlocked)",
                label: String(localized: "lifetime_ads_blocked_stat"),
                icon: "shield.fill",
                color: .red
            )
            statCell(
                value: "\(rewardsManager.totalTrackersBlocked)",
                label: String(localized: "lifetime_trackers_blocked_stat"),
                icon: "eye.slash.fill",
                color: .teal
            )
        }
    }

    private func statCell(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: AegisSpacing.xs) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(AegisColors.textPrimary)
            Text(label)
                .font(AegisTypography.captionSmall)
                .foregroundStyle(AegisColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(AegisSpacing.md)
        .background(AegisColors.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: AegisSpacing.cardCornerRadius))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 1)
    }

    // MARK: - Badges Section

    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: AegisSpacing.sm) {
            HStack {
                Text(String(localized: "badges_title"))
                    .font(AegisTypography.headlineSmall)
                    .foregroundStyle(AegisColors.textPrimary)
                Spacer()
                Text("\(rewardsManager.unlockedBadges.count)/\(UsageRewardsManager.Badge.allCases.count)")
                    .font(AegisTypography.captionSmall)
                    .foregroundStyle(AegisColors.textTertiary)
            }

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
            ], spacing: AegisSpacing.sm) {
                ForEach(UsageRewardsManager.Badge.allCases) { badge in
                    badgeCell(badge)
                }
            }
        }
        .padding(AegisSpacing.lg)
        .background(AegisColors.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: AegisSpacing.cardCornerRadius))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
    }

    private func badgeCell(_ badge: UsageRewardsManager.Badge) -> some View {
        let isUnlocked = rewardsManager.unlockedBadges.contains(badge)

        return VStack(spacing: AegisSpacing.xxs) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? badge.color.opacity(0.15) : AegisColors.inputBackground)
                    .frame(width: 52, height: 52)

                Image(systemName: badge.iconName)
                    .font(.system(size: 22))
                    .foregroundStyle(isUnlocked ? badge.color : AegisColors.textTertiary)
            }

            Text(badge.name)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(isUnlocked ? AegisColors.textPrimary : AegisColors.textTertiary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .opacity(isUnlocked ? 1.0 : 0.5)
    }

    // MARK: - Helpers

    private func dayLabel(_ dayOffset: Int) -> String {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: -(6 - dayOffset), to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
}

// MARK: - Badge Unlock Alert

struct BadgeUnlockOverlay: View {
    let badge: UsageRewardsManager.Badge
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: AegisSpacing.md) {
            Text(String(localized: "badge_unlocked_title"))
                .font(AegisTypography.labelMedium)
                .foregroundStyle(AegisColors.textSecondary)

            ZStack {
                Circle()
                    .fill(badge.color.opacity(0.2))
                    .frame(width: 80, height: 80)

                Image(systemName: badge.iconName)
                    .font(.system(size: 36))
                    .foregroundStyle(badge.color)
                    .symbolEffect(.bounce)
            }

            Text(badge.name)
                .font(AegisTypography.headlineSmall)
                .foregroundStyle(AegisColors.textPrimary)

            Text(badge.description)
                .font(AegisTypography.bodySmall)
                .foregroundStyle(AegisColors.textSecondary)
                .multilineTextAlignment(.center)

            Button(String(localized: "awesome_button")) {
                onDismiss()
            }
            .buttonStyle(.borderedProminent)
            .tint(badge.color)
        }
        .padding(AegisSpacing.xl)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
        .padding(AegisSpacing.xl)
    }
}
