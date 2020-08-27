// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwaggerKit",
    products: [
        .library(
            name: "SwaggerKit",
            targets: ["SwaggerKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "3.0.1")
    ],
    targets: [
        .target(
            name: "SwaggerKit",
            dependencies: ["Yams"],
            resources: nil),
        .testTarget(
            name: "SwaggerKitTests",
            dependencies: ["SwaggerKit"],
            resources: [
                // Copy Tests/ExampleTests/Resources directories as-is.
                // Use to retain directory structure.
                // Will be at top level in bundle.
                .copy("BasicSwagger.yaml"),
                .copy("Parameter"),
                .copy("Schemas"),
            ]),
    ]
)
