/// Receives analytics events from the payment recovery flow.
///
/// Adopt this protocol in your app to send events to your analytics platform.
/// All methods have no-op default implementations so you only implement what you need.
///
/// ```swift
/// class MyAnalytics: AnalyticsDelegate {
///     func paymentAttempted(result: PaymentResult, action: RecoveryAction) {
///         Amplitude.track("payment_attempted", properties: ["status": result.status.rawValue])
///     }
/// }
/// ```
public protocol AnalyticsDelegate: AnyObject {
    /// Called after every payment attempt, before any UI transition.
    func paymentAttempted(result: PaymentResult, action: RecoveryAction)

    /// Called when the recovery flow reaches a terminal state (success or error).
    func recoveryFlowCompleted(finalState: PaymentRecoveryViewModel.State, totalAttempts: Int)

    /// Called when the user taps Cancel on the 3DS challenge screen.
    func challengeCancelled(attemptCount: Int)

    /// Called when the user approves the 3DS challenge.
    func challengeCompleted(attemptCount: Int)
}

public extension AnalyticsDelegate {
    func paymentAttempted(result: PaymentResult, action: RecoveryAction) {}
    func recoveryFlowCompleted(finalState: PaymentRecoveryViewModel.State, totalAttempts: Int) {}
    func challengeCancelled(attemptCount: Int) {}
    func challengeCompleted(attemptCount: Int) {}
}
