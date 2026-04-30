import SwiftUI
import QuickLook
import AVKit
import PDFKit
import WebKit

/// Universal file preview view supporting PDF, images, video, audio, and all other file types.
/// Uses QuickLook as fallback for unsupported types.
struct FilePreviewView: View {
    let fileURL: URL
    let filename: String
    let fileType: FileType

    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    @State private var showSaveDialog = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // File content viewer
                fileViewer
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Action bar
                actionBar
            }
            .navigationTitle(filename)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "done_button")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showShareSheet = true
                        } label: {
                            Label(String(localized: "share_file_button"), systemImage: "square.and.arrow.up")
                        }

                        Button {
                            saveToFiles()
                        } label: {
                            Label(String(localized: "save_to_files_button"), systemImage: "folder")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: [fileURL])
            }
        }
    }

    // MARK: - File Viewer

    @ViewBuilder
    private var fileViewer: some View {
        switch fileType {
        case .image:
            ImageViewer(fileURL: fileURL)

        case .video:
            VideoPlayerView(fileURL: fileURL)

        case .audio:
            AudioPlayerView(fileURL: fileURL, filename: filename)

        case .pdf:
            PDFViewerRepresentable(fileURL: fileURL)

        case .document, .code:
            TextFileViewer(fileURL: fileURL)

        default:
            QuickLookPreview(fileURL: fileURL)
        }
    }

    // MARK: - Action Bar

    private var actionBar: some View {
        HStack(spacing: AegisSpacing.xl) {
            actionButton(icon: "square.and.arrow.up", label: String(localized: "share_button_label")) {
                showShareSheet = true
            }

            actionButton(icon: "folder", label: String(localized: "save_button_label")) {
                saveToFiles()
            }
        }
        .padding(.vertical, AegisSpacing.sm)
        .background(AegisColors.backgroundSecondary)
    }

    private func actionButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: AegisSpacing.xxxs) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(AegisColors.brandAccent)
                Text(label)
                    .font(AegisTypography.captionSmall)
                    .foregroundStyle(AegisColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .accessibilityLabel(label)
    }

    private func saveToFiles() {
        let controller = UIDocumentPickerViewController(forExporting: [fileURL])
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene }).first,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(controller, animated: true)
        }
    }
}

// MARK: - Image Viewer

struct ImageViewer: View {
    let fileURL: URL
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    var body: some View {
        GeometryReader { geo in
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                if let data = try? Data(contentsOf: fileURL),
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: geo.size.width * scale,
                            height: geo.size.height * scale
                        )
                        .scaleEffect(scale)
                        .gesture(
                            MagnifyGesture()
                                .onChanged { value in
                                    scale = lastScale * value.magnification
                                }
                                .onEnded { _ in
                                    lastScale = scale
                                    if scale < 1.0 {
                                        withAnimation {
                                            scale = 1.0
                                            lastScale = 1.0
                                        }
                                    }
                                }
                        )
                        .gesture(
                            TapGesture(count: 2)
                                .onEnded {
                                    withAnimation {
                                        if scale > 1.0 {
                                            scale = 1.0
                                            lastScale = 1.0
                                        } else {
                                            scale = 2.5
                                            lastScale = 2.5
                                        }
                                    }
                                }
                        )
                } else {
                    fileLoadError
                }
            }
        }
        .background(Color.black)
    }
}

// MARK: - Video Player

struct VideoPlayerView: View {
    let fileURL: URL
    @State private var player: AVPlayer?

    var body: some View {
        VideoPlayer(player: player ?? AVPlayer(url: fileURL))
            .onAppear {
                player = AVPlayer(url: fileURL)
            }
            .onDisappear {
                player?.pause()
                player = nil
            }
    }
}

// MARK: - Audio Player

