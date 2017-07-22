test:
	make test-ios
	make test-mac

test-ios:
	xcodebuild -project Suas.xcodeproj -scheme SuasIOS test -destination 'platform=iOS Simulator,name=iPhone 7,OS=10.2' | xcpretty
	xcodebuild -project Suas.xcodeproj -scheme SuasMonitorMiddlewareIOS test -destination 'platform=iOS Simulator,name=iPhone 7,OS=10.2' | xcpretty

test-mac:
	xcodebuild -project Suas.xcodeproj -scheme SuasMac test | xcpretty
	xcodebuild -project Suas.xcodeproj -scheme SuasMonitorMiddlewareMac test | xcpretty

clean:
	xcodebuild -project Suas.xcodeproj -scheme SuasIOS clean -destination 'platform=iOS Simulator,name=iPhone 7,OS=10.2' | xcpretty
	xcodebuild -project Suas.xcodeproj -scheme SuasMonitorMiddlewareIOS clean -destination 'platform=iOS Simulator,name=iPhone 7,OS=10.2' | xcpretty
	xcodebuild -project Suas.xcodeproj -scheme SuasMac clean | xcpretty
	xcodebuild -project Suas.xcodeproj -scheme SuasMonitorMiddlewareMac clean | xcpretty
	rm -rf ./build