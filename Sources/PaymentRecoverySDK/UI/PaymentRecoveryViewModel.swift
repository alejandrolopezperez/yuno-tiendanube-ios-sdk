import SwiftUI

/// State machine driving the entire payment recovery flow.
///
/// `@MainActor` ensures all `@Published` mutations happen on the main thread.
@MainActor
public final class PaymentRecoveryViewModel: ObservableObject {

    // MARK: - State

    public enum State: Equatable {
        case idle
        case processing
        case retrying(attemptCount: Int)
        case challenging3DS
        case success
        case error(message: String)
    }

    @Published public private(set) var state: State = .idle

    // MARK: - Dependencies

    private let classifier: DeclineClassifier
    private let simulation: SimulationService
    public weak var analyticsDelegate: (any AnalyticsDelegate)?

    // MARK: - Private state

    private var currentCard: TestCard?
    private var currentAttempt: Int = 0

    // MARK: - Init

    public init(
        classifier: DeclineClassifier = DeclineClassifier(),
        simulation: SimulationService = SimulationService()
    ) {
        self.classifier = classifier
        self.simulation = simulation
    }

    // MARK: - Public API

    /// Starts (or restarts) the payment flow for the given card.
    public func startPayment(with card: TestCard) async {
        currentCard = card
        currentAttempt = 1
        await attempt()
    }

    /// Called when the user approves the 3DS / bank challenge.
    public func confirmChallenge() async {
        guard let card = currentCard else { return }
        analyticsDelegate?.challengeCompleted(attemptCount: currentAttempt)
        currentAttempt += 1
        state = .processing
        let result = await simulation.processPayment(card: card, attemptCount: currentAttempt)
        let action = classifier.classify(result: result)
        analyticsDelegate?.paymentAttempted(result: result, action: action)
        apply(action: action)
    }

    /// Called when the user cancels the 3DS challenge.
    public func cancelChallenge() {
        analyticsDelegate?.challengeCancelled(attemptCount: currentAttempt)
        state = .error(message: localized("challenge_cancelled"))
        analyticsDelegate?.recoveryFlowCompleted(finalState: state, totalAttempts: currentAttempt)
    }

    /// Resets the flow back to idle so the user can try again.
    public func reset() {
        currentCard = nil
        currentAttempt = 0
        state = .idle
    }

    // MARK: - Private helpers

    private func attempt() async {
        guard let card = currentCard else { return }
        state = currentAttempt == 1 ? .processing : .retrying(attemptCount: currentAttempt)
        let result = await simulation.processPayment(card: card, attemptCount: currentAttempt)
        let action = classifier.classify(result: result)
        analyticsDelegate?.paymentAttempted(result: result, action: action)
        apply(action: action)
    }

    private func apply(action: RecoveryAction) {
        switch action {
        case .showSuccess:
            state = .success
            analyticsDelegate?.recoveryFlowCompleted(finalState: state, totalAttempts: currentAttempt)

        case .retry:
            currentAttempt += 1
            Task { await attempt() }

        case .challenge3DS:
            state = .challenging3DS

        case .showError(let key):
            state = .error(message: localized(key))
            analyticsDelegate?.recoveryFlowCompleted(finalState: state, totalAttempts: currentAttempt)
        }
    }
}
