test:
	make test-ios
	make test-mac

test-ios:
	xcodebuild -project Suas.xcodeproj -scheme SuasIOS -destination 'platform=iOS Simulator,name=iPhone 7,OS=10.3.1' -sdk iphonesimulator10.3 -configuration Debug ONLY_ACTIVE_ARCH=YES GCC_GENERATE_TEST_COVERAGE_FILES=YES GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES test

test-mac:
	xcodebuild -project Suas.xcodeproj -scheme SuasMac -sdk macosx10.12 -configuration Debug ONLY_ACTIVE_ARCH=YES GCC_GENERATE_TEST_COVERAGE_FILES=YES GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES test

clean:
	xcodebuild -project Suas.xcodeproj -scheme SuasIOS clean -destination 'platform=iOS Simulator,name=iPhone 7,OS=10.2' | xcpretty
	xcodebuild -project Suas.xcodeproj -scheme SuasMac clean
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

after_success:
  - bash <(curl -s https://codecov.io/bash) -t de4c0f22-50e8-4168-a938-7ad99c468dce
