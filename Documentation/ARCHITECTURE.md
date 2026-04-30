# Architecture Document — AegisShield Browser

## 1. High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    SwiftUI App Layer                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐ │
│  │  Splash   │  │Onboarding│  │  Paywall │  │ Browser │ │
│  │  Screen   │  │  Flow    │  │  Screen  │  │  Home   │ │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬────┘ │
│       │              │              │              │      │
│  ┌────▼──────────────▼──────────────▼──────────────▼────┐│
│  │              Navigation / App State                   ││
│  │           (AppStateManager + Router)                  ││
│  └──────────────────────┬───────────────────────────────┘│
└─────────────────────────┼────────────────────────────────┘
                          │
┌─────────────────────────▼────────────────────────────────┐
│                    Feature Modules                        │
│  ┌───────────┐ ┌──────────┐ ┌───────────┐ ┌───────────┐ │
│  │ BrowserEng│ │  AdBlock  │ │ Incognito │ │  Search   │ │
│  │   ine     │ │  Module   │ │  Module   │ │  Routing  │ │
│  └─────┬─────┘ └────┬─────┘ └─────┬─────┘ └─────┬─────┘ │
│  ┌─────┴─────┐ ┌────┴─────┐ ┌─────┴─────┐ ┌─────┴─────┐ │
│  │Monetizat- │ │Localizat-│ │ Settings  │ │ Analytics │ │
│  │  ion      │ │  ion     │ │  Module   │ │  Module   │ │
│  └───────────┘ └──────────┘ └───────────┘ └───────────┘ │
└──────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────▼────────────────────────────────┐
│                    Core Services                          │
│  ┌───────────┐ ┌──────────┐ ┌───────────┐ ┌───────────┐ │
│  │  Storage   │ │ Keychain │ │  Network  │ │   Theme   │ │
│  │  Manager   │ │  Service │ │  Monitor  │ │  Manager  │ │
│  └───────────┘ └──────────┘ └───────────┘ └───────────┘ │
└──────────────────────────────────────────────────────────┘
```

## 2. Module Breakdown

### 2.1 AppCore
- **Responsibility:** App lifecycle, navigation routing, first-launch flow orchestration
- **Key Classes:**
  - `AegisShieldApp` — SwiftUI @main entry point
  - `AppStateManager` — Observable state for navigation decisions
  - `FirstLaunchCoordinator` — Manages splash → language → onboarding → paywall → home flow

### 2.2 BrowserEngine
- **Responsibility:** WKWebView management, page loading, navigation controls
- **Key Classes:**
  - `WebViewRepresentable` — UIViewRepresentable wrapper for WKWebView
  - `BrowserViewModel` — Tab-level state: URL, title, loading, can go back/forward
  - `TabManager` — Multi-tab state management with @Observable
  - `SmartBarViewModel` — Unified address/search bar logic
- **Data Flow:** SmartBarViewModel → determines URL vs search query → BrowserViewModel → WebViewRepresentable

### 2.3 AdBlock
- **Responsibility:** Content rule compilation, application, stats tracking
- **Key Classes:**
  - `AdBlockManager` — Singleton managing rule compilation and application
  - `ContentRuleStore` — Manages WKContentRuleListStore lifecycle
  - `BlockingStats` — Tracks blocked content counts (honest, per-page + cumulative)
  - `RuleListProvider` — Bundled + remote rule list source management
- **Security Boundary:** Rule lists are compiled once and cached. Remote rules verified via checksum.

### 2.4 SearchRouting
- **Responsibility:** Country-aware search engine defaults, user preference management
- **Key Classes:**
  - `SearchEngineManager` — Engine selection, country detection, preference persistence
  - `SearchEngine` — Model: name, URL template, icon, country codes
  - `CountrySearchDefaults` — Static mapping of country code → default engine
- **Special Logic:** China mainland detection → Baidu fallback when Google unreachable

### 2.5 Incognito
- **Responsibility:** Private browsing mode with isolated data store
- **Key Classes:**
  - `IncognitoManager` — Session lifecycle, data isolation
  - `IncognitoWebViewConfig` — Non-persistent WKWebsiteDataStore configuration
- **Security Boundary:** Incognito tabs use `WKWebsiteDataStore.nonPersistent()`. No data survives session close.

### 2.6 Monetization
- **Responsibility:** RevenueCat SDK integration, paywall presentation, entitlement checking
- **Key Classes:**
  - `SubscriptionManager` — RevenueCat configuration, purchase flow, entitlement checks
  - `PaywallView` — SwiftUI paywall screen with plan cards
  - `CustomerCenterView` — Subscription management UI
- **Products:**
  - `lifetime` — One-time purchase
  - `yearly` — Annual subscription with 3-day free trial
- **Entitlement:** `iOS Browser App Pro`

### 2.7 Localization
- **Responsibility:** Multi-language support, RTL readiness, locale-aware formatting
- **Key Classes:**
  - `LanguageManager` — Language detection, selection, persistence
  - `LocaleFormatter` — Currency, date, number formatting
- **Supported Languages:** en, ar, zh-Hans, es, fr, de, ja, ko, pt-BR, ru, hi, tr

### 2.8 Settings
- **Responsibility:** User preferences UI and persistence
- **Sections:** Subscription, Language, Search Engine, Privacy, Support, Legal

### 2.9 Analytics
- **Responsibility:** Privacy-safe telemetry via Firebase
- **Key Classes:**
  - `AnalyticsManager` — Event logging with consent awareness
  - `EventSchema` — Typed event definitions
- **Privacy Guarantee:** No PII, no full URLs, no data selling. Region-aware consent.

## 3. Data Flow

```
User Input (URL/Search) → SmartBarViewModel
    → URL detected? → Load URL in WebViewRepresentable
    → Search query? → SearchEngineManager.buildSearchURL() → Load in WebViewRepresentable

