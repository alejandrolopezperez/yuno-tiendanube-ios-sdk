/// The specific reason code for a declined payment.
public enum DeclineType: String, Codable, Sendable {
    // Transient — may succeed on retry
    case processorTimeout
    case issuerUnavailable

    // Fraud-adjacent — retry once, then escalate to 3DS
    case suspectedFraud

    // Strong authentication required — go directly to 3DS
    case authenticationRequired

    // Hard declines — non-recoverable in the current session
    case insufficientFunds
    case expiredCard
    case invalidCVV
    case cardBlocked

    // Catch-all
    case unknown
}
