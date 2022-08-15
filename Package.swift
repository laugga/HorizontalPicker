// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LAUPickerView",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "LAUPickerView",
            targets: ["LAUPickerView"])
    ],
    targets: [
        .target(
            name: "LAUPickerView",
            path: "sources/LAUPickerView",
            resources: [
                .copy("resources/tick.caf")
            ],
            publicHeadersPath: "public")
    ]
)
