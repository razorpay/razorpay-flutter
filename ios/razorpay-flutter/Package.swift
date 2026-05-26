// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "RazorpayFlutter",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "razorpay-flutter", targets: ["razorpay_flutter"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/razorpay/razorpay-pod.git", "1.5.3"..<"2.0.0"),
    ],
    targets: [
        .target(
            name: "razorpay_flutter",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "RazorpayCheckout", package: "razorpay-pod"),
            ],
            path: "Classes",
            exclude: [
                "RazorpayFlutterPlugin.h",
                "RazorpayFlutterPlugin.m"
            ],
            swiftSettings: [
                .define("RAZORPAY_SPM")
            ]
        )
    ]
)
