import PackageDescription

let package = Package(
	name: "react-swift-example",
	dependencies: [
		.Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 0),
		.Package(url: "https://github.com/DanToml/Jay.git", majorVersion: 1),
		.Package(url: "https://github.com/remko/swift-duktape.git", majorVersion: 0, minor: 2)
	],
	exclude: [
		"Config",
		"Public",
		"JS",
		"Tests",
		"Resources",
		"node_modules",
	]
)

