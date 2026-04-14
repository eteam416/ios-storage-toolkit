# StorageToolkit

Lightweight Swift package for iOS/macOS apps to parse, format, and evaluate storage sizes.

[![CI](https://github.com/eteam416/ios-storage-toolkit/actions/workflows/ci.yml/badge.svg)](https://github.com/eteam416/ios-storage-toolkit/actions/workflows/ci.yml)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-F05138?logo=swift&logoColor=white)](https://www.swift.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Why This Repo

If you publish storage-related utility apps, this repository is a simple open-source signal that shows:

- Clean Swift package structure
- Unit-tested core logic
- Reusable utilities with practical value

## Features

- Parse input like `512 MB`, `1.5 GB`, `2 GiB`
- Format bytes in binary (`KiB`, `MiB`) and decimal (`KB`, `MB`) styles
- Estimate reclaimed space after deleting files
- Calculate cleanup efficiency percentage

## Installation

In Xcode:

1. File > Add Package Dependencies
2. Paste your repository URL
3. Select `StorageToolkit`

## Usage

```swift
import StorageToolkit

let size = StorageSize(bytes: 1_536)
print(size.formatted(style: .binary, fractionDigits: 1)) // 1.5 KiB

let parsed = StorageSize.parse("1.5 GB")
print(parsed?.bytes ?? 0) // 1500000000

let reclaimed = StorageSize.reclaimedSpace(fromDeletedItems: [1200, 3400, 5600])
let total = StorageSize(bytes: 20_000)
let efficiency = StorageSize.cleanupEfficiency(reclaimed: reclaimed, total: total)
print(efficiency) // 51.0
```

## Run Tests

```bash
swift test
```

## Roadmap

- Add localized formatting support
- Add convenience APIs for `ByteCountFormatter` interoperability
- Publish usage examples for SwiftUI

## License

MIT
