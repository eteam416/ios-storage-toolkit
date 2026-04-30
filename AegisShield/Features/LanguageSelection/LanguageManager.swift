import SwiftUI

/// Manages language selection, persistence, and locale-aware formatting.
final class LanguageManager: ObservableObject {
    struct SupportedLanguage: Identifiable, Hashable {
        let id: String // language code
        let name: String // native name
        let englishName: String
        let isRTL: Bool

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }

    static let supportedLanguages: [SupportedLanguage] = [
        SupportedLanguage(id: "en", name: "English", englishName: "English", isRTL: false),
        SupportedLanguage(id: "ar", name: "\u{0627}\u{0644}\u{0639}\u{0631}\u{0628}\u{064A}\u{0629}", englishName: "Arabic", isRTL: true),
        SupportedLanguage(id: "zh-Hans", name: "\u{7B80}\u{4F53}\u{4E2D}\u{6587}", englishName: "Chinese (Simplified)", isRTL: false),
        SupportedLanguage(id: "es", name: "Espa\u{00F1}ol", englishName: "Spanish", isRTL: false),
        SupportedLanguage(id: "fr", name: "Fran\u{00E7}ais", englishName: "French", isRTL: false),
        SupportedLanguage(id: "de", name: "Deutsch", englishName: "German", isRTL: false),
        SupportedLanguage(id: "ja", name: "\u{65E5}\u{672C}\u{8A9E}", englishName: "Japanese", isRTL: false),
        SupportedLanguage(id: "ko", name: "\u{D55C}\u{AD6D}\u{C5B4}", englishName: "Korean", isRTL: false),
        SupportedLanguage(id: "pt-BR", name: "Portugu\u{00EA}s (Brasil)", englishName: "Portuguese (Brazil)", isRTL: false),
        SupportedLanguage(id: "ru", name: "\u{0420}\u{0443}\u{0441}\u{0441}\u{043A}\u{0438}\u{0439}", englishName: "Russian", isRTL: false),
        SupportedLanguage(id: "hi", name: "\u{0939}\u{093F}\u{0928}\u{094D}\u{0926}\u{0940}", englishName: "Hindi", isRTL: false),
        SupportedLanguage(id: "tr", name: "T\u{00FC}rk\u{00E7}e", englishName: "Turkish", isRTL: false),
    ]

    @Published var selectedLanguage: SupportedLanguage
    @AppStorage("selectedLanguageCode") private var savedLanguageCode: String = ""

    init() {
        let deviceLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        let detected = Self.supportedLanguages.first { $0.id == deviceLanguage }
            ?? Self.supportedLanguages.first { $0.id.hasPrefix(deviceLanguage) }
            ?? Self.supportedLanguages[0]

        let savedCode = UserDefaults.standard.string(forKey: "selectedLanguageCode") ?? ""
        if savedCode.isEmpty {
            self.selectedLanguage = detected
        } else {
            self.selectedLanguage = Self.supportedLanguages.first { $0.id == savedCode } ?? detected
        }
    }

    var currentLocale: Locale {
        Locale(identifier: selectedLanguage.id)
    }

    var layoutDirection: LayoutDirection {
        selectedLanguage.isRTL ? .rightToLeft : .leftToRight
    }

    func selectLanguage(_ language: SupportedLanguage) {
        selectedLanguage = language
        savedLanguageCode = language.id
    }

    func detectedLanguage() -> SupportedLanguage {
        let deviceLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        return Self.supportedLanguages.first { $0.id == deviceLanguage }
            ?? Self.supportedLanguages[0]
    }
}
