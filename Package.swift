// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "YunoPaymentSDK",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "YunoPaymentSDK", targets: ["YunoPaymentSDK"]),
    ],
    targets: [
        .target(
            name: "YunoPaymentSDK",
            path: "Sources/YunoPaymentSDK"
        ),
        .testTarget(
            name: "YunoPaymentSDKTests",
            dependencies: ["YunoPaymentSDK"],
            path: "Tests/YunoPaymentSDKTests"
        )
    ]
)
