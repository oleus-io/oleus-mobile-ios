# OleusRUM — iOS SDK

Real User Monitoring for iOS & macOS. Captures sessions, views, user actions,
network requests, crashes, and session replay, and ships them to the Oleus platform.

- **Platforms:** iOS 14+, macOS 12+
- **Language:** Swift 5.9+
- **Distribution:** Swift Package Manager · CocoaPods

> This `Sources/` tree is the source of truth inside the platform monorepo. It is
> mirrored to the standalone **`oleus-io/oleus-rum-ios`** repo on each release (see
> [`../scripts/release-sdk.sh`](../scripts/release-sdk.sh)), which is the repo
> consumers actually pull from.

## Installation

### Swift Package Manager (recommended)

**Xcode:** *File → Add Package Dependencies…*, paste the repo URL, and pick the
latest version:

```
https://github.com/oleus-io/oleus-rum-ios.git
```

**`Package.swift`:**

```swift
dependencies: [
    .package(url: "https://github.com/oleus-io/oleus-rum-ios.git", from: "0.8.0"),
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [.product(name: "OleusRUM", package: "oleus-rum-ios")]
    ),
]
```

### CocoaPods

Add to your `Podfile`, then run `pod install`:

```ruby
pod 'OleusRUM', '~> 0.8'
```

> If you distribute via a private spec repo rather than the public trunk, add the
> source at the top of your `Podfile`:
> `source 'https://github.com/oleus-io/oleus-podspecs.git'`

## Quickstart

Initialize once, as early as possible — typically in your `App` init or
`AppDelegate.application(_:didFinishLaunchingWithOptions:)`:

```swift
import OleusRUM

OleusRUM.start(configuration: OleusConfiguration(
    apiKey: "<YOUR_API_KEY>",
    endpoint: URL(string: "https://api.internal.oleus.io")!
))
```

That's it — sessions, view tracking, network requests, and crashes are captured
automatically. To record a custom user action:

```swift
OleusRUM.shared?.trackAction(name: "checkout_tapped", attributes: [
    "cart_value": 42.00,
    "item_count": 3,
])
```

## Configuration

All fields have sensible defaults; only `apiKey` is required.

| Option | Default | Description |
| --- | --- | --- |
| `apiKey` | — | **Required.** Your Oleus ingest key. |
| `endpoint` | `https://api.internal.oleus.io` | Ingest endpoint. |
| `sessionSampleRate` | `1.0` | Fraction of sessions tracked (0.0–1.0). |
| `sessionReplayEnabled` | `true` | Enable session replay capture. |
| `sessionReplaySampleRate` | `0.1` | Fraction of sessions replayed. |
| `networkInstrumentationEnabled` | `true` | Auto-instrument `URLSession` requests. |
| `crashReportingEnabled` | `true` | Capture uncaught exceptions & signals. |
| `batchSize` | `50` | Events per upload batch. |
| `flushIntervalSeconds` | `30` | Max seconds between flushes. |

## License

Copyright © Oleus. All rights reserved. See [LICENSE](LICENSE).
