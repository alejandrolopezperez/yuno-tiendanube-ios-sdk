import Foundation

/// A test card used by `SimulationService` to produce realistic payment results.
public struct TestCard: Identifiable, Sendable {
    public let id: UUID
    public let displayName: String
    public let last4: String
    public let network: CardNetwork
    public let scenario: CardScenario

    public enum CardNetwork: String, Sendable {
        case visa = "Visa"
        case mastercard = "Mastercard"
        case amex = "Amex"
    }

    public enum CardScenario: Sendable {
        case alwaysSucceeds
        case processorTimeoutThenSuccess      // attempt 1: timeout, attempt 2: success
        case issuerUnavailableThenSuccess     // attempt 1: unavailable, attempt 2: success
        case suspectedFraudThen3DS            // attempt 1: retry, attempt 2: 3DS, then success
        case authenticationRequired           // direct 3DS, then success
        case insufficientFunds
        case expiredCard
        case invalidCVV
        case cardBlocked
        case processorTimeoutExhausted        // times out every attempt → error after retry limit
    }

    public init(
        id: UUID = UUID(),
        displayName: String,
        last4: String,
        network: CardNetwork,
        scenario: CardScenario
    ) {
        self.id = id
        self.displayName = displayName
        self.last4 = last4
        self.network = network
        self.scenario = scenario
    }
}

// MARK: - Pre-built test card catalogue

public extension TestCard {
    static let all: [TestCard] = [
        // ✅ Success
        TestCard(
            displayName: "Instant Approval",
            last4: "4242",
            network: .visa,
            scenario: .alwaysSucceeds
        ),
        // ↻ Retry → Success
        TestCard(
            displayName: "Processor Timeout (Recovers)",
            last4: "4001",
            network: .visa,
            scenario: .processorTimeoutThenSuccess
        ),
        TestCard(
            displayName: "Issuer Unavailable (Recovers)",
            last4: "5302",
            network: .mastercard,
            scenario: .issuerUnavailableThenSuccess
        ),
        // 🔐 3DS Flows
        TestCard(
            displayName: "Suspected Fraud → 3DS",
            last4: "4548",
            network: .visa,
            scenario: .suspectedFraudThen3DS
        ),
        TestCard(
            displayName: "Authentication Required",
            last4: "5200",
            network: .mastercard,
            scenario: .authenticationRequired
        ),
        // ✗ Hard Declines
        TestCard(
            displayName: "Insufficient Funds",
            last4: "4716",
            network: .visa,
            scenario: .insufficientFunds
        ),
        TestCard(
            displayName: "Expired Card",
            last4: "5185",
            network: .mastercard,
            scenario: .expiredCard
        ),
        TestCard(
            displayName: "Invalid CVV",
            last4: "3714",
            network: .amex,
            scenario: .invalidCVV
        ),
        TestCard(
            displayName: "Card Blocked",
            last4: "4024",
            network: .visa,
            scenario: .cardBlocked
        ),
        // ⏱ Retry Exhausted
        TestCard(
            displayName: "Processor Timeout (Fails)",
            last4: "4000",
            network: .visa,
            scenario: .processorTimeoutExhausted
        )
    ]

    // Convenience grouping for the demo UI
    static var successCards: [TestCard]   { all.filter { $0.scenario == .alwaysSucceeds } }
    static var retryCards: [TestCard]     { all.filter { [.processorTimeoutThenSuccess, .issuerUnavailableThenSuccess].contains($0.scenario) } }
    static var challengeCards: [TestCard] { all.filter { [.suspectedFraudThen3DS, .authenticationRequired].contains($0.scenario) } }
    static var hardDeclineCards: [TestCard] {
        all.filter { [.insufficientFunds, .expiredCard, .invalidCVV, .cardBlocked].contains($0.scenario) }
    }
    static var exhaustedCards: [TestCard] { all.filter { $0.scenario == .processorTimeoutExhausted } }
}

// Equatable conformance for scenario filtering
extension TestCard.CardScenario: Equatable {}
