// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "BrowserBridge",

    platforms: [
        .macOS("10.15")
    ],
    
    products: [
        .library(
            name: "BrowserBridge",
            targets: ["BrowserBridge"]),
        .executable(
            name: "BrowserBridgeConsole",
            targets: ["BrowserBridgeConsole"]),
    ],

    dependencies: [
    ],

    targets: [
        .target(
            name: "BrowserBridge",
            dependencies: []),
        .target(
            name: "BrowserBridgeConsole",
            dependencies: ["BrowserBridge"])
    ]
)
