// PaymentResult.swift
// YunoPaymentSDK — Input model representing a payment attempt result.

import Foundation

// MARK: - PaymentStatus

/// The top-level outcome of a payment authorization attempt.
public enum PaymentStatus: String, Codable {
    case success
    case softDecline
    case hardDecline
}

// MARK: - PaymentResult

/// Represents the raw result returned by a payment processor
/// after an authorization attempt.
public struct PaymentResult: Codable {

    /// Unique transaction ID from the processor
    public let id: String

    /// The authorization outcome
    public let status: PaymentStatus

    /// Specific decline code (nil on success)
    public let declineCode: DeclineCode?

    /// Issuing bank name (used for 3DS messaging)
    public let bankName: String?

    /// Transaction amount
    public let amount: Double

    /// ISO 4217 currency code (e.g. "USD", "BRL", "CLP")
    public let currency: String

    /// Last 4 digits of the card, for display purposes
    public let cardLast4: String?

    /// Number of times this payment has been retried
    public let retryCount: Int

    public init(
        id: String = UUID().uuidString,
        status: PaymentStatus,
        declineCode: DeclineCode? = nil,
        bankName: String? = nil,
        amount: Double = 100.00,
        currency: String = "USD",
        cardLast4: String? = nil,
        retryCount: Int = 0
    ) {
        self.id = id
        self.status = status
        self.declineCode = declineCode
        self.bankName = bankName
        self.amount = amount
        self.currency = currency
        self.cardLast4 = cardLast4
        self.retryCount = retryCount
    }
}

// MARK: - Convenience Factories (for testing and demos)

public extension PaymentResult {

    static func success(amount: Double = 99.90, currency: String = "BRL") -> PaymentResult {
        PaymentResult(status: .success, amount: amount, currency: currency, cardLast4: "1111")
    }

    static func softDecline(_ code: DeclineCode, bankName: String? = nil) -> PaymentResult {
        PaymentResult(status: .softDecline, declineCode: code, bankName: bankName, cardLast4: "4444")
    }

    static func hardDecline(_ code: DeclineCode) -> PaymentResult {
        PaymentResult(status: .hardDecline, declineCode: code, cardLast4: "5555")
    }
}
