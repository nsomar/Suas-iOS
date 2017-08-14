<p align="center">
<a href="http://imgur.com/a0IkBEX"><img src="http://i.imgur.com/a0IkBEX.png" title="source: imgur.com" /></a>
<p>

<p align="center">
<a href="https://travis-ci.com/zendesk/Suas-iOS"><img src="https://travis-ci.com/zendesk/Suas-iOS.svg?token=iTfSE3QQamPUFfPk3VRD&amp;branch=master" alt="Build Status" /></a>
<img src="https://img.shields.io/badge/platform-ios%20%7C%20osx%20%7C%20tvos%20%7C%20watchos-lightgrey.svg?style=flat" alt="Platform support" />
<a href="https://cocoapods.org/pods/Suas"><img src="https://img.shields.io/cocoapods/v/Suas.svg?style=flat" alt="CocoaPods Compatible" /></a>
<a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage Compatible" /></a>
</p>
<p align="center">
<img src="https://img.shields.io/badge/Swift-3.0-orange.svg" alt="Swift Version" />
<img src="https://img.shields.io/badge/Swift-3.2-orange.svg" alt="Swift Version" />
<img src="https://img.shields.io/badge/Swift-4.0-orange.svg" alt="Swift Version" />
<a href="https://raw.githubusercontent.com/zendesk/Suas-iOS/master/LICENSE?token=AIff-oX-dNf-KBOKyXYPRP9yto5D246gks5ZlwP7wA%3D%3D"><img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" alt="License" /></a>
<a href="https://gitter.im/SuasArch/Lobby?utm_source=badge&amp;utm_medium=badge&amp;utm_campaign=pr-badge&amp;utm_content=badge"><img src="https://badges.gitter.im/Join%20Chat.svg" alt="Join the chat at https://gitter.im/SuasArch/Lobby" /></a>
<br />
<br />
</p>

