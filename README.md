# Instaread iOS SDK

Audio player for article screens in iOS apps, for **UIKit and SwiftUI**.

The SDK provides the Instaread Audio Player inside your iOS app, including background playback, lock-screen controls, and a floating mini player.

It is distributed as a Swift package from this repository.

---

## Requirements

| Requirement      | Version / setting                                                   |
| ---------------- | ------------------------------------------------------------------- |
| iOS              | 13.0+                                                               |
| Xcode            | 26 or newer                                                         |
| Background audio | `UIBackgroundModes` with `audio`                                    |
| Network          | HTTPS access to `player.instaread.co` and `player-api.instaread.co` |
| Dependencies     | None — system frameworks only                                       |

---

# 1. Add the package

In Xcode, choose **File → Add Package Dependencies…** and enter:

```text
https://github.com/instaread-co/instaread-ios-sdk-spm
```

Choose **Up to Next Major Version** from `1.6.1`, then add the **InstareadSDK** library to your app target.

Or, in a `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/instaread-co/instaread-ios-sdk-spm", from: "1.6.1")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [.product(name: "InstareadSDK", package: "instaread-ios-sdk-spm")]
    )
]
```

The package includes the compiled SDK, so no additional download is required.

---

# 2. Enable background audio playback

To allow audio to continue playing when the app is in the background or the device screen is locked, add the following configuration to your `Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

This configuration belongs to your application and must be added manually. Without it, playback will stop when the device screen is locked.

After adding this configuration, rebuild the app.

---

# 3. Configure the SDK once at app start

Initialize the SDK once when your application starts, before anything renders.

**UIKit** — in `application(_:didFinishLaunchingWithOptions:)`:

```swift
import InstareadSDK

InstareadPlayer.configure(publication: "yourslug")
```

**SwiftUI** — in your `App`'s initializer:

```swift
import InstareadSDK

