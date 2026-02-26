/// The top-level outcome of a payment attempt.
public enum PaymentStatus: String, Codable, Sendable {
    case success
    case softDecline
    case hardDecline
}
