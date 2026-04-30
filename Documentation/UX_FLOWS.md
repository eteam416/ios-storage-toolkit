# Screen-by-Screen UX Flow

## Flow Overview

```
App Launch
    │
    ▼
┌──────────┐
│  Splash   │ (2s animation)
│  Screen   │
└────┬─────┘
     │
     ▼ (First launch?)
     ┌─── Yes ──────────────────────────────┐
     │                                       │
     ▼                                       ▼ (Returning user)
┌──────────────┐                      ┌──────────┐
│   Language    │                      │  Browser  │
│  Selection   │                      │   Home    │
└──────┬───────┘                      └──────────┘
       │
       ▼
┌──────────────┐
│  Onboarding   │ (5 screens)
│    Flow       │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Paywall     │
│   Screen     │
└──────┬───────┘
       │
       ▼ (Purchase / Skip / Restore)
┌──────────────┐
│   Browser    │
│    Home      │
└──────────────┘
```

## Screen Details

### 1. Splash Screen
- **Duration:** ~2 seconds
- **Elements:**
  - Deep blue (#1A2B5F) full background
  - Shield icon with spring animation (0 → 1 scale)
  - Radial cyan glow pulse behind icon
  - "AegisShield" text fade-up
  - Tagline fade-up
- **Auto-advance:** After animation completes → Language Selection (first launch) or Home (returning)

### 2. Language Selection Screen
- **Layout:** Vertical list with search
- **Elements:**
  - Globe icon header with gradient
  - Title: "Choose Your Language"
  - Subtitle: "You can change this anytime in Settings"
  - Search field (filters languages by name)
  - Scrollable language list with native + English names
  - RTL badge for Arabic
  - Checkmark indicator on selected language
  - Auto-selected based on device locale
  - "Continue" button at bottom
- **Accessibility:** Each row labeled with English name, selected trait on current selection

### 3. Onboarding Flow (5 Screens)
- **Navigation:** Horizontal swipe (TabView) + Next button
- **Skip button:** Top right, always visible
- **Page indicators:** Animated capsules at bottom

**Page 1 — The Problem:**
- Icon: exclamationmark.triangle (warning)
- Title: "The Web Is Broken"
- Copy: Focus on pain points — ads, tracking, slow loads

**Page 2 — The Solution:**
- Icon: shield.checkered (AegisShield)
- Title: "AegisShield Protects You"
- Copy: Three pillars — ad blocking, tracker prevention, incognito

**Page 3 — Core Benefits:**
- Icon: bolt.shield (speed + protection)
- Title: "Faster. Cleaner. Private."
- Copy: Specific claims — 3x faster, no ads, private

**Page 4 — Trust:**
- Icon: lock.shield (security)
- Title: "Privacy You Can Trust"
- Copy: No data selling, transparent stats

**Page 5 — Premium Transition:**
- Icon: crown (premium)
- Title: "Unlock Premium Browsing"
- Copy: Transition to paywall, builds desire
- Button changes to "Get Started"

### 4. Paywall Screen
- **Layout:** Scrollable vertical stack
- **Elements:**
  - Shield icon header
  - "Unlock AegisShield Pro" title
  - Feature list with icons (4 features)
  - **Yearly Plan Card:**
    - "Yearly Plan" title
    - "3-Day Free Trial" green badge
    - Monthly equivalent price (large, prominent)
    - Annual price (smaller, secondary)
    - Selection indicator (checkmark circle)
  - **Lifetime Plan Card:**
    - "Lifetime Access" title
    - One-time price (large)
    - Selection indicator
  - CTA Button: "Start Free Trial" or "Purchase Lifetime Access"
  - "Restore Purchases" link
  - "Continue with limited features" (subtle, meets Apple review requirement)
  - Legal disclosure text (auto-renew terms, billing, cancellation)
  - Privacy Policy + Terms of Use links

### 5. Browser Home Screen
- **Layout:** Scrollable vertical
- **Top:** Smart Bar (search/URL input)
- **Privacy Dashboard:**
  - 2x2 grid of stat cards
  - Ads Blocked (exact count, red)
  - Trackers Blocked (exact count, teal)
  - Bandwidth Saved (estimated, blue)
  - Time Saved (estimated, green)
  - "exact count" / "estimated" labels for transparency
- **Quick Shortcuts:**
  - 4x2 grid of popular site shortcuts
  - Country-aware (different sites for CN, JP, KR, AR, RU, IN, default)
  - Circle icon + name
- **Search Engine Indicator:** Shows current default engine
- **Bottom:** Browser toolbar (back, forward, share, tabs count, menu)

### 6. Browser View (Active Browsing)
- **Top:** Smart Bar with URL/search
  - Security icon (lock/warning)
  - URL display / editing mode
  - Clear button in edit mode
  - Cancel button in edit mode
  - Loading progress bar
- **Center:** WKWebView content area
- **Bottom:** Toolbar
  - ◀ Back
  - ▶ Forward
  - ↗ Share
  - □ Tab count badge (opens tab grid)
  - ⋯ Menu

### 7. Incognito Mode
- **Theme:** All-black premium UI
  - Background: #0A0A0A
  - Surface: #1A1A1A
  - Elevated: #2A2A2A
  - Accent: #00D4FF (cyan)
  - Text: White
- **Indicator:** Cyan capsule badge "Incognito Mode" at top
- **All components** use incognito color variants
- **Tab grid** shows eye.slash icon in tab previews

### 8. Tab Grid
- **Layout:** 2-column grid
- **Segmented picker:** Normal | Incognito tabs
- **Tab cells:**
  - Title + close (X) button
  - URL preview
  - Page preview placeholder (colored rectangle)
  - Active tab highlighted with accent border
- **Bottom:** "New Tab" button
- **Incognito tabs** show eye.slash icon

### 9. Settings Screen
- **Layout:** Grouped List (standard iOS)
- **Sections:**
  1. Subscription: Status, Restore, Manage, Subscription Help
  2. Browsing: Search Engine picker, Ad Blocking toggle
  3. Privacy: Clear Browsing Data, Reset Stats
  4. Preferences: Language picker
  5. Support: Contact Support (email)
  6. Legal: Privacy Policy, Terms & Conditions
  7. About: Version, Build
