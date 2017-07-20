test:
	make test-ios
	make test-mac

test-ios:
	xcodebuild -project Suas.xcodeproj -scheme SuasIOS test -destination 'platform=iOS Simulator,name=iPhone 7,OS=10.2' | xcpretty

test-mac:
	xcodebuild -project Suas.xcodeproj -scheme SuasMac test | xcpretty