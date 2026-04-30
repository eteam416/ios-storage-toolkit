import SwiftUI

/// Represents a single browser tab.
struct BrowserTab: Identifiable {
    let id = UUID()
    let viewModel: BrowserViewModel
    let isIncognito: Bool
    var createdAt = Date()

    var title: String {
        viewModel.pageTitle.isEmpty
            ? (viewModel.currentURL?.host ?? String(localized: "new_tab_title"))
            : viewModel.pageTitle
    }

    var displayURL: String {
        viewModel.currentURL?.host ?? ""
    }
}

/// Manages multiple browser tabs for both normal and incognito modes.
@MainActor
final class TabManager: ObservableObject {
    @Published var normalTabs: [BrowserTab] = []
    @Published var incognitoTabs: [BrowserTab] = []
    @Published var activeNormalTabID: UUID?
    @Published var activeIncognitoTabID: UUID?
    @Published var isIncognitoMode: Bool = false

    var activeTabs: [BrowserTab] {
        isIncognitoMode ? incognitoTabs : normalTabs
    }

    var activeTabID: UUID? {
        get { isIncognitoMode ? activeIncognitoTabID : activeNormalTabID }
        set {
            if isIncognitoMode {
                activeIncognitoTabID = newValue
            } else {
                activeNormalTabID = newValue
            }
        }
    }

    var activeTab: BrowserTab? {
        guard let id = activeTabID else { return nil }
        return activeTabs.first { $0.id == id }
    }

    var tabCount: Int {
        activeTabs.count
    }

    init() {
        createNewTab(isIncognito: false)
    }

    // MARK: - Tab Operations

    @discardableResult
    func createNewTab(isIncognito: Bool) -> BrowserTab {
        let viewModel = BrowserViewModel(isIncognito: isIncognito)
        let tab = BrowserTab(viewModel: viewModel, isIncognito: isIncognito)

        if isIncognito {
            incognitoTabs.append(tab)
            activeIncognitoTabID = tab.id
        } else {
            normalTabs.append(tab)
            activeNormalTabID = tab.id
        }

        return tab
    }

    func closeTab(_ tab: BrowserTab) {
        if tab.isIncognito {
            incognitoTabs.removeAll { $0.id == tab.id }
            if activeIncognitoTabID == tab.id {
                activeIncognitoTabID = incognitoTabs.last?.id
            }
            if incognitoTabs.isEmpty {
                isIncognitoMode = false
            }
        } else {
            normalTabs.removeAll { $0.id == tab.id }
            if activeNormalTabID == tab.id {
                activeNormalTabID = normalTabs.last?.id
            }
            if normalTabs.isEmpty {
                createNewTab(isIncognito: false)
            }
        }
    }

    func switchToTab(_ tab: BrowserTab) {
        if tab.isIncognito {
            isIncognitoMode = true
            activeIncognitoTabID = tab.id
        } else {
            isIncognitoMode = false
            activeNormalTabID = tab.id
        }
    }

    func closeAllIncognitoTabs() {
        incognitoTabs.removeAll()
        activeIncognitoTabID = nil
        isIncognitoMode = false
    }

    func toggleIncognitoMode() {
        isIncognitoMode.toggle()
        if isIncognitoMode && incognitoTabs.isEmpty {
            createNewTab(isIncognito: true)
        }
    }
}
