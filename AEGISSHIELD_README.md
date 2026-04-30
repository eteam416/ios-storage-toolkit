# AegisShield Browser

**Browse Without Boundaries** — A production-ready, international-grade iOS privacy browser with ad blocking, incognito mode, country-aware search defaults, and premium monetization.

## Features

- **Ad & Tracker Blocking** — WKContentRuleListStore-based blocking with layered rules (ads, trackers, annoyances)
- **Incognito Mode** — Premium black theme with WKWebsiteDataStore.nonPersistent() isolation
- **Smart Search Bar** — Unified address/search bar with intelligent URL detection
- **Country-Aware Search Defaults** — Auto-selects appropriate search engine per region (Baidu for China, Yandex for Russia, Naver for Korea, etc.)
- **Multi-Tab Management** — Grid view, tab counts, independent normal/incognito tab groups
- **Premium Monetization** — RevenueCat + StoreKit 2 with yearly (3-day trial) and lifetime plans
- **International Localization** — 12 languages with RTL support
- **Privacy Dashboard** — Honest stats with "exact" vs "estimated" labels
- **Firebase Analytics** — Privacy-safe telemetry with documented event schema

## Architecture

```
AegisShield/
├── App/                    # App entry point, configuration, state management
├── Core/DesignSystem/      # Colors, typography, spacing, reusable components
├── Features/
│   ├── Splash/             # Animated splash screen
│   ├── LanguageSelection/  # First-launch language picker
│   ├── Onboarding/         # 5-screen onboarding flow
│   ├── Paywall/            # RevenueCat paywall + subscription management
│   ├── Browser/            # WKWebView wrapper, smart bar, toolbar
│   ├── Home/               # Dashboard + country-aware quick shortcuts
│   ├── Tabs/               # Tab management (grid view, create/close/switch)
│   ├── AdBlock/            # WKContentRuleListStore rules + stats
│   ├── Incognito/          # Private browsing with data isolation
│   ├── SearchRouting/      # Country-aware search engine selection
│   ├── Settings/           # All app settings
│   └── Analytics/          # Firebase privacy-safe telemetry
├── Localization/           # 12 language bundles
└── Resources/              # Assets
```

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Dependencies

| Package | Purpose |
|---|---|
| [RevenueCat](https://github.com/RevenueCat/purchases-ios-spm) | Subscription management |
| [RevenueCatUI](https://github.com/RevenueCat/purchases-ios-spm) | Paywalls & Customer Center |
| [Firebase Analytics](https://github.com/firebase/firebase-ios-sdk) | Privacy-safe analytics |
| [Firebase Crashlytics](https://github.com/firebase/firebase-ios-sdk) | Crash reporting |

## Setup

1. Clone the repository
2. Open in Xcode 15+
3. Add packages via Swift Package Manager (Package.swift configured)
4. Add `GoogleService-Info.plist` for Firebase
5. Configure RevenueCat API key in `Configuration.swift`
6. Configure products in RevenueCat dashboard:
   - Product ID: `yearly` (annual subscription with 3-day trial)
   - Product ID: `lifetime` (one-time purchase)
   - Entitlement: `iOS Browser App Pro`
7. Build and run on iOS 17+ device/simulator

## RevenueCat Integration

This app uses RevenueCat SDK for all monetization:

- **SDK Installation:** Swift Package Manager via `https://github.com/RevenueCat/purchases-ios-spm.git`
- **Libraries:** `RevenueCat` + `RevenueCatUI`
- **Configuration:** `Purchases.configure(with: .init(withAPIKey: "your_key"))` in App init
- **Entitlement:** `iOS Browser App Pro`
- **Products:** yearly (with 3-day trial), lifetime
- **Paywall:** Custom SwiftUI paywall with RevenueCat remote paywall fallback
- **Customer Center:** RevenueCat CustomerCenterView in Settings
- **Restore:** `Purchases.shared.restorePurchases()` available in paywall and settings

## Apple Compliance

- Uses WKWebView exclusively (App Store requirement for iOS browsers)
- Ad blocking via WKContentRuleListStore (Apple-approved API)
- Subscription disclosures meet all App Store requirements
- Free mode available without purchase (review-friendly)
- Privacy labels match actual data collection

## Documentation

- [Market Research](Documentation/MARKET_RESEARCH.md)
- [Branding & App Names](Documentation/BRANDING.md)
- [Architecture](Documentation/ARCHITECTURE.md)
- [UX Flows](Documentation/UX_FLOWS.md)
- [Apple Compliance](Documentation/APPLE_COMPLIANCE.md)
- [QA Test Matrix](Documentation/QA_TEST_MATRIX.md)
- [Launch Checklist & Roadmap](Documentation/LAUNCH_CHECKLIST.md)

## Support

Contact: developer.nasar416@gmail.com

## License

Proprietary. All rights reserved.