Page Loading → AdBlockManager intercepts via WKContentRuleList
    → Blocked items counted by BlockingStats
    → Stats displayed in HomeView dashboard

Tab Management → TabManager maintains array of BrowserTab
    → Each tab has own BrowserViewModel
    → Incognito tabs flagged + use non-persistent data store

Subscription → SubscriptionManager checks RevenueCat entitlements
    → Pro features gated by `iOS Browser App Pro` entitlement
    → PaywallView presented when needed
```

## 4. Storage Strategy

| Data | Storage | Rationale |
|------|---------|-----------|
| Subscription status | RevenueCat (server) + Keychain (cache) | Server of record is RevenueCat |
| Language preference | UserDefaults | Non-sensitive, needs fast access |
| Search engine choice | UserDefaults | Non-sensitive preference |
| Browsing history | Core Data / SQLite | Structured, searchable |
| Bookmarks | Core Data / SQLite | Structured, future sync capability |
| Ad block rules (compiled) | WKContentRuleListStore (disk) | WebKit manages caching |
| Ad block stats | UserDefaults | Simple counters |
| Incognito data | WKWebsiteDataStore.nonPersistent() | MUST NOT persist |
| API keys | Keychain | Sensitive credential |
| First-launch flags | UserDefaults | Simple boolean state |
| Analytics consent | UserDefaults | Needs fast access for gating |

## 5. Security Boundaries

1. **Incognito Isolation:** Non-persistent data store. Zero data leakage between normal and incognito.
2. **Keychain for Secrets:** RevenueCat API key stored in build config, not in code (placeholder in source).
3. **No PII in Analytics:** Event schema strictly defines allowed parameters.
4. **Content Rule Integrity:** Remote rules validated via checksum before compilation.
5. **WebView Sandboxing:** Each WKWebView runs in its own process (WebKit default on iOS).
6. **No Data Selling:** Architecture enforces no pathway for exporting user browsing data.

## 6. State Management

- **@Observable pattern** (iOS 17+) for primary state management
- **@AppStorage** for UserDefaults-backed preferences
- **@Environment** for injecting managers via SwiftUI environment
- **Combine** for reactive streams where needed (WebView delegate callbacks)
- **async/await** for all asynchronous operations (no completion handler nesting)
