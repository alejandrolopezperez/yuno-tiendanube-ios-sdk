import SwiftUI

struct RetryLoadingView: View {
    let message: String
    let attemptCount: Int
    let total: Int

    @State private var rotation: Double = 0

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.accentColor.opacity(0.2), lineWidth: 5)
                    .frame(width: 72, height: 72)

                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 72, height: 72)
                    .rotationEffect(.degrees(rotation))
                    .onAppear {
                        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                            rotation = 360
                        }
                    }
            }

            VStack(spacing: 8) {
                Text(message)
                    .font(.headline)

                if attemptCount > 1 {
                    Text(String(format: localized("retry_attempt"), attemptCount - 1, total - 1))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .padding()
    }
}

#if DEBUG
struct RetryLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        RetryLoadingView(message: "Processing payment...", attemptCount: 1, total: 2)
            .previewDisplayName("Processing")
        RetryLoadingView(message: "Retrying your payment", attemptCount: 2, total: 2)
            .previewDisplayName("Retrying")
    }
}
#endif
