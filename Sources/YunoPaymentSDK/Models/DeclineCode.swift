// DeclineCode.swift
// YunoPaymentSDK — All known decline codes from payment processors.

import Foundation

/// Represents all possible decline codes returned by payment processors.
/// Grouped semantically: soft (retryable) vs hard (permanent).
public enum DeclineCode: String, Codable, CaseIterable {

    // MARK: - Soft Decline Codes (retryable / resolvable)

    /// Bank temporarily unavailable — retry after delay
    case issuerUnavailable = "issuer_unavailable"
    /// Network or processor timeout — retry
    case processorTimeout = "processor_timeout"
    /// Generic network error — retry
    case networkError = "network_error"
    /// Generic "try again" from processor — retry
    case tryAgain = "try_again"
    /// Suspected fraud — escalate to 3DS
    case suspectedFraud = "suspected_fraud"
    /// Bank requires additional authentication — trigger 3DS
    case authenticationRequired = "authentication_required"
    /// Generic do-not-honor that may resolve with 3DS
    case doNotHonor = "do_not_honor"

    // MARK: - Hard Decline Codes (permanent failures)

    /// Account has insufficient funds
    case insufficientFunds = "insufficient_funds"
    /// Card is past its expiration date
    case cardExpired = "card_expired"
    /// CVV/CVC does not match
    case invalidCVV = "invalid_cvv"
    /// Card number is invalid or does not exist
    case invalidCardNumber = "invalid_card_number"
    /// Card reported lost or stolen by cardholder
    case cardLostOrStolen = "card_lost_or_stolen"
    /// Card blocked by issuer
    case cardBlocked = "card_blocked"
    /// Processor explicitly says do not retry
    case doNotRetry = "do_not_retry"
    /// Card not enrolled in 3DS (hard after 3DS attempt)
    case cardNotEnrolled = "card_not_enrolled"
    /// Transaction not permitted for this card type
    case transactionNotPermitted = "transaction_not_permitted"

    // MARK: - Helpers

    /// True if this code represents a soft (retryable) decline
    public var isSoftDecline: Bool {
        switch self {
        case .issuerUnavailable, .processorTimeout, .networkError,
             .tryAgain, .suspectedFraud, .authenticationRequired, .doNotHonor:
            return true
        default:
            return false
        }
    }

    /// True if 3DS step-up is the recommended recovery path
    public var requires3DS: Bool {
        switch self {
        case .suspectedFraud, .authenticationRequired, .doNotHonor:
            return true
        default:
            return false
        }
    }
}
