# CocoaScript

[![Swift](https://img.shields.io/badge/Swift-6-F05138.svg?logo=swift\&logoColor=white)](https://www.swift.org)
[![Platform](https://img.shields.io/badge/platform-macOS%2015%2B-000000.svg?logo=apple\&logoColor=white)](https://www.apple.com/macos/)
[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-DE5C2C.svg?logo=swift\&logoColor=white)](https://www.swift.org/documentation/package-manager/)

CocoaScript is a native Swift runtime for executing JavaScript with Cocoa and
Objective-C interoperability on macOS.

This repository is a minimal Swift Package Manager distribution of CocoaScript.
It preserves the original public class names and runtime behavior where
practical, while replacing the original Objective-C implementation with Swift.

## Contents

* [Requirements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
* [Modules](#modules)
* [Source layout](#source-layout)
* [Development](#development)
* [Migration](#migration)
* [Acknowledgements](#acknowledgements)

## Requirements

* macOS 15 or later
* Swift 6 or later
* Xcode 16 or later

## Installation

Add CocoaScript as a Swift Package Manager dependency:

```swift
dependencies: [
	.package(url: "https://github.com/ruiaureliano/cocoascript.git", branch: "main")
]
```

Then add `CocoaScript` to the target dependencies in your `Package.swift`:

```swift
targets: [
	.executableTarget(
		name: "MyApp",
		dependencies: ["CocoaScript"]
	)
]
```

## Usage

Import the main module in Swift:

```swift
import CocoaScript
```

The package keeps the original CocoaScript and Mocha API names available to
existing macOS applications while the implementation is progressively
modernized for Swift 6.

## Modules

The package exposes one library product with two modules:

* `CocoaScript` — the main JavaScript and Cocoa runtime.
* `CocoaScriptParseKitSwift` — the Swift ParseKit implementation used by the
  runtime.

Most applications only need to import `CocoaScript`.

## Source layout

```text
Sources/
├── Mocha/
│   ├── BridgeSupport/
│   ├── Collections/
│   ├── Objects/
│   ├── Pointer/
│   ├── Reflection/
│   ├── Runtime/
│   └── Utilities/
├── ParseKit/
│   ├── Core/
│   ├── States/
│   └── Tokens/
└── Runtime/
	├── Fiber/
	├── Preprocessing/
	├── Script/
	└── System/
```

The project contains Swift source files only. There are no `.h` or `.m` files
under `Sources`.

## Development

Build the package from the repository root:

```bash
swift build
```

Run the formatter using the project configuration:

```bash
swift-format format --in-place --recursive \
	--configuration .swift-format Sources
```

## Migration

CocoaScript is being migrated from Objective-C to Swift in functional groups.
The migration keeps the original API names, Objective-C selectors, useful
documentation, and runtime behavior wherever possible.

The current Swift implementation includes:

* ParseKit tokenization, parsing, assemblies, states, and parser combinators.
* Mocha pointer wrappers, collections, utilities, objects, closures, and
  JavaScriptCore integration.
* Objective-C runtime reflection and BridgeSupport models and parsing.
* CocoaScript scripts, fibers, intervals, targets, listeners, and preprocessing.

Each change is validated with `swift build` before the next migration step.

## Acknowledgements

CocoaScript incorporates ideas and original source material from:

* CocoaScript by Colin M. McFarlane and contributors.
* Mocha by Logan Collins and Sunflower Softworks.
* TDParseKit by Todd Ditchendorf.
* jstalk by August Mueller and Flying Meat Inc.

Original copyright and attribution notices are retained in the migrated source
files.

## Connect

[![X](https://img.shields.io/badge/ruiaureliano-000000.svg?logo=x&logoColor=white)](https://x.com/ruiaureliano)
[![Mastodon](https://img.shields.io/badge/%40ruiaureliano-6364FF.svg?logo=mastodon&logoColor=white)](https://mastodon.social/@ruiaureliano)
[![Bluesky](https://img.shields.io/badge/ruiaureliano.com-0285FF.svg?logo=bluesky&logoColor=white)](https://bsky.app/profile/ruiaureliano.com)
[![GitHub](https://img.shields.io/badge/ruiaureliano-181717.svg?logo=github&logoColor=white)](https://github.com/ruiaureliano)
[![Email](https://img.shields.io/badge/ruiaureliano%40gmail.com-EA4335.svg?logo=gmail&logoColor=white)](mailto:ruiaureliano@gmail.com)
