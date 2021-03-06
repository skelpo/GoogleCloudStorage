// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "GoogleCloudStorage",
    products: [
        .library(name: "GoogleCloudStorage", targets: ["GoogleCloudStorage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor-community/google-cloud-provider.git", from: "0.1.0"),
        .package(url: "https://github.com/skelpo/Storage.git", from: "0.1.0")
    ],
    targets: [
        .target(name: "GoogleCloudStorage", dependencies: ["Storage", "GoogleCloud"]),
        .testTarget(name: "GoogleCloudStorageTests", dependencies: ["GoogleCloudStorage"]),
    ]
)
