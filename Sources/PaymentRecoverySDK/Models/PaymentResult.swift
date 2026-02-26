/// The result of a single payment attempt, passed to `DeclineClassifier`.
public struct PaymentResult: Codable, Sendable {
    /// Top-level outcome of the attempt.
    public let status: PaymentStatus
    /// Decline reason code. `nil` when `status == .success`.
    public let declineCode: DeclineType?
    /// 1-based attempt number (1 = first attempt, 2 = first retry, …).
    public let attemptCount: Int

    public init(
        status: PaymentStatus,
        declineCode: DeclineType? = nil,
        attemptCount: Int = 1
    ) {
        self.status = status
        self.declineCode = declineCode
        self.attemptCount = attemptCount
    }
}
