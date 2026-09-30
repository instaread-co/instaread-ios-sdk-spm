# Instaread iOS SDK

Audio player for article screens. It renders Instaread's real player inside your app, publishes
it to the lock screen, and shows a floating mini player while something plays.

## Install

In Xcode: **File → Add Package Dependencies**, paste this repository's URL, and pick *Up to Next
Major Version*. Or in a `Package.swift`:

```swift
.package(url: "https://github.com/instaread-co/instaread-ios-sdk-spm", from: "1.6.0")
```

Then add `audio` to your app's `UIBackgroundModes`, or playback stops when the screen locks:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

## Use

```swift
import InstareadSDK

// Once, at launch:
InstareadPlayer.configure(publication: "yourslug")

// Wherever the player goes on an article screen:
tableView.tableHeaderView = InstareadPlayerView(articleUrl: article.canonicalURL)
```

Full documentation — configuration options, the three player designs, SwiftUI, and what to do
when your app has an audio player of its own — ships with each release, and Instaread will send
it to you with your publication slug.

## What is in this repository

Only `Package.swift`. The SDK is a compiled XCFramework attached to each release here; Swift
downloads it and verifies its checksum. Requires iOS 13 or newer.

## License

Proprietary. See `LICENSE`.
