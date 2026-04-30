# QA Test Matrix

## 1. First Launch Flow

| Test Case | Steps | Expected Result | Priority |
|---|---|---|---|
| FL-001: Splash animation | Cold launch app | Shield animates in, title fades up, auto-advances in ~2s | P0 |
| FL-002: Language auto-detect | Launch on device with locale=ja | Japanese pre-selected in language picker | P0 |
| FL-003: Language manual select | Tap Arabic in language list | Arabic selected, UI should prepare for RTL | P0 |
| FL-004: Language search | Type "Fran" in search field | French appears in filtered results | P1 |
| FL-005: Onboarding flow | Swipe through all 5 pages | Each page shows unique content, indicators update | P0 |
| FL-006: Onboarding skip | Tap "Skip" on page 2 | Navigates directly to paywall | P0 |
| FL-007: Paywall display | Complete onboarding | Paywall shows with yearly + lifetime plans | P0 |
| FL-008: Return user bypass | Kill and relaunch after completing flow | Goes directly to Home, skips first-launch flow | P0 |

## 2. Paywall & Purchases

| Test Case | Steps | Expected Result | Priority |
|---|---|---|---|
| PW-001: Plan selection | Tap yearly, then lifetime plan | Selection indicator moves, CTA text updates | P0 |
| PW-002: Yearly pricing display | View yearly plan card | Shows monthly equivalent + annual total with localized pricing | P0 |
| PW-003: Free trial badge | View yearly plan | "3-Day Free Trial" badge visible | P0 |
| PW-004: Purchase flow | Tap "Start Free Trial" | StoreKit purchase sheet appears | P0 |
| PW-005: Restore purchases | Tap "Restore Purchases" with valid receipt | Pro status activates, navigates to Home | P0 |
| PW-006: Restore no purchases | Tap "Restore Purchases" with no history | "No active purchases found" alert | P1 |
| PW-007: Skip paywall | Tap "Continue with limited features" | Navigates to Home in free mode | P0 |
| PW-008: Subscription disclosure | Scroll to bottom of paywall | Auto-renew terms, billing timing, cancellation path visible | P0 |
| PW-009: Legal links | Tap Privacy Policy / Terms links | Opens respective URLs | P1 |
| PW-010: Localized pricing | Test on device with locale=JP | Prices shown in JPY | P1 |

## 3. Browser Core

| Test Case | Steps | Expected Result | Priority |
|---|---|---|---|
| BR-001: URL loading | Type "apple.com" in smart bar, press Go | Apple.com loads, URL bar shows "apple.com" | P0 |
| BR-002: Search query | Type "weather today" in smart bar, press Go | Search engine results page loads | P0 |
| BR-003: HTTPS indicator | Load "https://apple.com" | Green lock icon in smart bar | P0 |
| BR-004: HTTP warning | Load HTTP site | Warning icon in smart bar | P1 |
| BR-005: Back/Forward | Navigate to 3 pages, tap back, then forward | Navigation works correctly | P0 |
| BR-006: Reload | Tap reload while on a page | Page reloads | P0 |
| BR-007: Share | Tap share button | iOS share sheet appears with current URL | P1 |
| BR-008: Target blank links | Click link with target="_blank" | Loads in current tab (not lost) | P1 |
| BR-009: YouTube playback | Navigate to youtube.com, play video | Video plays inline smoothly | P0 |
| BR-010: Google login | Navigate to accounts.google.com | Login flow works without issues | P0 |
| BR-011: Facebook web | Navigate to facebook.com | Login and browsing works | P1 |
| BR-012: Instagram web | Navigate to instagram.com | Content loads and displays correctly | P1 |
| BR-013: TikTok web | Navigate to tiktok.com | Videos play, scrolling smooth | P1 |
| BR-014: Error handling | Enter invalid URL like "https://thissitedoesnotexist.xyz" | Error overlay with retry button | P1 |

## 4. Tab Management

| Test Case | Steps | Expected Result | Priority |
|---|---|---|---|
| TM-001: New tab | Tap + from tab grid | New tab created, shows home screen | P0 |
| TM-002: Close tab | Tap X on tab in grid | Tab closes, adjacent tab becomes active | P0 |
| TM-003: Switch tabs | Tap different tab in grid | Switches to tapped tab | P0 |
| TM-004: Tab count | Open 5 tabs | Tab count indicator shows "5" | P1 |
| TM-005: Last tab close | Close the only normal tab | New empty tab auto-created | P0 |
| TM-006: Mode switch | Toggle between normal and incognito in tab grid | Shows correct tab set for each mode | P0 |

