/// Pure, stateless classifier that maps a `PaymentResult` to a `RecoveryAction`.
///
/// Because `classify(result:)` is a pure function, it requires no mocking in tests
/// and is safe to call from any concurrency context.
public struct DeclineClassifier: Sendable {

    /// Maximum number of automatic retries before escalating or failing.
    public static let retryLimit = 2

    public init() {}

    /// Determines the best recovery action for a given payment result.
    ///
    /// Decision tree:
    /// - `.success`                          → `.showSuccess`
    /// - `.hardDecline`                      → `.showError(localizationKey)`
    /// - `.softDecline(.authenticationRequired)` → `.challenge3DS`
    /// - `.softDecline(.suspectedFraud)` attempt 1 → `.retry`; attempt ≥ 2 → `.challenge3DS`
    /// - `.softDecline(.processorTimeout | .issuerUnavailable)`:
    ///   - attempt < retryLimit → `.retry`
    ///   - attempt ≥ retryLimit → `.showError(localizationKey)`
    public func classify(result: PaymentResult) -> RecoveryAction {
        switch result.status {
        case .success:
            return .showSuccess

        case .hardDecline:
            return hardDeclineAction(for: result.declineCode)

        case .softDecline:
            return softDeclineAction(for: result.declineCode, attemptCount: result.attemptCount)
        }
    }

    // MARK: - Private helpers

    private func hardDeclineAction(for code: DeclineType?) -> RecoveryAction {
        switch code {
        case .insufficientFunds:  return .showError(message: "insufficient_funds")
        case .expiredCard:        return .showError(message: "expired_card")
        case .invalidCVV:         return .showError(message: "invalid_cvv")
        case .cardBlocked:        return .showError(message: "card_blocked")
        default:                  return .showError(message: "generic_decline")
        }
    }

    private func softDeclineAction(for code: DeclineType?, attemptCount: Int) -> RecoveryAction {
        switch code {
        case .authenticationRequired:
            return .challenge3DS

        case .suspectedFraud:
            return attemptCount < 2 ? .retry : .challenge3DS

        case .processorTimeout:
            return attemptCount < Self.retryLimit ? .retry : .showError(message: "processor_unavailable")

        case .issuerUnavailable:
            return attemptCount < Self.retryLimit ? .retry : .showError(message: "issuer_unavailable")

        default:
            return .showError(message: "generic_decline")
        }
    }
}
