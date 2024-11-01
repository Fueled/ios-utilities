// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "FueledUtils",
	platforms: [
		.macOS(.v13), .iOS(.v16), .tvOS(.v16), .watchOS(.v8)
	],
	products: [
		.library(
			name: "FueledUtilsCore",
			targets: ["FueledUtilsCore"]
		),
		.library(
			name: "FueledUtilsCombine",
			targets: ["FueledUtilsCombine"]
		),
		.library(
			name: "FueledUtilsSwiftUI",
			targets: ["FueledUtilsSwiftUI"]
		),
	],
	dependencies: [
		.package(url: "https://github.com/Quick/Quick.git", from: "4.0.0"),
		.package(url: "https://github.com/Quick/Nimble.git", from: "9.0.0"),
	],
	targets: [
		.target(
			name: "FueledUtilsCore",
			path: "Sources/FueledUtils/Core",
			linkerSettings: [
                .linkedFramework("Foundation")
            ]
		),
		.target(
			name: "FueledUtilsCombine",
			dependencies: [
				"FueledUtilsCore"
			],
			path: "Sources/FueledUtils/Combine"
		),
		.target(
			name: "FueledUtilsSwiftUI",
			dependencies: ["FueledUtilsCombine", "FueledUtilsCore"],
			path: "Sources/FueledUtils/SwiftUI",
			linkerSettings: [
                .linkedFramework("SwiftUI", .when(platforms: [.iOS, .tvOS, .macOS])),
            ]
		),
		.testTarget(
			name: "FueledUtilsCombineTests",
			dependencies: [
				"FueledUtilsCombine",
				"Quick",
				"Nimble",
			],
			path: "Tests/FueledUtils/CombineTests"
		),
	]
)
