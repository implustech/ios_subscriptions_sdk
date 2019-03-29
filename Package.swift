// swift-tools-version:4.0
/*
 Copyright 2019 Apptilaus
 Licensed under MIT License
 See LICENSE
*/

import PackageDescription

let package = Package(
    name: "Apptilaus",
    products: [
        .library(name: "Apptilaus", targets: ["Apptilaus"]),
    ],
    targets: [
        .target(
            name: "Apptilaus",
            dependencies: []),
        // .testTarget(
        //     name: "ApptilausTests",
        //     dependencies: ["Apptilaus"]),
    ]
)