@main
struct MyApp: App {
    init() {
        InstareadPlayer.configure(publication: "yourslug")
    }

    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
```

Replace `yourslug` with your Instaread publication name.

The publication name should be provided in the same format as your partner/publication name. The SDK normalizes it to the publication slug used by Instaread.

---

# 4. Add the player to your article screen

Add the player wherever you want it to appear on your article screen.

We recommend placing it near the top of the article, immediately after the article heading and before the article content.

**UIKit** — `InstareadPlayerView` is a `UIView`:

```swift
import InstareadSDK

let player = InstareadPlayerView(articleUrl: "https://yoursite.com/your-article")
stackView.addArrangedSubview(player)
```

It also works as a `tableHeaderView` or under Auto Layout. Create it in code; it cannot be added from a storyboard or xib.

**SwiftUI**:

```swift
import InstareadSDK

WebInlinePlayerView(publication: "yourslug", articleUrl: "https://yoursite.com/your-article")
```

### Important

`articleUrl` must point to the article's own page URL on your website.

It should be the same article URL used by the Instaread web player.

The player automatically manages its own height:

* It has zero height while there is nothing to display.
* It shows a loading state while the player is loading.
* It then displays the player or the appropriate audio state.
* It does not scroll independently, so it should be placed inside your article's scroll view.

That's the basic integration. There is no client instance to create or pass between screens. All players and the mini player share the SDK's internal player state.

---

# 5. Optional: Configure the player

The basic configuration only requires your publication name:

```swift
InstareadPlayer.configure(publication: "yourslug")
```

You can also provide optional configuration:

```swift
InstareadPlayer.configure(
    publication: "yourslug",
    miniPlayerEnabled: true,
    miniPlayerBottomOffset: 49,
    playerType: .compact,
    dark: true,
    singlePlayerMode: true
)
```

All configuration options are optional, and must be passed in the order shown.

When a configuration value is not provided, the SDK uses the publication's configured setting, followed by the SDK default.

## Configuration options

| Option                   | Default     | Description                                                                                                  |
| ------------------------ | ----------- | ------------------------------------------------------------------------------------------------------------ |
| `miniPlayerEnabled`      | `true`      | Controls whether the floating mini player is displayed.                                                      |
| `miniPlayerBottomOffset` | `50`        | The height of your app's bottom UI, in points, so the mini player can be positioned above it.                |
| `playerType`             | `.acoustic` | The inline player design: `.acoustic`, `.compact`, or `.rectangular`.                                        |
| `dark`                   | `false`     | Enables the dark player theme. A single `InstareadPlayerView(articleUrl:dark:)` can override it.             |
| `singlePlayerMode`       | `false`     | Enables coordination between the Instaread Player and your app's own audio player.                          |

---

# 6. Configure the mini player position

If your app has a tab bar or other UI at the bottom of the screen, use `miniPlayerBottomOffset` to position the mini player above it.

Set the value to the height of your app's own bottom UI, in points:

| What your app shows at the bottom          | Value |
| ------------------------------------------ | ----- |
| Nothing                                    | `0`   |
| A standard `UITabBar`                      | `49`  |
| A tab bar and a 64pt bar of your own       | `113` |

```swift
InstareadPlayer.configure(publication: "yourslug", miniPlayerBottomOffset: 49)
```

The value is measured from above the home indicator, which the SDK already allows for. Do **not** pass `tabBar.frame.height` — it includes the home indicator, and the mini player would sit about 34pt too high.

If there is nothing at the bottom of your app, pass `0` rather than leaving it out.

If your bottom UI appears and disappears, call `configure` again with the new value. The mini player moves to it.

---

# 7. Optional: Integrate with your existing audio player

If your app already has its own audio player and the two players should never play simultaneously, enable `singlePlayerMode`.

```swift
InstareadPlayer.configure(publication: "yourslug", singlePlayerMode: true)
```

Then connect the two players:

```swift
// Instaread Player started playing → pause your app's player
InstareadPlayer.onPlaybackStarted = {
    myPlayer.pause()
}

// Your player started playing → stop the Instaread mini player
myPlayer.onStartedPlaying {
    InstareadPlayer.stop()
}
```

The important part is to connect `onStartedPlaying` to the event where your own audio actually begins playing, rather than only to the Play button. Playback can also start from a full-screen player, track list, lock screen, or another control. Call `InstareadPlayer.stop()` on the main thread.

### How single-player mode works

* When Instaread starts playing, `onPlaybackStarted` is called on the main thread so you can pause or close your own player.
* When your player starts playing, call `InstareadPlayer.stop()` to close the Instaread mini player.
* These callbacks only take effect when `singlePlayerMode` is enabled.
* Stopping one player does not automatically start the other, so there is no callback loop.

---

# 8. Player designs

The SDK supports three inline player designs:

| Acoustic                                                                                                                                                   | Compact                                                                                                                                                  | Rectangular                                                                                                                                                      | Custom                                                                                                                                                 |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| <img src="https://raw.githubusercontent.com/instaread-co/instaread-ios-sdk-spm/main/assets/player-designs/acoustic.png" alt="Acoustic player" width="280"> | <img src="https://raw.githubusercontent.com/instaread-co/instaread-ios-sdk-spm/main/assets/player-designs/compact.png" alt="Compact player" width="280"> | <img src="https://raw.githubusercontent.com/instaread-co/instaread-ios-sdk-spm/main/assets/player-designs/rectangular.png" alt="Rectangular player" width="280"> | <img src="https://raw.githubusercontent.com/instaread-co/instaread-ios-sdk-spm/main/assets/player-designs/Custom.png" alt="Custom design" width="280"> |

> **Note:** For custom designs, please contact us.

Select a design using the `playerType` configuration:

```swift
InstareadPlayer.configure(publication: "yourslug", playerType: .compact)
```

Supported values are:

```text
.acoustic
.compact
.rectangular
```

---

# 9. Privacy

The SDK includes Apple's `PrivacyInfo.xcprivacy` privacy manifest.

The SDK collects:

* An anonymous device identifier — a random UUID stored in the Keychain rather than the advertising ID.
* Playback interactions used for analytics and app functionality.

This information is not linked to user identity and is not used for tracking.

Your application's App Store privacy information remains your responsibility to configure.

---

# What is in this repository

Only `Package.swift`, which points to the compiled SDK attached to each release in this repository. Swift downloads it and verifies its checksum. Each version is a tag here — see **Releases**.

---

# License

Proprietary. See `LICENSE`.
