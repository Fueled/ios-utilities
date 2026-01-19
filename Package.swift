// swift-tools-version:6.2

import PackageDescription

let package = Package(
	name: "FueledUtils",
	platforms: [
		.macOS(.v13), .iOS(.v16), .tvOS(.v16), .watchOS(.v8)
	],
	products: [
		.library(
			name: "FueledCore",
			targets: ["FueledCore"]
		),
		.library(
			name: "FueledCombine",
			targets: ["FueledCombine"]
		),
		.library(
			name: "FueledSwiftUI",
			targets: ["FueledSwiftUI"]
		),
		.library(
			name: "FueledSwiftConcurrency",
			targets: ["FueledSwiftConcurrency"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.4.5"),
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.1.1"),
        .package(url: "https://github.com/pointfreeco/swift-concurrency-extras", from: "1.3.2"),
	],
	targets: [
		.target(
			name: "FueledCore",
			path: "Sources/FueledUtils/Core",
			linkerSettings: [
                .linkedFramework("Foundation")
            ]
		),
		.target(
			name: "FueledCombine",
			dependencies: [
				"FueledCore"
			],
			path: "Sources/FueledUtils/Combine"
		),
		.target(
			name: "FueledSwiftUI",
			dependencies: ["FueledCombine", "FueledCore"],
			path: "Sources/FueledUtils/SwiftUI",
			linkerSettings: [
                .linkedFramework("SwiftUI", .when(platforms: [.iOS, .tvOS, .macOS])),
            ]
		),
		.target(
			name: "FueledSwiftConcurrency",
            dependencies: [
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras"),
            ],
			path: "Sources/FueledUtils/SwiftConcurrency"
		),
		.testTarget(
			name: "FueledCombineTests",
			dependencies: [
				"FueledCombine",
			],
			path: "Tests/FueledUtils/CombineTests"
		),
        .testTarget(
            name: "FueledSwiftConcurrencyTests",
            dependencies: [
                "FueledSwiftConcurrency"
            ],
            path: "Tests/FueledUtils/SwiftConcurrencyTests"
        ),
	]
)
