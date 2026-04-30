import SwiftUI

/// Browsing history view with search and date-grouped sections.
struct HistoryView: View {
    @EnvironmentObject private var historyManager: HistoryManager
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var showClearConfirmation = false
    let onOpenURL: (String) -> Void

    var body: some View {
        NavigationStack {
            Group {
                if historyManager.entries.isEmpty {
                    emptyState
                } else {
                    historyList
                }
            }
            .searchable(text: $searchText, prompt: String(localized: "search_history_placeholder"))
            .navigationTitle(String(localized: "history_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "done_button")) { dismiss() }
                }
                if !historyManager.entries.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Button(role: .destructive) {
                                historyManager.clearToday()
                            } label: {
                                Label(String(localized: "clear_today_button"), systemImage: "clock.badge.xmark")
                            }
                            Button(role: .destructive) {
                                showClearConfirmation = true
                            } label: {
                                Label(String(localized: "clear_all_history_button"), systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .alert(String(localized: "clear_history_title"), isPresented: $showClearConfirmation) {
                Button(String(localized: "clear_button"), role: .destructive) {
                    historyManager.clearHistory()
                }
                Button(String(localized: "cancel_button"), role: .cancel) {}
            } message: {
                Text(String(localized: "clear_history_message"))
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: AegisSpacing.lg) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(AegisColors.textTertiary)
            Text(String(localized: "no_history_title"))
                .font(AegisTypography.headlineSmall)
            Text(String(localized: "no_history_subtitle"))
                .font(AegisTypography.bodySmall)
                .foregroundStyle(AegisColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AegisSpacing.xl)
    }

    private var historyList: some View {
        List {
            let results = searchText.isEmpty
                ? historyManager.groupedByDate()
                : [(String(localized: "search_results_label"), historyManager.search(searchText))]

            ForEach(results, id: \.0) { group in
                Section(group.0) {
                    ForEach(group.1) { entry in
                        historyRow(entry)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func historyRow(_ entry: HistoryEntry) -> some View {
        Button {
            onOpenURL(entry.urlString)
            dismiss()
        } label: {
            HStack(spacing: AegisSpacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AegisColors.brandPrimary.opacity(0.08))
                        .frame(width: 36, height: 36)
                    Text(String(entry.displayDomain.prefix(1)).uppercased())
                        .font(AegisTypography.labelMedium)
                        .foregroundStyle(AegisColors.brandPrimary)
                }

                VStack(alignment: .leading, spacing: AegisSpacing.xxxs) {
                    Text(entry.title.isEmpty ? entry.displayDomain : entry.title)
                        .font(AegisTypography.bodyMedium)
                        .foregroundStyle(AegisColors.textPrimary)
                        .lineLimit(1)
                    Text(entry.displayDomain)
                        .font(AegisTypography.captionSmall)
                        .foregroundStyle(AegisColors.textTertiary)
                        .lineLimit(1)
                }

                Spacer()

                Text(entry.visitedAt, style: .time)
                    .font(AegisTypography.captionSmall)
                    .foregroundStyle(AegisColors.textTertiary)
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                historyManager.deleteEntry(entry)
            } label: {
                Label(String(localized: "delete_button"), systemImage: "trash")
            }
        }
    }
}
