format:
	ios/Pods/SwiftFormat/CommandLineTool/swiftformat ios/CBStore --header "Copyright (c) 2017-{year} Coinbase Inc. See LICENSE"
	gradle ktlintFormat -p android

lint:
	Pods/SwiftLint/swiftlint

init:
	 brew install gradle
