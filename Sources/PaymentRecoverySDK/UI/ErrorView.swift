import SwiftUI

struct ErrorView: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.12))
                    .frame(width: 88, height: 88)
                Image(systemName: errorIcon)
                    .font(.system(size: 40))
                    .foregroundColor(.red)
            }

            VStack(spacing: 8) {
                Text(localized("error_title"))
                    .font(.title3.bold())
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()

            Button(localized("error_dismiss"), action: onDismiss)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.secondary.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                .padding(.bottom)
        }
        .padding()
    }

    // Maps localized message back to an appropriate SF Symbol icon
    private var errorIcon: String {
        if message.contains(localized("insufficient_funds")) || message == localized("insufficient_funds") {
            return "banknote"
        } else if message.contains(localized("expired_card")) {
            return "calendar.badge.exclamationmark"
        } else if message.contains(localized("invalid_cvv")) {
            return "lock.slash"
        } else if message.contains(localized("card_blocked")) {
            return "creditcard.slash"
        } else if message.contains(localized("processor_unavailable")) {
            return "wifi.exclamationmark"
        } else if message.contains(localized("issuer_unavailable")) {
            return "building.2.slash"
        } else {
            return "xmark.circle"
        }
    }
}

#if DEBUG
struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(
            message: "Your card has insufficient funds. Please use a different payment method.",
            onDismiss: {}
        )
        .previewDisplayName("Insufficient Funds")

        ErrorView(
            message: "This card has been blocked. Please contact your bank.",
            onDismiss: {}
        )
        .previewDisplayName("Card Blocked")

        ErrorView(
            message: "Payment processor temporarily unavailable. Please try again later.",
            onDismiss: {}
        )
        .previewDisplayName("Processor Unavailable")
    }
}
#endif
