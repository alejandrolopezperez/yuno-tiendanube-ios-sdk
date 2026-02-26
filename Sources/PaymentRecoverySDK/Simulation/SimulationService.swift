import Foundation

/// Simulates network payment processing with realistic async delays.
///
/// `actor` isolation ensures Swift 6 strict concurrency compliance.
public actor SimulationService {

    /// Simulated network latency per attempt.
    public var simulatedDelay: UInt64 = 1_500_000_000 // 1.5 seconds

    public init() {}

    /// Processes a payment attempt and returns the simulated result after a delay.
    /// - Parameters:
    ///   - card: The test card driving the scenario.
    ///   - attemptCount: 1-based attempt number.
    public func processPayment(card: TestCard, attemptCount: Int) async -> PaymentResult {
        try? await Task.sleep(nanoseconds: simulatedDelay)
        return result(for: card.scenario, attemptCount: attemptCount)
    }

    // MARK: - Scenario lookup table

    private func result(for scenario: TestCard.CardScenario, attemptCount: Int) -> PaymentResult {
        switch scenario {
        case .alwaysSucceeds:
            return PaymentResult(status: .success, attemptCount: attemptCount)

        case .processorTimeoutThenSuccess:
            if attemptCount == 1 {
                return PaymentResult(status: .softDecline, declineCode: .processorTimeout, attemptCount: attemptCount)
            }
            return PaymentResult(status: .success, attemptCount: attemptCount)

        case .issuerUnavailableThenSuccess:
            if attemptCount == 1 {
                return PaymentResult(status: .softDecline, declineCode: .issuerUnavailable, attemptCount: attemptCount)
            }
            return PaymentResult(status: .success, attemptCount: attemptCount)

        case .suspectedFraudThen3DS:
            // Attempt 1: soft decline → classifier sends to retry
            // Attempt 2: soft decline → classifier escalates to 3DS
            // After 3DS confirmation: success (handled by ViewModel calling processPayment again)
            return PaymentResult(status: .softDecline, declineCode: .suspectedFraud, attemptCount: attemptCount)

        case .authenticationRequired:
            return PaymentResult(status: .softDecline, declineCode: .authenticationRequired, attemptCount: attemptCount)

        case .insufficientFunds:
            return PaymentResult(status: .hardDecline, declineCode: .insufficientFunds, attemptCount: attemptCount)

        case .expiredCard:
            return PaymentResult(status: .hardDecline, declineCode: .expiredCard, attemptCount: attemptCount)

        case .invalidCVV:
            return PaymentResult(status: .hardDecline, declineCode: .invalidCVV, attemptCount: attemptCount)

        case .cardBlocked:
            return PaymentResult(status: .hardDecline, declineCode: .cardBlocked, attemptCount: attemptCount)

        case .processorTimeoutExhausted:
            return PaymentResult(status: .softDecline, declineCode: .processorTimeout, attemptCount: attemptCount)
        }
    }
}
