// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HorizontalPicker",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "HorizontalPicker",
            targets: ["HorizontalPicker"])
    ],
    targets: [
        .target(
            name: "HorizontalPicker",
            path: "sources/LAUPickerView",
            resources: [
                .copy("resources/tick.caf")
            ],
            publicHeadersPath: "public")
    ]
)
