/// The action the SDK recommends after classifying a payment result.
public enum RecoveryAction: Equatable, Sendable {
    /// Automatically retry the payment with the same card.
    case retry
    /// Launch a 3DS / Strong Customer Authentication challenge.
    case challenge3DS
    /// Display a localized error message (value is a localization key).
    case showError(message: String)
    /// Display a payment success confirmation.
    case showSuccess
}