struct AudioPlayerView: View {
    let fileURL: URL
    let filename: String
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: AegisSpacing.xl) {
            Spacer()

            // Album art placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [AegisColors.brandPrimary, AegisColors.brandAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                    .shadow(color: AegisColors.brandAccent.opacity(0.3), radius: 20, y: 10)

                Image(systemName: "music.note")
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(.white)
            }

            // File name
            Text(filename)
                .font(AegisTypography.headlineSmall)
                .foregroundStyle(AegisColors.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AegisSpacing.lg)

            // Progress slider
            VStack(spacing: AegisSpacing.xxs) {
                Slider(value: $currentTime, in: 0...max(duration, 1)) { editing in
                    if !editing {
                        player?.seek(to: CMTime(seconds: currentTime, preferredTimescale: 600))
                    }
                }
                .tint(AegisColors.brandAccent)

                HStack {
                    Text(formatTime(currentTime))
                        .font(AegisTypography.captionSmall)
                        .foregroundStyle(AegisColors.textTertiary)
                    Spacer()
                    Text(formatTime(duration))
                        .font(AegisTypography.captionSmall)
                        .foregroundStyle(AegisColors.textTertiary)
                }
            }
            .padding(.horizontal, AegisSpacing.xl)

            // Controls
            HStack(spacing: AegisSpacing.xxl) {
                // Rewind 15s
                Button {
                    seek(by: -15)
                } label: {
                    Image(systemName: "gobackward.15")
                        .font(.title2)
                        .foregroundStyle(AegisColors.textPrimary)
                }
                .accessibilityLabel(String(localized: "rewind_15"))

                // Play/Pause
                Button {
                    togglePlayPause()
                } label: {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(AegisColors.brandAccent)
                }
                .accessibilityLabel(isPlaying
                    ? String(localized: "pause_button_label")
                    : String(localized: "play_button_label"))

                // Forward 15s
                Button {
                    seek(by: 15)
                } label: {
                    Image(systemName: "goforward.15")
                        .font(.title2)
                        .foregroundStyle(AegisColors.textPrimary)
                }
                .accessibilityLabel(String(localized: "forward_15"))
            }

            Spacer()
        }
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
            timer?.invalidate()
        }
    }

    private func setupPlayer() {
        player = AVPlayer(url: fileURL)
        if let asset = player?.currentItem?.asset {
            Task {
                let dur = try? await asset.load(.duration)
                if let dur {
                    duration = CMTimeGetSeconds(dur)
                }
            }
        }
        startTimer()
    }

    private func togglePlayPause() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
    }

    private func seek(by seconds: Double) {
        let newTime = max(0, min(currentTime + seconds, duration))
        player?.seek(to: CMTime(seconds: newTime, preferredTimescale: 600))
        currentTime = newTime
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            guard let player else { return }
            let time = CMTimeGetSeconds(player.currentTime())
            if time.isFinite {
                Task { @MainActor in
                    currentTime = time
                }
            }
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite else { return "0:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: - PDF Viewer

struct PDFViewerRepresentable: UIViewRepresentable {
    let fileURL: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        if let document = PDFDocument(url: fileURL) {
            pdfView.document = document
        }
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}

// MARK: - Text File Viewer

struct TextFileViewer: View {
    let fileURL: URL
    @State private var content: String = ""
    @State private var loadError: String?

    var body: some View {
        ScrollView {
            if let loadError {
                fileLoadErrorView(message: loadError)
            } else {
                Text(content)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(AegisColors.textPrimary)
                    .textSelection(.enabled)
                    .padding(AegisSpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .onAppear {
            loadTextFile()
        }
    }

    private func loadTextFile() {
        do {
            content = try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            // Try other encodings
            if let data = try? Data(contentsOf: fileURL),
               let str = String(data: data, encoding: .ascii) {
                content = str
            } else {
                loadError = error.localizedDescription
            }
        }
    }

    private func fileLoadErrorView(message: String) -> some View {
        VStack(spacing: AegisSpacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(AegisColors.warning)
            Text(String(localized: "file_open_error_title"))
                .font(AegisTypography.headlineSmall)
            Text(message)
                .font(AegisTypography.bodySmall)
                .foregroundStyle(AegisColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AegisSpacing.xl)
    }
}

// MARK: - QuickLook Preview (Fallback for all other file types)

struct QuickLookPreview: UIViewControllerRepresentable {
    let fileURL: URL

    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(fileURL: fileURL)
    }

    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let fileURL: URL

        init(fileURL: URL) {
            self.fileURL = fileURL
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            fileURL as QLPreviewItem
        }
    }
}

// MARK: - File Load Error View

private var fileLoadError: some View {
    VStack(spacing: AegisSpacing.md) {
        Image(systemName: "exclamationmark.triangle")
            .font(.system(size: 48))
            .foregroundStyle(AegisColors.warning)
        Text(String(localized: "file_open_error_title"))
            .font(AegisTypography.headlineSmall)
        Text(String(localized: "file_open_error_subtitle"))
            .font(AegisTypography.bodySmall)
            .foregroundStyle(AegisColors.textSecondary)
    }
    .padding(AegisSpacing.xl)
}
