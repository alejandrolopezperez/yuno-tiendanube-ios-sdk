import Foundation

// MARK: - Decline Codes

/// All possible payment decline codes returned by the processor.
public enum DeclineCode: String, Codable, CaseIterable {
    // Hard Declines — permanent, do not retry
    case insufficientFunds      = "insufficient_funds"
    case cardExpired            = "card_expired"
    case invalidCVV             = "invalid_cvv"
    case cardBlocked            = "card_blocked"
    case lostOrStolen           = "lost_or_stolen"
    case doNotHonor             = "do_not_honor"
    case invalidCardNumber      = "invalid_card_number"

    // Soft Declines — retry with backoff
    case processorTimeout       = "processor_timeout"
    case issuerUnavailable      = "issuer_unavailable"
    case networkError           = "network_error"
    case genericDecline         = "generic_decline"

    // Soft Declines — requires 3DS step-up
    case suspectedFraud         = "suspected_fraud"
    case authenticationRequired = "authentication_required"

    // Success
    case approved               = "approved"

    public var declineType: DeclineType {
        switch self {
        case .insufficientFunds, .cardExpired, .invalidCVV, .cardBlocked,
             .lostOrStolen, .doNotHonor, .invalidCardNumber:
            return .hard
        case .processorTimeout, .issuerUnavailable, .networkError, .genericDecline:
            return .soft(.retry)
        case .suspectedFraud, .authenticationRequired:
            return .soft(.threeds)
        case .approved:
            return .success
        }
    }
}

// MARK: - Decline Type

public enum DeclineType: Equatable {
    case hard
    case soft(SoftDeclineStrategy)
    case success
}

public enum SoftDeclineStrategy: Equatable {
    case retry
    case threeds
}

// MARK: - Payment Result

/// Represents a single payment attempt result from the processor.
public struct PaymentResult: Identifiable, Codable {
    public let id: String
    public let amount: Double
    public let currency: String
    public let declineCode: DeclineCode
    public let cardLastFour: String
    public let cardBrand: CardBrand
    public let merchantName: String
    public let bankName: String?
    public let timestamp: Date

    public init(
        id: String = UUID().uuidString,
        amount: Double,
        currency: String = "USD",
        declineCode: DeclineCode,
        cardLastFour: String = "4242",
        cardBrand: CardBrand = .visa,
        merchantName: String = "TiendaNube Store",
        bankName: String? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.amount = amount
        self.currency = currency
        self.declineCode = declineCode
        self.cardLastFour = cardLastFour
        self.cardBrand = cardBrand
        self.merchantName = merchantName
        self.bankName = bankName
        self.timestamp = timestamp
    }
}

// MARK: - Card Brand

public enum CardBrand: String, Codable {
    case visa       = "Visa"
    case mastercard = "Mastercard"
    case amex       = "American Express"
    case unknown    = "Unknown"

    public var icon: String {
        switch self {
        case .visa:       return "v.circle.fill"
        case .mastercard: return "m.circle.fill"
        case .amex:       return "a.circle.fill"
        case .unknown:    return "creditcard.fill"
        }
    }
}

// MARK: - Recommended Action

/// The action the SDK recommends after classifying a payment result.
public enum PaymentAction: Equatable {
    case success
    case retry(attempt: Int, delay: TimeInterval)
    case triggerThreeDS(bankName: String)
    case requestNewPaymentMethod(reason: String)
    case showError(message: String, userMessage: String)

    public static func == (lhs: PaymentAction, rhs: PaymentAction) -> Bool {
        switch (lhs, rhs) {
        case (.success, .success): return true
        case (.retry(let a1, let d1), .retry(let a2, let d2)): return a1 == a2 && d1 == d2
        case (.triggerThreeDS(let b1), .triggerThreeDS(let b2)): return b1 == b2
        case (.requestNewPaymentMethod(let r1), .requestNewPaymentMethod(let r2)): return r1 == r2
        default: return false
        }
    }
}

// MARK: - Payment State (drives UI)

/// The observable UI state of the payment recovery flow.
public enum PaymentState: Equatable {
    case idle
    case processing
    case retrying(attempt: Int, maxAttempts: Int)
    case awaitingThreeDS(bankName: String)
    case success(PaymentResult)
    case hardFailure(message: String, userMessage: String)
    case softFailureExhausted(userMessage: String)