Suas is a [unidirectional data flow architecture](https://suas.readme.io/docs/why-unidirectional-architectures) implementation for iOS/macOS/tvOS/watchOS and Android heavily inspired by [Redux](http://redux.js.org). It provides an easy-to-use library that helps to create applications that are consistent, deterministic, and scalable.

Suas focuses on providing [good developer experience](#developer-experience-and-tooling) and tooling such as [customizable logging](#customizable-logging) and [state changes monitoring](#state-changes-monitoring).

Join our [gitter chat channel](https://gitter.im/SuasArch/Lobby) for any questions. Or check [Suas documentatation website](https://suas.readme.io).

# What's on this page

- [Suas application flow and components](#suas-application-flow-and-components)
- [Why use Suas](#why-use-suas)
- [Getting Started](#getting-started)
- [Installation](#installation)
- [Developer experience and tooling](#developer-experience-and-tooling)
- [Example applications built with Suas](#example-applications-built-with-suas)
- [Where to go next](#where-to-go-next)
- [Contributing](#contributing)
- [Contact us](#contact-us)
- [Suas future](#suas-future)

For more in depth documentation on how to use Suas [check Suas website](https://suas.readme.io), [Suas API Interface](https://zendesk.github.io/Suas-iOS/) or go straight to a [list of applications built with Suas](https://suas.readme.io/docs/list-of-examples).

# Suas application flow and components

Suas architecture is composed of five core elements:

  * [Store](https://suas.readme.io/docs/store): main component that contains a [Reducer](https://suas.readme.io/docs/reducer) (or [set of reducers](https://suas.readme.io/docs/applications-with-multiple-decoupled-states)), the main application [State](https://suas.readme.io/docs/state), and the [Listeners](https://suas.readme.io/docs/listener)  subscribed to it for state changes. [Actions](https://suas.readme.io/docs/action) that cause state changes are dispatched to it.
  * [State](https://suas.readme.io/docs/state): defines the state of a component/screen or group of components/screens.
  * [Action](https://suas.readme.io/docs/action): each action specifies a change we want to effect on the state. 
  * [Reducer](https://suas.readme.io/docs/reducer): contains the logic to alter the state based on a specific action received.
  * [Listener](https://suas.readme.io/docs/listener): callbacks that gets notified when the state changes.

The following animation describes the Suas runtime flow.

<p align="center">
<img src="http://i.imgur.com/E7Cx2tf.gif" title="source: imgur.com" />
</p>

# Why use Suas 
Suas helps you to build highly-dynamic, consistent mobile applications:

- Cross platform; Suas-iOS works on iOS, macOS, tvOS and watchOS. [Suas-Android](https://github.com/zendesk/Suas-Android) works on all API levels and provides a Kotlin-friendly interface. 
- Focuses on [developer experience](#developer-experience-and-tooling) with plugins/tools like [LoggerMiddleware](https://suas.readme.io/docs/logging-in-suas) and [Suas Monitor](https://suas.readme.io/docs/monitor-middleware-monitor-js).
- Small code base with low operational footprint. Really check the source code 🙂.
- Static typing and type information are conserved in the Store, Reducers, and Listeners.
- Fast out of the box, and can be customized by developers to be even faster [with filtering listeners](https://suas.readme.io/docs/filtering-listeners).

# Installation

Suas on the iOS can be installed with [Carthage](https://github.com/Carthage/Carthage) or [CocoaPods](https://cocoapods.org)

## Installing with Carthage

Open your `Cartfile` and append the following:

```
github "zendesk/suas-ios"
```

And then build it with `carthage update --platform ...`

## Installing with CocoaPod

Add `pod 'Suas'` to your `Podfile`.

```
use_frameworks!

source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

pod 'Suas'
```

Then run `pod install`

# Getting started

Let's get started by building a counter application. 

When building applications in Suas, we start by defining the state for our counter. In this example, the counter state is a struct that contains the counter value.

```swift
struct Counter {
  var value: Int
}
```

We then define the actions that affect the state. For the counter, we need increment and decrement actions.

```swift
struct IncrementAction: Action {
  let incrementValue: Int
}

struct DecrementAction: Action {
  let decrementValue: Int
}
```

Now that we have both the `State` and the `Actions`, we need to specify how actions are going to affect the state. This logic is implemented in the reducer. The counter state reducer looks like the following:

```swift
let counterReducer = BlockReducer(state: Counter(value: 0)) { state, action in

  // Handle increment action
  if let action = action as? IncrementAction {
    var newState = state
    newState.value += action.incrementValue
    return newState
  }
  
  // Handle decrement action
  if let action = action as? DecrementAction {
    var newState = state
    newState.value -= action.decrementValue
    return newState
  }

  // Important: If action does not affec the state, return nil
  return nil
}
```

The reducer defines two things:

1. The initial state for the store. i.e. the initial `Counter` value.
2. The reduce function, which receives both the dispatched `Action` and the current `State`. This function decides what `State` to return based on the `Action`. If the reducer did not change the state, it should return `nil`

The `Store` is the main component we interact with in the application. The store contains:

1. The application's state.
2. The reducer, or reducers.
3. (Advanced) The [middlewares](https://suas.readme.io/docs/middleware)

We create a store with the following snippet:

```swift
let store = Suas.createStore(reducer: counterReducer)
```

Now we can dispatch actions to it and add listeners to it. Let's look at our UI.

```swift
class CounterViewController: UIViewController {
  @IBOutlet weak var counterValue: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Finally: Use the store
    
    self.counterValue.text = "\(store.state.value(forKeyOfType: Counter.self)!.value)"
    
    // Add a listener to the store
    // Notice the [weak self] so we dont leak listeners
    let subscription = store.addListener(forStateType: Counter.self)  { [weak self] state in
      self?.counterValue.text = "\(state.value)"
    }

    // When this object is deallocated, the listener will be removed
    // Alternatively, you have to delete it by hand `subscription.removeListener()`
    subscription.linkLifeCycleTo(object: self)
  }

  @IBAction func incrementTapped(_ sender: Any) {
    // Dispatch actions to the store
    store.dispatch(action: IncrementAction(incrementValue: 1))
  }

  @IBAction func decrementTapped(_ sender: Any) {
    // Dispatch actions to the store
    store.dispatch(action: DecrementAction(decrementValue: 1))
  }
}
```

Let's break down the code above:
1. We add a listener to the store by calling `store.addListener(forStateType: Counter.self)` specifying the state type. 
Notice that we **Must** use `[weak self]` reference in the callback block to prevent strong memory cycles.
2. By calling `subscription.linkLifeCycleTo(object: self)` we link the listener lifecycle to the view controller. When the controller is deallocated the listener is removed.
3. Tapping on the increase or decrease button dispatches actions with `store.dispatch(action:)` that change the state.

That's it, check our [documentation website](https://suas.readme.io/docs) for a full reference on Suas components and check the [list of example built using Suas](https://suas.readme.io/docs/list-of-examples).

# Developer experience and tooling

Suas focuses on developer experience and tooling. It provides two plugins in the form of [Middlewares](https://suas.readme.io/docs/middleware) out of the box.

## Customizable logging
While the `LoggerMiddleware` logs all the action received with the state changes.

<p align="center">
<img src="http://i.imgur.com/yFRGNXe.gif" title="source: imgur.com" />
</p>

Read more about [how to use the LoggerMiddleware](https://suas.readme.io/docs/logging-in-suas).

## State transition monitoring

The `MonitorMiddleware` helps to track state transition and action dispatch history.
When using `MonitorMiddleware` the `Action` dispatched and `State` changes are sent to our [Suas Monitor desktop application](https://github.com/zendesk/Suas-Monitor).

<p align="center">
<img src="http://i.imgur.com/QsbDsN7.gif" title="source: imgur.com" />
</p>

Read how to install and start using the `MonitorMiddleware` by heading to [getting started with monitor middleware article](https://suas.readme.io/docs/monitor-middleware-monitor-js).
Under the hood `Suas Monitor` uses the fantastic [Redux DevTools](https://github.com/gaearon/redux-devtools) to provide state and action information.

# Example applications built with Suas

Check Suas website for an updated [list of examples built with Suas](https://suas.readme.io/docs/list-of-examples).

# Where to go next

To get more information about Suas:
- Head to [Suas website](https://suas.readme.io/docs) for more in-depth knowledge about how to use Suas.
- Check the [Suas API refrerence](https://zendesk.github.io/Suas-iOS/).
- Read through how to use Suas by checking [some examples built with Suas](https://suas.readme.io/docs/list-of-examples).
- Join the conversation on [Suas gitter channel](https://gitter.im/SuasArch/Lobby) or get in touch with the [people behind Suas](#contact-us).

# Contributing

We love any sort of contribution. From changing the internals of how Suas works, changing Suas methods and public API, changing readmes and [documentation topics](https://suas.readme.io). 

Feel free to suggest changes on the GitHub repos or directly [in Saus gitter channel](https://gitter.im/SuasArch/Lobby).

For reference check our [contributing](https://suas.readme.io/docs/contributing) guidelines.

# Contact us

Join our [gitter channel](https://gitter.im/SuasArch/Lobby) to talk to other Suas developers.

For any question, suggestion, or just to say hi, you can find the core team on twitter:

- [Omar Abdelhafith](https://twitter.com/ifnottrue) 
- [Sebastian Chlan](https://twitter.com/sebchlan) 
- [Steven Diviney](https://twitter.com/DivoDivenson) 
- [Giacomo Rebonato](https://twitter.com/GiacomoRebonato)
- [Elvis Porebski](https://twitter.com/) 
- [Vitor Nunes](https://twitter.com/@vitornovictor)

# Suas future

To help craft Suas future releases, join us on [gitter channel](https://gitter.im/SuasArch/Lobby).