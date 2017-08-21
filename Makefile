test:
	make test-ios
	make test-mac

test-ios:
	xcodebuild -project Suas.xcodeproj -scheme SuasIOS test -destination 'platform=iOS Simulator,name=iPhone 7,OS=10.2' | xcpretty

test-mac:
	xcodebuild -project Suas.xcodeproj -scheme SuasMac test | xcpretty

clean:
	xcodebuild -project Suas.xcodeproj -scheme SuasIOS clean -destination 'platform=iOS Simulator,name=iPhone 7,OS=10.2' | xcpretty
	xcodebuild -project Suas.xcodeproj -scheme SuasMac clean | xcpretty
	rm -rf ./build
doc:
	rm -rf docs

	jazzy \
  --author "Zendesk" \
  --author_url http://zendesk.com \
  --github_url https://github.com/Zendesk/Suas-iOS/tree/master \
  --output docs \
  --xcodebuild-arguments -scheme,"SuasIOS" \
  --github-file-prefix https://github.com/Zendesk/Suas-iOS \
  --theme fullwidth
