// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(name: "Jetpack",
                      platforms: [.macOS(.v10_10),
                                  .iOS(.v8),
                                  .tvOS(.v9),
                                  .watchOS(.v2)],
                      products: [.library(name: "Jetpack",
                                          targets: ["Jetpack"])],
                      targets: [.target(name: "Jetpack",
                                        path: "Sources"),
                                .testTarget(
                                    name: "JetpackTests",
                                    dependencies: ["Jetpack"]),],
                      swiftLanguageVersions: [.v5])
