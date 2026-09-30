// swift-tools-version: 5.9
import PackageDescription

// The Instaread iOS SDK, as a Swift package.
//
// This repository holds nothing but this file. The SDK itself is a compiled
// XCFramework attached to each GitHub release here, and `binaryTarget` below
// points at one — so the SDK's own source stays in its private repository,
// exactly as the Android SDK ships a compiled .aar to Maven Central.
//
// Releasing a new version means: attach that version's XCFramework zip to a
// release here, update the two lines below to match it, and tag this
// repository with the same version. See RELEASING.md.
let package = Package(
    name: "InstareadSDK",
    platforms: [
        // iOS 13 is the SDK's real floor — it is built on SwiftUI, which does
        // not exist before then.
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "InstareadSDK",
            targets: ["InstareadSDK"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "InstareadSDK",
            url: "https://github.com/instaread-co/instaread-ios-sdk-spm/releases/download/1.6.1/InstareadSDK-1.6.1.xcframework.zip",
            // `swift package compute-checksum` on that exact zip. Swift refuses
            // the download if it does not match, so this is what makes a
            // tampered or truncated file fail loudly instead of silently
            // building against the wrong binary.
            checksum: "0281a2d6b4c327f55b6f6cdd0528f97545705774087e656375ce64c0737ec213"
        )
    ]
)
