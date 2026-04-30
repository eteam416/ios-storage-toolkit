# Launch Checklist & 90-Day Roadmap

## Pre-Launch Checklist

### App Store Connect Setup
- [ ] Create App Store Connect record
- [ ] Configure app name: "AegisShield Browser"
- [ ] Upload 1024x1024 app icon
- [ ] Set up In-App Purchases (yearly, lifetime)
- [ ] Configure subscription group
- [ ] Set pricing for all territories
- [ ] Upload screenshots for all required device sizes
- [ ] Write App Store description (keyword optimized)
- [ ] Set age rating (17+ for unrestricted web access)
- [ ] Configure App Privacy labels (match actual collection)
- [ ] Set up review notes explaining browser functionality

### RevenueCat Setup
- [ ] Create RevenueCat project
- [ ] Add Apple App Store app
- [ ] Configure products (yearly, lifetime)
- [ ] Create "iOS Browser App Pro" entitlement
- [ ] Create default offering with both packages
- [ ] Set up paywall template (optional remote paywall)
- [ ] Configure Customer Center
- [ ] Connect Apple Shared Secret for receipt validation
- [ ] Test sandbox purchases

### Firebase Setup
- [ ] Create Firebase project
- [ ] Download GoogleService-Info.plist
- [ ] Enable Analytics
- [ ] Enable Crashlytics
- [ ] Set data retention to minimum (2 months)
- [ ] Configure data deletion on user request

### Code Quality
- [ ] Remove all debug print statements
- [ ] Verify no hardcoded test data in production paths
- [ ] Run static analysis (SwiftLint)
- [ ] Run all unit tests
- [ ] Test memory leaks with Instruments
- [ ] Profile performance with Instruments
- [ ] Verify all localization keys have values in every language

### Legal
- [ ] Host Privacy Policy at aegisshield.app/privacy
- [ ] Host Terms of Use at aegisshield.app/terms
- [ ] Verify subscription disclosure text matches Apple requirements
- [ ] Ensure GDPR/CCPA compliance for EU/CA users

### Testing
- [ ] Complete QA test matrix (all P0 tests passing)
- [ ] Test on iPhone SE (smallest screen)
- [ ] Test on iPhone 15 Pro Max (largest screen)
- [ ] Test with Dynamic Type (Accessibility sizes)
- [ ] Test with VoiceOver
- [ ] Test in RTL mode (Arabic)
- [ ] Test with poor network conditions
- [ ] Sandbox purchase flow end-to-end
- [ ] Sandbox restore flow

### App Review Preparation
- [ ] Prepare demo account (if login required — N/A for browser)
- [ ] Write review notes explaining:
  - Browser uses WKWebView as required
  - Ad blocking via WKContentRuleListStore (Apple-approved API)
  - Free mode available without purchase
  - No VPN or network extension used
- [ ] Prepare appeal response for common rejection reasons

---

## 90-Day Post-Launch Roadmap

### Week 1-2: Stabilization
- Monitor crash rates via Crashlytics
- Fix critical bugs from user reports
- Monitor App Store review feedback
- Track conversion rates: onboarding → paywall → purchase
- Respond to all 1-2 star reviews

### Week 3-4: Quick Wins (Month 1)
- **Bookmarks System:** Add bookmark saving and management
- **History View:** Browsing history with search/filter
- **Enhanced Tab Previews:** Screenshot-based tab thumbnails
- **Dark Mode System Toggle:** Auto-switch based on system appearance
- **Widget:** Home screen widget showing stats

### Week 5-8: Core Improvements (Month 2)
- **Remote Ad-Block Rule Updates:** Fetch updated rule lists from server
- **Reader Mode:** Distraction-free reading view
- **Find in Page:** Text search within web pages
- **Download Manager:** Basic file download handling
- **Password Autofill Integration:** Connect with iOS Keychain/Password Manager
- **Swipe Gestures:** Edge swipe for back/forward navigation

### Week 9-12: Growth & Retention (Month 3)
- **A/B Test Paywalls:** Test different paywall designs via RevenueCat Experiments
- **Push Notifications:** Weekly privacy report ("Blocked 847 ads this week")
- **Share Extension:** Open URLs from other apps in AegisShield
- **iCloud Sync:** Sync bookmarks and settings across devices
- **Tab Sync:** Cross-device tab sync (premium feature)
- **Custom Themes:** Allow users to customize UI colors (premium)
- **Performance Optimizations:** Reduce memory footprint, improve page load

### Beyond 90 Days
- VPN integration (separate premium tier)
- Extension support (content blocker extensions)
- macOS version (Catalyst or native)
- iPad optimization with sidebar navigation
- AI-powered ad detection (supplement rule-based blocking)

---

## Key Metrics to Track

| Metric | Target | Tool |
|---|---|---|
| Day 1 Retention | >40% | Firebase Analytics |
| Day 7 Retention | >20% | Firebase Analytics |
| Day 30 Retention | >10% | Firebase Analytics |
| Trial → Paid Conversion | >30% | RevenueCat |
| Paywall View → Trial Start | >15% | RevenueCat |
| Crash-Free Rate | >99.5% | Crashlytics |
| Average Page Load Time | <2s | Custom Analytics |
| App Store Rating | >4.5 | App Store Connect |
| Monthly Recurring Revenue | Track growth | RevenueCat |
