// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "KiberXavfliy",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "KiberXavfliy", targets: ["KiberXavfliy"])
    ],
    targets: [
        .target(
            name: "KiberXavfliy",
            dependencies: ["KiberXavfliyCore"],
            path: "KiberXavfliy",
            exclude: ["Info.plist"]
        ),
        .binaryTarget(
            name: "KiberXavfliyCore",
            path: "KiberXavfliy/Libraries/libkiberxavfliy_core.xcframework"
        )
    ]
)
