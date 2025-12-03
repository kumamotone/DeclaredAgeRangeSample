# DeclaredAgeRangeSample

A sample iOS app demonstrating Apple's [Declared Age Range API](https://developer.apple.com/documentation/declaredagerange).

## Requirements

- iOS 26.0+ / macOS 26.0+
- Xcode 26 beta
- Physical device (recommended for testing)

## Features

- Request user's declared age range from Apple ID
- Display age range bounds (lowerBound / upperBound)
- Show declaration method (self-declared, guardian-declared, etc.)
- Handle declined sharing gracefully

## Usage

The app uses SwiftUI's `@Environment(\.requestAgeRange)` to request age ranges:

```swift
let response = try await requestAgeRange(ageGates: 13, 16, 18)
switch response {
case .declinedSharing:
    // User declined to share
case .sharing(let range):
    // Use range.lowerBound, range.upperBound
}
```

## License

MIT