## 5. Incognito Mode

| Test Case | Steps | Expected Result | Priority |
|---|---|---|---|
| IC-001: Enter incognito | Tap "Enter Incognito Mode" from menu | Black theme UI, incognito indicator visible | P0 |
| IC-002: No history persistence | Browse in incognito, exit, check history | No incognito browsing history visible | P0 |
| IC-003: No cookie persistence | Login to site in incognito, exit and re-enter | Not logged in anymore | P0 |
| IC-004: Close all incognito | Tap "Close All Incognito Tabs" | All incognito tabs removed, switches to normal mode | P0 |
| IC-005: Visual distinction | Side-by-side normal vs incognito | Clear visual difference (white vs black theme) | P0 |
| IC-006: Data isolation | Log in to site in normal, open same site in incognito | Not logged in in incognito (separate data store) | P0 |

## 6. Ad Blocking

| Test Case | Steps | Expected Result | Priority |
|---|---|---|---|
| AB-001: Rules compile | Launch app, check AdBlockManager status | compilationStatus == .compiled | P0 |
| AB-002: Ads blocked | Load ad-heavy site (e.g., news site) | Fewer ads visible vs Safari | P0 |
| AB-003: Stats update | Browse several pages | Dashboard stats increment | P0 |
| AB-004: Disable adblock | Turn off ad blocking in Settings | Ads appear on sites | P1 |
| AB-005: Fail-safe | Corrupt a rule list JSON | Other rule lists still active, app doesn't crash | P0 |
| AB-006: Honest labels | Check dashboard | "Exact count" vs "estimated" labels present | P0 |
| AB-007: Reset stats | Reset stats from Settings | All counters return to zero | P1 |

## 7. Search Engine

| Test Case | Steps | Expected Result | Priority |
|---|---|---|---|
| SE-001: Default engine | Fresh install on US device | Google set as default | P0 |
| SE-002: China default | Device region=CN | Baidu set as default | P0 |
| SE-003: Russia default | Device region=RU | Yandex set as default | P0 |
| SE-004: Korea default | Device region=KR | Naver set as default | P0 |
| SE-005: Manual change | Select DuckDuckGo in Settings | Search queries go to DuckDuckGo | P0 |
| SE-006: Persistence | Change engine, kill app, relaunch | Selected engine persists | P0 |
| SE-007: Override permanence | Change engine in China region | Manual selection persists, doesn't auto-revert | P1 |

## 8. Settings

| Test Case | Steps | Expected Result | Priority |
|---|---|---|---|
| ST-001: All sections visible | Open Settings | All required sections displayed | P0 |
| ST-002: Clear browsing data | Confirm clear data | History, cookies, cache cleared | P0 |
| ST-003: Language change | Change language in Settings | UI updates to new language | P0 |
| ST-004: Contact support | Tap Contact Support | Opens email composer to support email | P1 |
| ST-005: Privacy Policy | Tap Privacy Policy | Opens privacy policy URL | P1 |
| ST-006: Terms | Tap Terms & Conditions | Opens terms URL | P1 |
| ST-007: Version display | Check About section | Version and build number shown | P2 |
| ST-008: Customer Center | Tap "Subscription Help" | RevenueCat Customer Center opens | P1 |

## 9. Performance

| Test Case | Steps | Expected Result | Priority |
|---|---|---|---|
| PF-001: Cold launch time | Time from tap to first usable screen | < 2 seconds | P0 |
| PF-002: Page load speed | Load google.com | < 3 seconds on broadband | P0 |
| PF-003: Memory usage | Open 10 tabs | Memory stays under 300MB | P1 |
| PF-004: Scroll smoothness | Scroll long page | 60fps, no jank | P1 |

## 10. Security

| Test Case | Steps | Expected Result | Priority |
|---|---|---|---|
| SC-001: No data leaks | Monitor network traffic | No PII sent to any server | P0 |
| SC-002: Incognito isolation | Check data stores | Incognito uses nonPersistent store | P0 |
| SC-003: API key security | Search codebase | API key in Configuration only, not in logs | P0 |
| SC-004: HTTPS upgrade | Navigate to known HTTPS site via HTTP | Connection upgrades where server supports | P1 |

## Device Coverage

Test on:
- iPhone SE (3rd gen) — smallest screen
- iPhone 15 — standard size
- iPhone 15 Pro Max — largest screen
- iPad (if universal build)
- iOS 17.0 (minimum supported)
- iOS 18.x (latest)
