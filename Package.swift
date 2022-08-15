// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LAPickerView",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "LAPickerView",
            targets: ["LAPickerView"])
    ],
    targets: [
        .target(
            name: "LAPickerView",
            path: "sources/LAPickerView",
            resources: [
                .copy("resources/tick.caf")
            ],
            publicHeadersPath: "public")
    ]
)
