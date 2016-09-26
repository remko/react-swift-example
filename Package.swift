import PackageDescription

let package = Package(
	name: "react-swift-example",
	dependencies: [
		.Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 0),
        .Package(url: "https://github.com/DanToml/Jay.git", majorVersion: 1)
	],
	exclude: [
		"Config",
		"Public",
		"JS",
		"Resources",
		"node_modules",
	]
)

