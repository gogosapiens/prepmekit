// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "PrepMeKit",
    platforms: [
        .iOS("15.0"),
    ],
    products: [
        .library(
            name: "PrepMeKit",
            targets: ["PrepMeKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/gogosapiens/scepkit", branch: "main")
    ],
    targets: [
        .target(
            name: "PrepMeKit",
            dependencies: [
                .product(name: "SCEPKit", package: "SCEPKit")
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
