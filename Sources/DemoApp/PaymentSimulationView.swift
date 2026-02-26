import SwiftUI
import PaymentRecoverySDK

struct PaymentSimulationView: View {
    let card: TestCard

    @StateObject private var logger = FlowLogger()

    var body: some View {
        VStack(spacing: 0) {
            // SDK view — the main event
            PaymentRecoveryView(
                card: card,
                analyticsDelegate: logger
            )
            .frame(maxHeight: .infinity)

            // Debug state inspector (demo-only, not part of the SDK)
            Divider()
            StateInspectorView(logger: logger)
        }
        .navigationTitle(card.displayName)
    }
}

// MARK: - State Inspector (demo debug panel)

private struct StateInspectorView: View {
    @ObservedObject var logger: FlowLogger

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("SDK Event Log")
                .font(.caption.bold())
                .foregroundColor(.secondary)

            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(logger.events.reversed(), id: \.self) { event in
                        Text(event)
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.primary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: 90)
        }
        .padding(10)
        .background(Color.secondary.opacity(0.1))
    }
}

// MARK: - Analytics logger (demo-only)

@MainActor
private final class FlowLogger: ObservableObject, AnalyticsDelegate {
    @Published var events: [String] = []

    nonisolated func paymentAttempted(result: PaymentResult, action: RecoveryAction) {
        let entry = "attempt \(result.attemptCount): \(result.status) → \(action)"
        Task { @MainActor in self.events.append(entry) }
    }

    nonisolated func recoveryFlowCompleted(finalState: PaymentRecoveryViewModel.State, totalAttempts: Int) {
        let entry = "flow ended: \(finalState) (\(totalAttempts) attempt(s))"
        Task { @MainActor in self.events.append(entry) }
    }

    nonisolated func challengeCancelled(attemptCount: Int) {
        Task { @MainActor in self.events.append("3DS cancelled at attempt \(attemptCount)") }
    }

    nonisolated func challengeCompleted(attemptCount: Int) {
        Task { @MainActor in self.events.append("3DS approved at attempt \(attemptCount)") }
    }
}

#if DEBUG
struct PaymentSimulationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PaymentSimulationView(card: TestCard.all[0])
        }
        .previewDisplayName("Success Flow")

        NavigationStack {
            PaymentSimulationView(card: TestCard.all[5])
        }
        .previewDisplayName("Hard Decline")

        NavigationStack {
            PaymentSimulationView(card: TestCard.all[4])
        }
        .previewDisplayName("3DS Challenge")
    }
}
#endif
