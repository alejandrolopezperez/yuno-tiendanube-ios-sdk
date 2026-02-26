import SwiftUI
import PaymentRecoverySDK

@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ScenarioPickerView()
                    .navigationTitle("PaymentRecovery Demo")
            }
            .frame(minWidth: 400, minHeight: 600)
        }
    }
}
