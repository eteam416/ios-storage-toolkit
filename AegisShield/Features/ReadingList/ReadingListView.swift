import SwiftUI

/// Reading list view showing saved articles organized by read/unread status.
struct ReadingListView: View {
    @EnvironmentObject private var readingListManager: ReadingListManager
    @Environment(\.dismiss) private var dismiss
    let onOpenURL: (String) -> Void

    var body: some View {
        NavigationStack {
            Group {
                if readingListManager.items.isEmpty {
                    emptyState
                } else {
                    itemList
                }
            }
            .navigationTitle(String(localized: "reading_list_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "done_button")) { dismiss() }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: AegisSpacing.lg) {
            Image(systemName: "book")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(AegisColors.textTertiary)
            Text(String(localized: "no_reading_list_title"))
                .font(AegisTypography.headlineSmall)
            Text(String(localized: "no_reading_list_subtitle"))
                .font(AegisTypography.bodySmall)
                .foregroundStyle(AegisColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AegisSpacing.xl)
    }

    private var itemList: some View {
        List {
            if !readingListManager.unreadItems.isEmpty {
                Section(String(localized: "unread_section")) {
                    ForEach(readingListManager.unreadItems) { item in
                        readingListRow(item)
                    }
                }
            }

            if !readingListManager.readItems.isEmpty {
                Section(String(localized: "read_section")) {
                    ForEach(readingListManager.readItems) { item in
                        readingListRow(item)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func readingListRow(_ item: ReadingListItem) -> some View {
        Button {
            readingListManager.markAsRead(item)
            onOpenURL(item.urlString)
            dismiss()
        } label: {
            HStack(spacing: AegisSpacing.sm) {
                // Unread indicator
                Circle()
                    .fill(item.isRead ? Color.clear : AegisColors.brandAccent)
                    .frame(width: 8, height: 8)

                VStack(alignment: .leading, spacing: AegisSpacing.xxxs) {
                    Text(item.title)
                        .font(AegisTypography.bodyMedium)
                        .foregroundStyle(item.isRead ? AegisColors.textTertiary : AegisColors.textPrimary)
                        .lineLimit(2)

                    HStack(spacing: AegisSpacing.xs) {
                        Text(item.displayDomain)
                            .font(AegisTypography.captionSmall)
                            .foregroundStyle(AegisColors.textTertiary)

                        Text("•")
                            .foregroundStyle(AegisColors.textTertiary)

                        Label(
                            "\(item.estimatedReadingMinutes) min",
                            systemImage: "clock"
                        )
                        .font(AegisTypography.captionSmall)
                        .foregroundStyle(AegisColors.textTertiary)
                    }

                    if !item.excerpt.isEmpty {
                        Text(item.excerpt)
                            .font(AegisTypography.captionSmall)
                            .foregroundStyle(AegisColors.textSecondary)
                            .lineLimit(2)
                    }
                }
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                readingListManager.removeItem(item)
            } label: {
                Label(String(localized: "delete_button"), systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                readingListManager.toggleRead(item)
            } label: {
                Label(
                    item.isRead
                        ? String(localized: "mark_unread_button")
                        : String(localized: "mark_read_button"),
                    systemImage: item.isRead ? "eye.slash" : "eye"
                )
            }
            .tint(AegisColors.brandAccent)
        }
    }
}
