// swift-tools-version:5.6

import PackageDescription

let package = Package(
  name: "swift-markdown-ui",
  platforms: [
    .macOS(.v12),
    .iOS(.v15),
    .tvOS(.v15),
    .watchOS(.v8),
  ],
  products: [
    .library(
      name: "MarkdownUI",
      targets: ["MarkdownUI"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/mudkipme/swift-markdown.git", branch: "main"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.10.0")
  ],
  targets: [
    .target(
      name: "MarkdownUI",
      dependencies: [.product(name: "Markdown", package: "swift-markdown")]
    ),
    .testTarget(
      name: "MarkdownUITests",
      dependencies: [
        "MarkdownUI",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ],
      exclude: ["__Snapshots__"]
    ),
  ]
)
