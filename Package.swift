// swift-tools-version: 6.1
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "CompactSchema",
    platforms: [.macOS(.v13), .iOS(.v13)],
    products: [
        .library(
            name: "CompactSchema",
            targets: ["CompactSchema"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        .target(
            name: "CompactSchema",
            dependencies: ["CompactSchemaMacros"]
        ),
        .macro(
            name: "CompactSchemaMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .testTarget(
            name: "CompactSchemaTests",
            dependencies: ["CompactSchema"]
        ),
    ]
)
