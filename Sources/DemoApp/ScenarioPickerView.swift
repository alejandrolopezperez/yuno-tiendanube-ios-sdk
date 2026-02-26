import SwiftUI
import PaymentRecoverySDK

struct ScenarioPickerView: View {

    private let groups: [CardGroup] = [
        CardGroup(title: "✅  Success", cards: TestCard.successCards),
        CardGroup(title: "↻  Retry → Success", cards: TestCard.retryCards),
        CardGroup(title: "🔐  3DS Challenge", cards: TestCard.challengeCards),
        CardGroup(title: "✗  Hard Decline", cards: TestCard.hardDeclineCards),
        CardGroup(title: "⏱  Retry Exhausted", cards: TestCard.exhaustedCards),
    ]

    var body: some View {
        List {
            ForEach(groups) { group in
                Section(group.title) {
                    ForEach(group.cards) { card in
                        NavigationLink(destination: PaymentSimulationView(card: card)) {
                            CardRowView(card: card)
                        }
                    }
                }
            }
        }
        .navigationTitle("Scenarios")
    }
}

// MARK: - Supporting types

private struct CardGroup: Identifiable {
    let id = UUID()
    let title: String
    let cards: [TestCard]
}

private struct CardRowView: View {
    let card: TestCard

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(networkColor.opacity(0.15))
                    .frame(width: 40, height: 28)
                Text(card.network.rawValue.prefix(2).uppercased())
                    .font(.caption.bold())
                    .foregroundColor(networkColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(card.displayName)
                    .font(.subheadline.bold())
                HStack(spacing: 4) {
                    Text(card.network.rawValue)
                    Text("••••")
                    Text(card.last4)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private var networkColor: Color {
        switch card.network {
        case .visa:       return .blue
        case .mastercard: return .orange
        case .amex:       return .green
        }
    }
}
