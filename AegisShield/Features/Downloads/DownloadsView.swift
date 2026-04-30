import SwiftUI

/// Downloads list view showing all downloads with progress and actions.
struct DownloadsView: View {
    @EnvironmentObject private var downloadManager: DownloadManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: DownloadItem?
    @State private var showFilePreview = false
    @State private var showShareSheet = false
    @State private var shareURL: URL?
    @State private var showDeleteConfirmation = false
    @State private var itemToDelete: DownloadItem?

    var body: some View {
        NavigationStack {
            Group {
                if downloadManager.downloads.isEmpty {
                    emptyState
                } else {
                    downloadList
                }
            }
            .navigationTitle(String(localized: "downloads_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "done_button")) {
                        dismiss()
                    }
                }

                if !downloadManager.downloads.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Button(role: .destructive) {
                                downloadManager.clearCompleted()
                            } label: {
                                Label(String(localized: "clear_completed_button"), systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .sheet(isPresented: $showFilePreview) {
                if let item = selectedItem, let url = item.localFileURL {
                    FilePreviewView(fileURL: url, filename: item.suggestedFilename, fileType: item.fileType)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = shareURL {
                    ShareSheet(items: [url])
                }
            }
            .alert(
                String(localized: "delete_download_title"),
                isPresented: $showDeleteConfirmation
            ) {
                Button(String(localized: "delete_button"), role: .destructive) {
                    if let item = itemToDelete {
                        downloadManager.deleteDownload(item)
                    }
                }
                Button(String(localized: "cancel_button"), role: .cancel) {}
            } message: {
                Text(String(localized: "delete_download_message"))
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: AegisSpacing.lg) {
            Image(systemName: "arrow.down.circle")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(AegisColors.textTertiary)

            Text(String(localized: "no_downloads_title"))
                .font(AegisTypography.headlineSmall)
                .foregroundStyle(AegisColors.textPrimary)

            Text(String(localized: "no_downloads_subtitle"))
                .font(AegisTypography.bodySmall)
                .foregroundStyle(AegisColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AegisSpacing.xl)
    }

    // MARK: - Download List

    private var downloadList: some View {
        List {
            // Active downloads
            let active = downloadManager.downloads.filter { $0.status == .downloading }
            if !active.isEmpty {
                Section(String(localized: "active_downloads_section")) {
                    ForEach(active) { item in
                        DownloadRowView(
                            item: item,
                            onCancel: { downloadManager.cancelDownload(item) },
                            onTap: {},
                            onShare: {},
                            onDelete: {}
                        )
                    }
                }
            }

            // Completed downloads
            let completed = downloadManager.downloads.filter { $0.status == .completed }
            if !completed.isEmpty {
                Section(String(localized: "completed_downloads_section")) {
                    ForEach(completed) { item in
                        DownloadRowView(
                            item: item,
                            onCancel: {},
                            onTap: {
                                selectedItem = item
                                showFilePreview = true
                            },
                            onShare: {
                                shareURL = item.localFileURL
                                showShareSheet = true
                            },
                            onDelete: {
                                itemToDelete = item
                                showDeleteConfirmation = true
                            }
                        )
                    }
                }
            }

            // Failed downloads
            let failed = downloadManager.downloads.filter { $0.status == .failed || $0.status == .cancelled }
            if !failed.isEmpty {
                Section(String(localized: "failed_downloads_section")) {
                    ForEach(failed) { item in
                        DownloadRowView(
                            item: item,
                            onCancel: {},
                            onTap: {
                                downloadManager.retryDownload(item)
                            },
                            onShare: {},
                            onDelete: {
                                itemToDelete = item
                                showDeleteConfirmation = true
                            }
                        )
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Download Row

struct DownloadRowView: View {
    @ObservedObject var item: DownloadItem
    let onCancel: () -> Void
    let onTap: () -> Void
    let onShare: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AegisSpacing.sm) {
                // File type icon
                fileTypeIcon

                // File info
                VStack(alignment: .leading, spacing: AegisSpacing.xxxs) {
                    Text(item.suggestedFilename)
                        .font(AegisTypography.bodyMedium)
                        .foregroundStyle(AegisColors.textPrimary)
                        .lineLimit(1)

                    statusLine

                    // Progress bar for active downloads
                    if item.status == .downloading {
                        progressBar
                    }
                }

                Spacer()

                // Actions
                actionButtons
            }
            .padding(.vertical, AegisSpacing.xxs)
        }
        .contextMenu {
            if item.status == .completed {
                Button {
                    onTap()
                } label: {
                    Label(String(localized: "open_file_button"), systemImage: "eye")
                }

                Button {
                    onShare()
                } label: {
                    Label(String(localized: "share_file_button"), systemImage: "square.and.arrow.up")
                }

                Button {
                    saveToFiles()
                } label: {
                    Label(String(localized: "save_to_files_button"), systemImage: "folder")
                }

                Divider()

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label(String(localized: "delete_button"), systemImage: "trash")
                }
            }

            if item.status == .failed {
                Button {
                    onTap()
                } label: {
                    Label(String(localized: "retry_button"), systemImage: "arrow.clockwise")
                }
            }
        }
    }

    // MARK: - File Type Icon

    private var fileTypeIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(item.fileType.color.opacity(0.12))
                .frame(width: 44, height: 44)

            Image(systemName: item.fileType.iconName)
                .font(.system(size: 20))
                .foregroundStyle(item.fileType.color)
        }
    }

    // MARK: - Status Line

    @ViewBuilder
    private var statusLine: some View {
        switch item.status {
        case .downloading:
            HStack(spacing: AegisSpacing.xs) {
                Text(item.formattedProgress)
                    .font(AegisTypography.captionSmall)
                    .foregroundStyle(AegisColors.brandAccent)
                    .fontWeight(.semibold)

                Text("\(item.formattedDownloadedSize) / \(item.formattedTotalSize)")
                    .font(AegisTypography.captionSmall)
                    .foregroundStyle(AegisColors.textTertiary)

                Text(item.formattedSpeed)
                    .font(AegisTypography.captionSmall)
                    .foregroundStyle(AegisColors.textTertiary)
            }

        case .completed:
            Text(item.formattedTotalSize)
                .font(AegisTypography.captionSmall)
                .foregroundStyle(AegisColors.success)

        case .failed:
            Text(item.error ?? String(localized: "download_failed_label"))
                .font(AegisTypography.captionSmall)
                .foregroundStyle(AegisColors.error)
                .lineLimit(1)

        case .cancelled:
            Text(String(localized: "download_cancelled_label"))
                .font(AegisTypography.captionSmall)
                .foregroundStyle(AegisColors.warning)

        case .paused:
            Text(String(localized: "download_paused_label"))
                .font(AegisTypography.captionSmall)
                .foregroundStyle(AegisColors.warning)
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(AegisColors.inputBackground)

                RoundedRectangle(cornerRadius: 3)
                    .fill(AegisColors.brandAccent)
                    .frame(width: geo.size.width * item.progress)
                    .animation(.linear(duration: 0.3), value: item.progress)
            }
        }
        .frame(height: 6)
    }

    // MARK: - Action Buttons

    @ViewBuilder
    private var actionButtons: some View {
        switch item.status {
        case .downloading:
            Button(action: onCancel) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(AegisColors.textTertiary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(String(localized: "cancel_download"))

        case .completed:
            HStack(spacing: AegisSpacing.sm) {
                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.body)
                        .foregroundStyle(AegisColors.brandAccent)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(String(localized: "share_file_button"))
            }

        case .failed, .cancelled:
            Button {
                onTap()
            } label: {
                Image(systemName: "arrow.clockwise.circle.fill")
                    .font(.title3)
                    .foregroundStyle(AegisColors.brandAccent)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(String(localized: "retry_button"))

        case .paused:
            EmptyView()
        }
    }

    // MARK: - Save to Files

    private func saveToFiles() {
        guard let localURL = item.localFileURL else { return }
        let controller = UIDocumentPickerViewController(forExporting: [localURL])
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene }).first,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(controller, animated: true)
        }
    }
}

// MARK: - Download Alert Banner

struct DownloadAlertBanner: View {
    @ObservedObject var item: DownloadItem
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AegisSpacing.sm) {
                // Animated download icon
                ZStack {
                    Circle()
                        .stroke(AegisColors.inputBackground, lineWidth: 3)
                        .frame(width: 36, height: 36)

                    Circle()
                        .trim(from: 0, to: item.progress)
                        .stroke(AegisColors.brandAccent, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 36, height: 36)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.3), value: item.progress)

                    Image(systemName: item.status == .completed ? "checkmark" : "arrow.down")
                        .font(.caption)
                        .foregroundStyle(item.status == .completed ? AegisColors.success : AegisColors.brandAccent)
                }

                VStack(alignment: .leading, spacing: AegisSpacing.xxxs) {
                    Text(item.suggestedFilename)
                        .font(AegisTypography.labelMedium)
                        .foregroundStyle(AegisColors.textPrimary)
                        .lineLimit(1)

                    if item.status == .downloading {
                        Text("\(item.formattedProgress) - \(item.formattedDownloadedSize)")
                            .font(AegisTypography.captionSmall)
                            .foregroundStyle(AegisColors.textSecondary)
                    } else if item.status == .completed {
                        Text(String(localized: "tap_to_open_label"))
                            .font(AegisTypography.captionSmall)
                            .foregroundStyle(AegisColors.success)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(AegisColors.textTertiary)
            }
            .padding(AegisSpacing.sm)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: AegisSpacing.cardCornerRadius))
            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        }
        .padding(.horizontal, AegisSpacing.md)
    }
}
