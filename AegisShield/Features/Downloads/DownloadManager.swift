import SwiftUI
import Combine
import UniformTypeIdentifiers

/// Represents a single download task with progress tracking.
@MainActor
final class DownloadItem: ObservableObject, Identifiable {
    let id = UUID()
    let url: URL
    let suggestedFilename: String
    let startedAt: Date

    @Published var progress: Double = 0
    @Published var totalBytes: Int64 = 0
    @Published var downloadedBytes: Int64 = 0
    @Published var status: DownloadStatus = .downloading
    @Published var localFileURL: URL?
    @Published var error: String?
    @Published var mimeType: String?

    enum DownloadStatus: String {
        case downloading
        case paused
        case completed
        case failed
        case cancelled
    }

    var fileExtension: String {
        URL(string: suggestedFilename)?.pathExtension.lowercased()
            ?? url.pathExtension.lowercased()
    }

    var fileType: FileType {
        FileType.from(extension: fileExtension, mimeType: mimeType)
    }

    var formattedProgress: String {
        "\(Int(progress * 100))%"
    }

    var formattedDownloadedSize: String {
        ByteCountFormatter.string(fromByteCount: downloadedBytes, countStyle: .file)
    }

    var formattedTotalSize: String {
        totalBytes > 0
            ? ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file)
            : String(localized: "unknown_size")
    }

    var formattedSpeed: String {
        let elapsed = Date().timeIntervalSince(startedAt)
        guard elapsed > 0 else { return "" }
        let bytesPerSecond = Int64(Double(downloadedBytes) / elapsed)
        return ByteCountFormatter.string(fromByteCount: bytesPerSecond, countStyle: .file) + "/s"
    }

    init(url: URL, suggestedFilename: String) {
        self.url = url
        self.suggestedFilename = suggestedFilename
        self.startedAt = Date()
    }
}

/// File type classification for icon and viewer selection.
enum FileType: String {
    case image
    case video
    case audio
    case pdf
    case document
    case archive
    case code
    case spreadsheet
    case presentation
    case other

    var iconName: String {
        switch self {
        case .image: return "photo"
        case .video: return "film"
        case .audio: return "music.note"
        case .pdf: return "doc.text"
        case .document: return "doc.richtext"
        case .archive: return "archivebox"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .spreadsheet: return "tablecells"
        case .presentation: return "play.rectangle"
        case .other: return "doc"
        }
    }

    var color: Color {
        switch self {
        case .image: return .purple
        case .video: return .red
        case .audio: return .orange
        case .pdf: return .red
        case .document: return .blue
        case .archive: return .gray
        case .code: return .green
        case .spreadsheet: return .green
        case .presentation: return .orange
        case .other: return .gray
        }
    }

    static func from(extension ext: String, mimeType: String? = nil) -> FileType {
        let lower = ext.lowercased()

        // Image types
        if ["jpg", "jpeg", "png", "gif", "bmp", "webp", "heic", "heif", "tiff", "tif", "svg", "ico"].contains(lower) {
            return .image
        }

        // Video types
        if ["mp4", "mov", "avi", "mkv", "wmv", "flv", "webm", "m4v", "3gp", "ts"].contains(lower) {
            return .video
        }

        // Audio types
        if ["mp3", "m4a", "aac", "wav", "flac", "ogg", "wma", "aiff", "opus"].contains(lower) {
            return .audio
        }

        // PDF
        if lower == "pdf" {
            return .pdf
        }

        // Documents
        if ["doc", "docx", "rtf", "txt", "odt", "pages", "md", "epub"].contains(lower) {
            return .document
        }

        // Archives
        if ["zip", "rar", "7z", "tar", "gz", "bz2", "xz", "dmg", "iso"].contains(lower) {
            return .archive
        }

        // Code
        if ["swift", "js", "ts", "py", "java", "html", "css", "json", "xml", "yaml", "yml", "sh", "rb", "go", "rs", "c", "cpp", "h"].contains(lower) {
            return .code
        }

        // Spreadsheet
        if ["xls", "xlsx", "csv", "ods", "numbers"].contains(lower) {
            return .spreadsheet
        }

        // Presentation
        if ["ppt", "pptx", "key", "odp"].contains(lower) {
            return .presentation
        }

        // Try MIME type fallback
        if let mime = mimeType?.lowercased() {
            if mime.hasPrefix("image/") { return .image }
            if mime.hasPrefix("video/") { return .video }
            if mime.hasPrefix("audio/") { return .audio }
            if mime.contains("pdf") { return .pdf }
            if mime.hasPrefix("text/") { return .document }
        }

        return .other
    }
}

/// Manages all file downloads with progress tracking.
@MainActor
final class DownloadManager: NSObject, ObservableObject {
    @Published var downloads: [DownloadItem] = []
    @Published var activeDownloadCount: Int = 0
    @Published var showDownloadAlert: Bool = false
    @Published var latestDownloadItem: DownloadItem?

    private var urlSession: URLSession!
    private var downloadTasks: [URLSessionDownloadTask: DownloadItem] = [:]

