// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "GoogleCloudStorage",
    products: [
        .library(name: "GoogleCloudStorage", targets: ["GoogleCloudStorage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor-community/GoogleCloudKit.git", from: "1.0.0-alpha"),
        .package(url: "https://github.com/skelpo/Storage.git", .branch("develop"))
    ],
    targets: [
        .target(name: "GoogleCloudStorage", dependencies: ["Storage", "GoogleCloudKit"]),
        .testTarget(name: "GoogleCloudStorageTests", dependencies: ["GoogleCloudStorage"]),
    ]
)
