# Apple Policy Compliance Mapping

## App Store Review Guidelines Compliance

### Section 2: Performance

| Guideline | Requirement | Our Implementation | Status |
|---|---|---|---|
| 2.1 App Completeness | App must be fully functional at review | All features functional, no placeholders in UI | Compliant |
| 2.3 Accurate Metadata | Screenshots/description match functionality | Screenshots show actual app screens | Compliant |
| 2.5.6 Browsers must use WebKit | iOS browsers must use WKWebView/WebKit | Uses WKWebView exclusively | Compliant |

### Section 3: Business

| Guideline | Requirement | Our Implementation | Status |
|---|---|---|---|
| 3.1.1 In-App Purchase | Digital content must use IAP | RevenueCat/StoreKit 2 for all purchases | Compliant |
| 3.1.2 Subscriptions | Auto-renew subs must follow rules | Yearly plan with proper disclosure text | Compliant |
| 3.1.2(a) Permissible Uses | Subscription content must justify ongoing value | Ongoing ad-block rule updates, new features | Compliant |
| 3.1.2(b) Upgrades/Downgrades | Must handle subscription changes | RevenueCat handles all upgrade/downgrade logic | Compliant |

### Section 3.1.2 Subscription Requirements (Critical)

**Required disclosures (all present in our paywall):**
1. Title of auto-renewing subscription (e.g., "Yearly Plan")
2. Length of subscription (1 year)
3. Price of subscription (localized via StoreKit)
4. Payment timing ("Payment will be charged to your Apple ID account at confirmation of purchase")
5. Auto-renewal terms ("Subscription automatically renews unless canceled at least 24 hours before the end of the current period")
6. How to cancel ("You can manage and cancel your subscriptions by going to your account settings on the App Store after purchase")
7. Links to Privacy Policy and Terms of Use

**Free Trial Requirements:**
- 3-day free trial clearly labeled
- Billing timing after trial clearly stated
- User understands trial converts to paid subscription

### Section 5: Legal / Privacy

| Guideline | Requirement | Our Implementation | Status |
|---|---|---|---|
| 5.1.1 Data Collection | Must describe data collection in Privacy labels | Firebase Analytics with minimal, documented collection | Compliant |
| 5.1.1(i) Data Minimization | Collect only necessary data | Event schema limits collection to product-improvement signals | Compliant |
| 5.1.2 Data Use | Must disclose data use purposes | "Analytics" and "App Functionality" only | Compliant |
| 5.1.1(iv) Health/Finance | Don't collect sensitive categories | No health/finance/sensitive data collected | Compliant |

### App Privacy Label Configuration

**Data Linked to You:**
- None

**Data Not Linked to You:**
- Usage Data: Product Interaction (analytics events)
- Diagnostics: Crash Data, Performance Data

**Data Used for Tracking:**
- None (we do not track users across apps)

**Data Sold to Third Parties:**
- None

### Section 4: Design (HIG Compliance)

| Guideline | Requirement | Our Implementation | Status |
|---|---|---|---|
| 4.0 Design | Follow HIG | Semantic colors, Dynamic Type, VoiceOver | Compliant |
| 4.1 Copycats | Must be distinct from other apps | Unique AegisShield brand, distinct UI | Compliant |
| 4.2 Minimum Functionality | Must provide value beyond website | Ad blocking, incognito, tab mgmt, search routing | Compliant |
| 4.5.4 VPN Apps | Ad blockers must use Content Blocker API | WKContentRuleListStore (WebKit-native) | Compliant |

---

## Sensitive Areas & Mitigations

### 1. Paywall Blocking Access
**Risk:** Apple may reject if paywall prevents basic functionality.
**Mitigation:** "Continue with limited features" button always visible. Users can browse with basic features without paying.

### 2. Ad Blocking Claims
**Risk:** Overstating blocking capabilities.
**Mitigation:**
- "Exact count" label for rule-based blocking counts
- "Estimated" label for bandwidth/time savings with transparent calculation methodology
- No claims of "100% ad blocking" — we block known domains via content rules

### 3. Privacy Claims
**Risk:** Privacy claims must match actual behavior.
**Mitigation:**
- App Privacy labels exactly match Firebase Analytics collection
- Event schema documented and auditable
- No PII collection
- Clear "We never sell your data" messaging backed by actual architecture

### 4. Incognito Mode
**Risk:** Overpromising privacy in incognito mode.
**Mitigation:**
- Uses WKWebsiteDataStore.nonPersistent() (WebKit-standard approach)
- Does not claim "untraceable" or "anonymous" — only "private browsing that doesn't save locally"
- Clear description of what incognito does and does not protect against

### 5. Data Collection in Incognito
**Risk:** Analytics during incognito sessions.
**Mitigation:**
- Only collect feature-usage events (e.g., "incognito session started") — never page content
- No URLs, page titles, or browsing content captured in any mode

---

## Required Legal Documents

1. **Privacy Policy** — Must cover: what data is collected, how it's used, third-party sharing (none), user rights, contact info
2. **Terms of Use** — Must cover: subscription terms, usage restrictions, liability limitations, governing law
3. **Support URL** — developer.nasar416@gmail.com accessible from Settings

Both documents must be hosted at stable URLs and linked from the paywall and Settings.
