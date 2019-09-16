checkFormat:
	ios/Pods/SwiftFormat/CommandLineTool/swiftformat ios/CBStore --lint --header "Copyright (c) 2017-{year} Coinbase Inc. See LICENSE"
	android/gradlew ktlint -p android/store

format:
	ios/Pods/SwiftFormat/CommandLineTool/swiftformat ios/CBStore --header "Copyright (c) 2017-{year} Coinbase Inc. See LICENSE"
	android/gradlew ktlintFormat -p android/store

lint:
	Pods/SwiftLint/swiftlint

init:
	git submodule update --force --recursive
	if [ -d ".git/hooks" ]; then \
		dir=".git"; \
	else \
		dir=`cat .git | awk '/gitdir:/ {print $$2}'` && cp pre-push "$$dir/hooks/" && chmod 766 "$$dir/hooks/pre-push"; \
	fi; \
	cp pre-push "$$dir/hooks/" && chmod 766 "$$dir/hooks/pre-push";
