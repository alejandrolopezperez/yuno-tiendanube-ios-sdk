import SwiftUI

/// The root reusable view for the payment recovery flow.
///
/// Embed this in your checkout screen and pass a `TestCard`.
/// The view manages the entire state machine internally.
///
/// ```swift
/// PaymentRecoveryView(card: TestCard.all[0])
/// ```
public struct PaymentRecoveryView: View {

    @StateObject private var viewModel: PaymentRecoveryViewModel
    private let card: TestCard

    public init(
        card: TestCard,
        classifier: DeclineClassifier = DeclineClassifier(),
        simulation: SimulationService = SimulationService(),
        analyticsDelegate: (any AnalyticsDelegate)? = nil
    ) {
        self.card = card
        let vm = PaymentRecoveryViewModel(classifier: classifier, simulation: simulation)
        vm.analyticsDelegate = analyticsDelegate
        _viewModel = StateObject(wrappedValue: vm)
    }

    public var body: some View {
        ZStack {
            switch viewModel.state {
            case .idle:
                idleView

            case .processing:
                RetryLoadingView(message: localized("processing"), attemptCount: 1, total: DeclineClassifier.retryLimit)

            case .retrying(let attempt):
                RetryLoadingView(message: localized("retry_title"), attemptCount: attempt, total: DeclineClassifier.retryLimit)

            case .challenging3DS:
                ChallengeView(
                    onApprove: { Task { await viewModel.confirmChallenge() } },
                    onCancel: { viewModel.cancelChallenge() }
                )

            case .success:
                SuccessView(onDismiss: { viewModel.reset() })

            case .error(let message):
                ErrorView(
                    message: message,
                    onDismiss: { viewModel.reset() }
                )
            }
        }
        .animation(.easeInOut(duration: 0.35), value: viewModel.state)
    }

    // MARK: - Idle / card summary

    private var idleView: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)

                Text(card.displayName)
                    .font(.title2.bold())

                HStack(spacing: 4) {
                    Text(card.network.rawValue)
                    Text("••••")
                    Text(card.last4)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }

            Spacer()

            Button {
                Task { await viewModel.startPayment(with: card) }
            } label: {
                Label(localized("pay_now"), systemImage: "lock.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding()
    }
}
