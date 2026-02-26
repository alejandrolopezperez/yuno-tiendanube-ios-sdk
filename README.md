# PaymentRecoverySDK

> Native Swift iOS SDK for intelligent payment decline handling and recovery flows — Yuno × TiendaNube proof-of-concept.

---

## What it does

When a payment is declined, most checkouts show a generic error and force the user to start over. **PaymentRecoverySDK** classifies every decline code and automatically picks the best recovery path:

| Decline type | Action |
|---|---|
| Processor timeout, issuer unavailable | Automatic retry (up to 2×) |
| Suspected fraud (first attempt) | Retry once, then escalate to 3DS |
| Authentication required | 3DS / SCA challenge immediately |
| Insufficient funds, expired card, invalid CVV, card blocked | Localized hard-error screen |

Recovery flows are surfaced as a polished SwiftUI view that your checkout screen can embed in one line.

---

## Quick start

**Add via Swift Package Manager**

```swift
// Package.swift
.package(url: "https://github.com/alejandrolopezperez/yuno-tiendanube-ios-sdk", from: "1.0.0")
```

**Embed the recovery view**

```swift
import SwiftUI
import PaymentRecoverySDK

struct CheckoutView: View {
    let card = TestCard.all[0] // replace with your card data

    var body: some View {
        PaymentRecoveryView(card: card)
    }
}
```

**Use the classifier standalone** (if you supply your own UI)

```swift
let classifier = DeclineClassifier()
let result = PaymentResult(status: .softDecline, declineCode: .processorTimeout, attemptCount: 1)
let action = classifier.classify(result: result)
// → RecoveryAction.retry
```

**Observe analytics events**

```swift
class MyAnalytics: AnalyticsDelegate {
    func paymentAttempted(result: PaymentResult, action: RecoveryAction) {
        Amplitude.track("payment_attempted", properties: ["decline": result.declineCode?.rawValue ?? "none"])
    }
}

PaymentRecoveryView(card: card, analyticsDelegate: MyAnalytics())
```

---

## Run the demo

No Xcode or iOS simulator required — the demo runs as a native macOS SwiftUI app:

```bash
git clone https://github.com/alejandrolopezperez/yuno-tiendanube-ios-sdk
cd yuno-tiendanube-ios-sdk
swift run DemoApp
```

This opens a window with a **Scenario Picker** listing all 10 test cards across 5 flow categories. Selecting any card walks you through the full recovery flow with a live event log.

**Run tests:**

```bash
swift run RunTests
```

Expected output: 10 tests, 10 passed.

> **Note on XCTest:** Full Xcode (not just Command Line Tools) is required to run `.xctest` bundles.
> `RunTests` is a standalone executable runner with no external dependencies — it works with CLT only.

---

## Architecture

```
PaymentResult
     │
     ▼
DeclineClassifier.classify(result:)   ← pure function, fully unit-testable
     │
     ▼
RecoveryAction (.retry / .challenge3DS / .showError / .showSuccess)
     │
     ▼
PaymentRecoveryViewModel              ← @MainActor ObservableObject, state machine
     │
     ▼
PaymentRecoveryView                   ← SwiftUI, switches on State enum
  ├── RetryLoadingView
  ├── ChallengeView  (mock 3DS)
  ├── ErrorView      (localized, SF Symbol icons)
  └── SuccessView    (animated checkmark)
```

### Key files

| Path | Role |
|---|---|
| `Sources/PaymentRecoverySDK/Engine/DeclineClassifier.swift` | Core business logic |
| `Sources/PaymentRecoverySDK/UI/PaymentRecoveryViewModel.swift` | State machine |
| `Sources/PaymentRecoverySDK/UI/PaymentRecoveryView.swift` | Drop-in SwiftUI view |
| `Sources/PaymentRecoverySDK/Simulation/SimulationService.swift` | Async actor, simulates network |
| `Sources/PaymentRecoverySDK/Simulation/TestCards.swift` | 10 pre-built test cards |
| `Tests/PaymentRecoverySDKTests/DeclineClassifierTests.swift` | 10 unit tests |

---

## Localization

Strings are bundled in EN / ES / PT. The SDK resolves them from its own `Bundle.module` so they never conflict with host-app strings. The system locale is respected automatically.

---

## Trade-offs

**`attemptCount` lives on `PaymentResult`, not inside `DeclineClassifier`.**
The classifier is a pure function — all context comes in, nothing is stored. This makes it trivially testable and safe to call from any concurrency context. The trade-off is that callers must track `attemptCount` themselves (the `ViewModel` does this).

**SPM macOS executable for the demo instead of an `.xcodeproj`.**
Any reviewer can run `swift run DemoApp` without Xcode or an iOS simulator. The SwiftUI code is identical to what ships on iOS — same views, same state machine, same SDK. The only difference is the window chrome.

**`actor SimulationService` for Swift 6 strict concurrency.**
Using `actor` over `@MainActor class` keeps simulation off the main thread, preventing UI jank during the simulated 1.5-second network delay.

**`State` enum as the single source of truth.**
Impossible states (`isRetrying && isSuccess`) are unrepresentable by construction. Adding a new state forces exhaustive handling across all switch statements — the compiler enforces completeness.

---

## Requirements

- iOS 16+ / macOS 13+
- Swift 5.9+
- No external dependencies
