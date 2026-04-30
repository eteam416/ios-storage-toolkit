import SwiftUI
import WebKit

/// Distraction-free reader mode that extracts main content from web pages.
struct ReaderModeView: View {
    let url: URL
    let title: String
    @Environment(\.dismiss) private var dismiss

    @State private var content: String = ""
    @State private var isLoading = true
    @State private var fontSize: CGFloat = 18
    @State private var isDarkMode = false
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()

                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: AegisSpacing.md) {
                            // Article title
                            Text(title)
                                .font(.system(size: fontSize + 8, weight: .bold))
                                .foregroundStyle(textColor)
                                .padding(.bottom, AegisSpacing.xs)

                            // Source domain
                            Text(url.host?.replacingOccurrences(of: "www.", with: "") ?? "")
                                .font(.system(size: fontSize - 4))
                                .foregroundStyle(isDarkMode ? .gray : AegisColors.textTertiary)

                            Divider()

                            // Article content
                            Text(content)
                                .font(.system(size: fontSize))
                                .foregroundStyle(textColor)
                                .lineSpacing(fontSize * 0.6)
                                .textSelection(.enabled)
                        }
                        .padding(AegisSpacing.lg)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "done_button")) { dismiss() }
                }

                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: AegisSpacing.sm) {
                        // Font size controls
                        Button {
                            fontSize = max(12, fontSize - 2)
                        } label: {
                            Image(systemName: "textformat.size.smaller")
                        }

                        Button {
                            fontSize = min(32, fontSize + 2)
                        } label: {
                            Image(systemName: "textformat.size.larger")
                        }

                        // Dark mode toggle
                        Button {
                            isDarkMode.toggle()
                        } label: {
                            Image(systemName: isDarkMode ? "sun.max" : "moon")
                        }
                    }
                }
            }
            .task {
                await extractContent()
            }
        }
    }

    private var backgroundColor: Color {
        isDarkMode ? Color(white: 0.1) : Color(white: 0.97)
    }

    private var textColor: Color {
        isDarkMode ? .white : .black
    }

    /// Extracts readable content from the web page using JavaScript.
    private func extractContent() async {
        isLoading = true

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let html = String(data: data, encoding: .utf8) {
                content = extractTextFromHTML(html)
            } else {
                content = String(localized: "reader_mode_error")
            }
        } catch {
            content = String(localized: "reader_mode_error")
        }

        isLoading = false
    }

    /// Basic HTML text extraction — removes tags, scripts, styles, and navigation.
    private func extractTextFromHTML(_ html: String) -> String {
        var text = html

        // Remove script and style blocks
        text = text.replacingOccurrences(
            of: "<script[^>]*>[\\s\\S]*?</script>",
            with: "",
            options: .regularExpression
        )
        text = text.replacingOccurrences(
            of: "<style[^>]*>[\\s\\S]*?</style>",
            with: "",
            options: .regularExpression
        )

        // Remove navigation, header, footer, sidebar
        let removeElements = ["nav", "header", "footer", "aside", "menu"]
        for element in removeElements {
            text = text.replacingOccurrences(
                of: "<\(element)[^>]*>[\\s\\S]*?</\(element)>",
                with: "",
                options: .regularExpression
            )
        }

        // Convert paragraph breaks to newlines
        text = text.replacingOccurrences(of: "</p>", with: "\n\n")
        text = text.replacingOccurrences(of: "<br[^>]*>", with: "\n", options: .regularExpression)
        text = text.replacingOccurrences(of: "</h[1-6]>", with: "\n\n", options: .regularExpression)
        text = text.replacingOccurrences(of: "</li>", with: "\n")
        text = text.replacingOccurrences(of: "</div>", with: "\n")

        // Remove remaining HTML tags
        text = text.replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression
        )

        // Decode HTML entities
        text = text.replacingOccurrences(of: "&amp;", with: "&")
        text = text.replacingOccurrences(of: "&lt;", with: "<")
        text = text.replacingOccurrences(of: "&gt;", with: ">")
        text = text.replacingOccurrences(of: "&quot;", with: "\"")
        text = text.replacingOccurrences(of: "&#39;", with: "'")
        text = text.replacingOccurrences(of: "&nbsp;", with: " ")

        // Clean up whitespace
        text = text.replacingOccurrences(
            of: "\\n{3,}",
            with: "\n\n",
            options: .regularExpression
        )
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)

        return text
    }
}
