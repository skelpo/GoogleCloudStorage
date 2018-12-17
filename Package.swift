// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "GoogleCloudStorage",
    products: [
        .library(name: "GoogleCloudStorage", targets: ["GoogleCloudStorage"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "GoogleCloudStorage", dependencies: []),
        .testTarget(name: "GoogleCloudStorageTests", dependencies: ["GoogleCloudStorage"]),
    ]
)