    public static func == (lhs: PaymentState, rhs: PaymentState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.processing, .processing): return true
        case (.retrying(let a1, let m1), .retrying(let a2, let m2)): return a1 == a2 && m1 == m2
        case (.awaitingThreeDS(let b1), .awaitingThreeDS(let b2)): return b1 == b2
        case (.success(let r1), .success(let r2)): return r1.id == r2.id
        case (.hardFailure(let m1, _), .hardFailure(let m2, _)): return m1 == m2
        case (.softFailureExhausted(let m1), .softFailureExhausted(let m2)): return m1 == m2
        default: return false
        }
    }

    public var isTerminal: Bool {
        switch self {
        case .success, .hardFailure, .softFailureExhausted: return true
        default: return false
        }
    }
}

// MARK: - Test Scenario (for sample app)

public struct PaymentScenario: Identifiable {
    public let id = UUID()
    public let title: String
    public let subtitle: String
    public let emoji: String
    public let result: PaymentResult

    public static let all: [PaymentScenario] = [
        .init(title: "Successful Payment", subtitle: "Visa •••• 4242", emoji: "✅",
              result: PaymentResult(amount: 149.99, declineCode: .approved, cardLastFour: "4242", cardBrand: .visa, merchantName: "TiendaNube Store")),
        .init(title: "Insufficient Funds", subtitle: "Hard decline — no retry", emoji: "💸",
              result: PaymentResult(amount: 299.99, declineCode: .insufficientFunds, cardLastFour: "5555", cardBrand: .mastercard, merchantName: "TiendaNube Store")),
        .init(title: "Expired Card", subtitle: "Hard decline — update card", emoji: "📅",
              result: PaymentResult(amount: 89.00, declineCode: .cardExpired, cardLastFour: "1234", cardBrand: .visa, merchantName: "TiendaNube Store")),
        .init(title: "Invalid CVV", subtitle: "Hard decline — check details", emoji: "🔢",
              result: PaymentResult(amount: 55.00, declineCode: .invalidCVV, cardLastFour: "9999", cardBrand: .amex, merchantName: "TiendaNube Store")),
        .init(title: "Lost / Stolen Card", subtitle: "Hard decline — contact bank", emoji: "🚨",
              result: PaymentResult(amount: 199.00, declineCode: .lostOrStolen, cardLastFour: "7777", cardBrand: .mastercard, merchantName: "TiendaNube Store")),
        .init(title: "Do Not Honor", subtitle: "Hard decline — bank refused", emoji: "🚫",
              result: PaymentResult(amount: 75.00, declineCode: .doNotHonor, cardLastFour: "3333", cardBrand: .visa, merchantName: "TiendaNube Store")),
        .init(title: "Processor Timeout", subtitle: "Soft decline — auto retry", emoji: "⏱",
              result: PaymentResult(amount: 120.00, declineCode: .processorTimeout, cardLastFour: "4242", cardBrand: .visa, merchantName: "TiendaNube Store")),
        .init(title: "Issuer Unavailable", subtitle: "Soft decline — auto retry", emoji: "🔄",
              result: PaymentResult(amount: 65.00, declineCode: .issuerUnavailable, cardLastFour: "5555", cardBrand: .mastercard, merchantName: "TiendaNube Store")),
        .init(title: "Network Error", subtitle: "Soft decline — auto retry", emoji: "📡",
              result: PaymentResult(amount: 39.99, declineCode: .networkError, cardLastFour: "4242", cardBrand: .visa, merchantName: "TiendaNube Store")),
        .init(title: "Suspected Fraud → 3DS", subtitle: "Banco de Chile requires verification", emoji: "🔐",
              result: PaymentResult(amount: 450.00, declineCode: .suspectedFraud, cardLastFour: "6666", cardBrand: .visa, merchantName: "TiendaNube Store", bankName: "Banco de Chile")),
        .init(title: "Auth Required → 3DS", subtitle: "Itaú requires verification", emoji: "🏦",
              result: PaymentResult(amount: 225.00, declineCode: .authenticationRequired, cardLastFour: "8888", cardBrand: .mastercard, merchantName: "TiendaNube Store", bankName: "Itaú"))
    ]
}
