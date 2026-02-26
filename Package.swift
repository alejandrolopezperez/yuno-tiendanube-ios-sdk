// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PaymentRecoverySDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "PaymentRecoverySDK",
            targets: ["PaymentRecoverySDK"]
        ),
        .executable(
            name: "DemoApp",
            targets: ["DemoApp"]
        ),
        .executable(
            name: "RunTests",
            targets: ["RunTests"]
        )
    ],
    targets: [
        .target(
            name: "PaymentRecoverySDK",
            path: "Sources/PaymentRecoverySDK",
            resources: [
                .process("Localization")
            ]
        ),
        .executableTarget(
            name: "DemoApp",
            dependencies: ["PaymentRecoverySDK"],
            path: "Sources/DemoApp"
        ),
        .executableTarget(
            name: "RunTests",
            dependencies: ["PaymentRecoverySDK"],
            path: "Sources/RunTests"
        )
    ]
)
