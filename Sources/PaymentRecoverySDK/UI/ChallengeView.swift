import SwiftUI

struct ChallengeView: View {
    let onApprove: () -> Void
    let onCancel: () -> Void

    @State private var otp: String = ""
    @State private var isApproving: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Bank header
            HStack {
                Image(systemName: "building.columns.fill")
                    .font(.title2)
                Text(localized("challenge_bank"))
                    .font(.headline)
                Spacer()
                Button(localized("challenge_cancel"), action: onCancel)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.secondary.opacity(0.12))

            ScrollView {
                VStack(spacing: 32) {
                    // Bank logo placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.accentColor.opacity(0.12))
                            .frame(width: 80, height: 80)
                        Image(systemName: "building.columns.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.accentColor)
                    }
                    .padding(.top, 24)

                    VStack(spacing: 8) {
                        Text(localized("challenge_title"))
                            .font(.title3.bold())
                            .multilineTextAlignment(.center)
                        Text(localized("challenge_subtitle"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    // Mock OTP field
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localized("challenge_otp_label"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        TextField(localized("challenge_otp_placeholder"), text: $otp)
#if canImport(UIKit)
                            .keyboardType(.numberPad)
                            .textContentType(.oneTimeCode)
#endif
                            .padding(12)
                            .background(Color.primary.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)

                    Text(localized("challenge_disclaimer"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // Approve button
                    Button {
                        isApproving = true
                        onApprove()
                    } label: {
                        Group {
                            if isApproving {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(localized("challenge_approve"))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(isApproving)
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
        }
    }
}
