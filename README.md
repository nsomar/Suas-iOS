![Screenshot](https://raw.githubusercontent.com/zendesk/Suas-iOS/master/Misc/Logo.png)

[![Build Status](https://travis-ci.com/zendesk/Suas-iOS.svg?token=iTfSE3QQamPUFfPk3VRD&branch=master)](https://travis-ci.com/zendesk/Suas-iOS)
![Platform](https://img.shields.io/badge/platform-ios%20%7C%20mac-green.svg)
![Swift Version](https://img.shields.io/badge/Swift-3.0-orange.svg)
![Swift Version](https://img.shields.io/badge/Swift-3.2-orange.svg)
![Swift Version](https://img.shields.io/badge/Swift-4.0-orange.svg)

Suas is a [Unidirectional Data Flow architecture](doc:why-unidirectional-architectures) implementation for iOS/MacOS/TvOS/WatchOs and Android heavily inspired by [Redux](http://redux.js.org). It provides an easy to use library that helps to create applications that are consistent, deterministic and scalable.

Suas has frameworks for iOS, Android, and MacOS. And it aims to have good developer tooling such as customizable logging and state transition monitoring.

Suas is a pragmatic framework, it is designed to work nicely with Cocoa/CocoaTouch and Android/Java/Kotlin. 

# Why Suas
Suas aims to be used to build highly-dynamic, consistent mobile apps:

- Small code base with very low operational footprint (268 methods).
- Static typing and type information is conserved in the Store, Reducers, and Listeners.
- Cross platform; Suas-iOS works on the iOS, MacOS, TvOS and watchOS. And Suas-Android works on all API levels and provides a Kotlin friendly interface. 
- Fast out of the box and can be customized by developers to be even faster [StateConverter]()
- Focuses on developer experience with tools like [LoggerMiddleware]() and [MonitorMiddleware]() 


# Installation

Suas on the iOS can be installed with [Carthage](https://github.com/Carthage/Carthage) or [CocoaPods](https://cocoapods.org)

### Installing with Carthage

Open your `Cartfile` and append the following:

```
github "zendesk/suas-ios" "master"
```

And then build it with `carthage update --platform ...`

### Installing with CocoaPod

Add `pod 'Suas'` to your `Podfile`.

```
use_frameworks!

source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

pod 'Suas'
```

Then run `pod install`

