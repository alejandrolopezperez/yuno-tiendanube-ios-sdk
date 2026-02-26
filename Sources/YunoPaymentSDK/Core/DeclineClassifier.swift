// DeclineClassifier.swift
// YunoPaymentSDK — Core classification engine.
// Classifies payment results and routes to the correct recovery action.

import Foundation

/// The main classification engine of the SDK.
/// Given a PaymentResult, it deterministically returns the recommended PaymentAction.
public final class DeclineClassifier {

    public init() {}

    // MARK: - Public API

    /// Classify a payment result and return the recommended recovery action.
    /// - Parameter result: The raw payment result from the processor.
    /// - Returns: A `PaymentAction` describing what the SDK should do next.
    public func classify(_ result: PaymentResult) -> PaymentAction {
        switch result.status {
        case .success:
            return .success

        case .softDecline:
            guard let code = result.declineCode else {
                return .retry(reason: LocalizedStrings.current.retryingBackup)
            }
            return routeSoftDecline(code: code, bankName: result.bankName)

        case .hardDecline:
            guard let code = result.declineCode else {
                return .failure(message: LocalizedStrings.current.generic, code: nil)
            }
            return routeHardDecline(code: code)
        }
    }

    // MARK: - Private Routing

    private func routeSoftDecline(code: DeclineCode, bankName: String?) -> PaymentAction {
        switch code {
        case .suspectedFraud, .authenticationRequired:
            // Step up to 3DS — stronger auth can resolve these
            return .triggerThreeDS(bankName: bankName ?? "Your bank")

        case .doNotHonor:
            // Ambiguous: try 3DS first, it often resolves generic bank refusals
            return .triggerThreeDS(bankName: bankName ?? "Your bank")

        case .processorTimeout, .networkError, .tryAgain:
            // Purely transient — retry automatically
            return .retry(reason: LocalizedStrings.current.retryingBackup)

        case .issuerUnavailable:
            // Issuer is temporarily down — retry
            return .retry(reason: LocalizedStrings.current.issuerUnavailable)

        default:
            return .retry(reason: LocalizedStrings.current.retryingBackup)
        }
    }

    private func routeHardDecline(code: DeclineCode) -> PaymentAction {
        let strings = LocalizedStrings.current
        let message: String

        switch code {
        case .insufficientFunds:
            message = strings.insufficientFunds
        case .cardExpired:
            message = strings.cardExpired
        case .invalidCVV:
            message = strings.invalidCVV
        case .invalidCardNumber:
            message = strings.invalidCardNumber
        case .cardLostOrStolen:
            message = strings.cardLostOrStolen
        case .cardBlocked:
            message = strings.cardBlocked
        case .doNotRetry:
            message = strings.doNotRetry
        default:
            message = strings.generic
        }

        return .failure(message: message, code: code)
    }
}
