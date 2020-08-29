// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwaggerSwiftML",
    products: [
        .library(
            name: "SwaggerSwiftML",
            targets: ["SwaggerSwiftML"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "3.0.1")
    ],
    targets: [
        .target(
            name: "SwaggerSwiftML",
            dependencies: ["Yams"],
            resources: nil),
        .testTarget(
            name: "SwaggerSwiftMLTests",
            dependencies: ["SwaggerSwiftML"],
            resources: [
                .copy("BasicSwagger.yaml"),
                .copy("Parameter"),
                .copy("Schemas"),
                .copy("Path"),
                .copy("Swagger"),
                .copy("Items"),
            ]),
    ]
)
