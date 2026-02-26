import SwiftUI

struct SuccessView: View {
    let onDismiss: () -> Void

    @State private var circleScale: CGFloat = 0.3
    @State private var circleopacity: Double = 0
    @State private var checkProgress: CGFloat = 0

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 100, height: 100)
                    .scaleEffect(circleScale)
                    .opacity(circleopacity)

                CheckmarkShape()
                    .trim(from: 0, to: checkProgress)
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    .frame(width: 44, height: 44)
            }
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    circleScale = 1
                    circleopacity = 1
                }
                withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                    checkProgress = 1
                }
            }

            VStack(spacing: 8) {
                Text(localized("success_title"))
                    .font(.title2.bold())
                Text(localized("success_subtitle"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(localized("success_done"), action: onDismiss)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                .padding(.bottom)
        }
        .padding()
    }
}

// MARK: - Animated checkmark path

private struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: w * 0.1, y: h * 0.5))
        path.addLine(to: CGPoint(x: w * 0.4, y: h * 0.8))
        path.addLine(to: CGPoint(x: w * 0.9, y: h * 0.2))
        return path
    }
}