    static let downloadsDirectory: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("AegisShield_Downloads", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    override init() {
        super.init()
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = true
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 600
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        loadSavedDownloads()
    }

    // MARK: - Start Download

    func startDownload(url: URL, suggestedFilename: String? = nil) {
        let filename = suggestedFilename ?? url.lastPathComponent
        let item = DownloadItem(url: url, suggestedFilename: filename)

        downloads.insert(item, at: 0)
        activeDownloadCount += 1
        latestDownloadItem = item
        showDownloadAlert = true

        let task = urlSession.downloadTask(with: url)
        downloadTasks[task] = item
        task.resume()
    }

    // MARK: - Cancel Download

    func cancelDownload(_ item: DownloadItem) {
        if let task = downloadTasks.first(where: { $0.value.id == item.id })?.key {
            task.cancel()
            downloadTasks.removeValue(forKey: task)
        }
        item.status = .cancelled
        activeDownloadCount = max(0, activeDownloadCount - 1)
    }

    // MARK: - Delete Download

    func deleteDownload(_ item: DownloadItem) {
        if let localURL = item.localFileURL {
            try? FileManager.default.removeItem(at: localURL)
        }
        downloads.removeAll { $0.id == item.id }
        saveDownloadHistory()
    }

    // MARK: - Clear Completed

    func clearCompleted() {
        let toRemove = downloads.filter { $0.status == .completed || $0.status == .failed || $0.status == .cancelled }
        for item in toRemove {
            if let localURL = item.localFileURL {
                try? FileManager.default.removeItem(at: localURL)
            }
        }
        downloads.removeAll { $0.status == .completed || $0.status == .failed || $0.status == .cancelled }
        saveDownloadHistory()
    }

    // MARK: - Retry Failed

    func retryDownload(_ item: DownloadItem) {
        // Only cancel the task if still active; don't decrement count for already-failed items
        if let task = downloadTasks.first(where: { $0.value.id == item.id })?.key {
            task.cancel()
            downloadTasks.removeValue(forKey: task)
            activeDownloadCount = max(0, activeDownloadCount - 1)
        }
        deleteDownload(item)
        startDownload(url: item.url, suggestedFilename: item.suggestedFilename)
    }

    // MARK: - Persistence

    private func saveDownloadHistory() {
        let completed = downloads.filter { $0.status == .completed && $0.localFileURL != nil }
        let entries: [[String: String]] = completed.map {
            [
                "url": $0.url.absoluteString,
                "filename": $0.suggestedFilename,
                "localPath": $0.localFileURL?.path ?? "",
                "mimeType": $0.mimeType ?? "",
            ]
        }
        UserDefaults.standard.set(entries, forKey: "downloadHistory")
    }

    private func loadSavedDownloads() {
        guard let entries = UserDefaults.standard.array(forKey: "downloadHistory") as? [[String: String]] else { return }

        for entry in entries {
            guard let urlString = entry["url"], let url = URL(string: urlString),
                  let filename = entry["filename"],
                  let localPath = entry["localPath"], !localPath.isEmpty else { continue }

            let localURL = URL(fileURLWithPath: localPath)
            guard FileManager.default.fileExists(atPath: localURL.path) else { continue }

            let item = DownloadItem(url: url, suggestedFilename: filename)
            item.status = .completed
            item.localFileURL = localURL
            item.mimeType = entry["mimeType"]
            item.progress = 1.0
            downloads.append(item)
        }
    }

    // MARK: - File Operations

    func getUniqueFilename(for filename: String) -> URL {
        Self.computeUniqueFilename(for: filename)
    }

    /// Computes a unique file path in the downloads directory. Nonisolated so it
    /// can be called synchronously from URLSession delegate callbacks.
    nonisolated static func computeUniqueFilename(for filename: String) -> URL {
        var url = downloadsDirectory.appendingPathComponent(filename)
        var counter = 1
        let name = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension

        while FileManager.default.fileExists(atPath: url.path) {
            let newName = ext.isEmpty ? "\(name)_\(counter)" : "\(name)_\(counter).\(ext)"
            url = downloadsDirectory.appendingPathComponent(newName)
            counter += 1
        }
        return url
    }
}

// MARK: - URLSessionDownloadDelegate

extension DownloadManager: URLSessionDownloadDelegate {
    nonisolated func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        // The system deletes the temp file when this method returns, so the
        // file MUST be moved synchronously—before any async dispatch.
        let suggestedName = downloadTask.response?.suggestedFilename
            ?? downloadTask.originalRequest?.url?.lastPathComponent
            ?? "download"
        let destinationURL = Self.computeUniqueFilename(for: suggestedName)
        let mimeType = downloadTask.response?.mimeType

        let moveResult: Result<URL, Error>
        do {
            try FileManager.default.moveItem(at: location, to: destinationURL)
            moveResult = .success(destinationURL)
        } catch {
            moveResult = .failure(error)
        }

        // Now update the UI-bound state on the main actor.
        Task { @MainActor in
            guard let item = downloadTasks[downloadTask] else { return }

            switch moveResult {
            case .success(let url):
                item.localFileURL = url
                item.status = .completed
                item.progress = 1.0
                item.mimeType = mimeType
                activeDownloadCount = max(0, activeDownloadCount - 1)
                saveDownloadHistory()
            case .failure(let error):
                item.status = .failed
                item.error = error.localizedDescription
                activeDownloadCount = max(0, activeDownloadCount - 1)
            }

            downloadTasks.removeValue(forKey: downloadTask)
        }
    }

    nonisolated func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        Task { @MainActor in
            guard let item = downloadTasks[downloadTask] else { return }
            item.downloadedBytes = totalBytesWritten
            item.totalBytes = totalBytesExpectedToWrite

            if totalBytesExpectedToWrite > 0 {
                item.progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
            }
        }
    }

    nonisolated func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: (any Error)?
    ) {
        guard let error else { return }
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
            return
        }

        Task { @MainActor in
            if let downloadTask = task as? URLSessionDownloadTask,
               let item = downloadTasks[downloadTask] {
                item.status = .failed
                item.error = error.localizedDescription
                activeDownloadCount = max(0, activeDownloadCount - 1)
                downloadTasks.removeValue(forKey: downloadTask)
            }
        }
    }
}
