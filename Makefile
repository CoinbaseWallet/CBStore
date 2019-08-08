format:
	ios/Pods/SwiftFormat/CommandLineTool/swiftformat ios/CBStore --header "Copyright (c) 2017-{year} Coinbase Inc. See LICENSE"
	android/gradlew ktlintFormat -p android/store

lint:
	Pods/SwiftLint/swiftlint

init:
	git submodule update --force --recursive
