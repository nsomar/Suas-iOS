//
//  SuasIOSTests.swift
//  SuasIOSTests
//
//  Created by Omar Abdelhafith on 18/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import XCTest
@testable import SuasIOS

class ListenerTests: XCTestCase {

  func testItCanListenToAChange() {
    let store = Suas.createStore(reducer: reducer1)

    var changed = false

    store.addListener(withId: "1", type: MyState1.self) { val in
      changed = true
    }

    store.dispatch(action: IncrementAction())
    XCTAssertTrue(changed)
  }

  func testItCanRemoveAListener() {
    let store = Suas.createStore(reducer: reducer1)

    var changed = false

    store.addListener(withId: "1", type: MyState1.self) { val in
      changed = true
    }

    store.removeListener(withId: "1")

    store.dispatch(action: IncrementAction())
    XCTAssertFalse(changed)
  }

  func testItCanListenToAChangeAndMakesSureThatTypeIsCorrect() {
    let store = Suas.createStore(reducer: reducer1)

    var changed = false

    store.addListener(withId: "1", type: MyState2.self) { val in
      changed = true
    }

    store.dispatch(action: IncrementAction())
    XCTAssertFalse(changed)
  }

  func testItCanListenToAChangeAndMakesSureThatTypeIsCorrect2() {
    let store = Suas.createStore(reducer: reducer1,
                                 state: ["x": MyState1(value: 10)])

    var changed = false

    store.addListener(withId: "1", stateKey: "x", type: MyState2.self) { val in
      changed = true
    }

    store.dispatch(action: IncrementAction())
    XCTAssertFalse(changed)
  }

  func testItCallsTheNotifierToBeNotifiedAboutTheChange() {
    let store = Suas.createStore(reducer: reducer1)

    var changed = false
    var notifierCalled = true

    store.addListener(
      withId: "1",
      type: MyState1.self,
      notifier: { new, old, listener in
        listener.notify(new)
        notifierCalled = true
    },
      callback: { val in changed = true })

    store.dispatch(action: IncrementAction())

    XCTAssertTrue(changed)
    XCTAssertTrue(notifierCalled)
  }

  func testIfTheNotifierDoseNotCallNotifyThenCallbackIsNotCalled() {
    let store = Suas.createStore(reducer: reducer1)

    var changed = false
    var notifierCalled = true

    store.addListener(
      withId: "1",
      type: MyState1.self,
      notifier: { new, old, listener in
        notifierCalled = true
    },
      callback: { val in changed = true })

    store.dispatch(action: IncrementAction())

    XCTAssertFalse(changed)
    XCTAssertTrue(notifierCalled)
  }

  func testListnerCanListenToFullState() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())

    var changed = false
    var keys: [String] = []

    store.addListener(withId: "1") { val in
      changed = true
      keys = val.keys
    }

    store.dispatch(action: IncrementAction())
    XCTAssertTrue(changed)
    XCTAssertTrue(keys.contains("MyState1"))
    XCTAssertTrue(keys.contains("MyState2"))
  }

  func testListnerCanListenToFullStateWithNotifier() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())

    var changed = false
    var keys: [String] = []

    let notifier: ListenerNotifier<StoreState> = { new, old, l in l.notify(new) }
    store.addListener(withId: "1", notifier: notifier) { val in
      changed = true
      keys = val.keys
    }

    store.dispatch(action: IncrementAction())
    XCTAssertTrue(changed)
    XCTAssertTrue(keys.contains("MyState1"))
    XCTAssertTrue(keys.contains("MyState2"))
  }

  func testListnerCanListenToStateForKey() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())

    var changed = false
    var val = 0

    store.addListener(withId: "1", stateKey: "MyState1") { (x: MyState1) in
      changed = true
      val = x.value
    }

    store.dispatch(action: IncrementAction())
    XCTAssertTrue(changed)
    XCTAssertEqual(val, 10)
  }

  func testListnerCanListenToStateForKeyWithNotifierThatAlwaysCalls() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())

    var changed = false
    var val = 0

    let notifier: ListenerNotifier<Any> = { new, old, l in l.notify(new) }
    store.addListener(withId: "1", stateKey: "MyState1", notifier: notifier) { (x: MyState1) in
      changed = true
      val = x.value
    }

    store.dispatch(action: IncrementAction())
    XCTAssertTrue(changed)
    XCTAssertEqual(val, 10)
  }

  func testListnerCanListenToStateForKeyWithNotifierThatNeverCalls() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())

    var changed = false
    var val = 0

    let notifier: ListenerNotifier<Any> = { new, old, l in  }
    store.addListener(withId: "1", stateKey: "MyState1", notifier: notifier) { (x: MyState1) in
      changed = true
      val = x.value
    }

    store.dispatch(action: IncrementAction())
    XCTAssertFalse(changed)
    XCTAssertEqual(val, 0)
  }

  func testListnerCanListenToStateForKeyWithNotifierWithATypeThatMatches() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())

    var changed = false
    var val = 0

    let notifier: ListenerNotifier<MyState1> = { new, old, l in l.notify(new) }
    store.addListener(withId: "1", stateKey: "MyState1", notifier: notifier) { (x: MyState1) in
      changed = true
      val = x.value
    }

    store.dispatch(action: IncrementAction())
    XCTAssertTrue(changed)
    XCTAssertEqual(val, 10)
  }


  func testListnerCanListenToStateForKeyAndTypeThatMatches() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())

    var changed = false
    var val = 0

    store.addListener(withId: "1", stateKey: "MyState1", type: MyState1.self) { x in
      changed = true
      val = x.value
    }

    store.dispatch(action: IncrementAction())
    XCTAssertTrue(changed)
    XCTAssertEqual(val, 10)
  }

  func testListnerCanListenToStateForKeyAndTypeThatDoesNotMatch() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())

    var changed = false
    var val = 0

    store.addListener(withId: "1", stateKey: "MyState1", type: MyState2.self) { x in
      changed = true
      val = x.blink
    }

    store.dispatch(action: IncrementAction())
    XCTAssertFalse(changed)
    XCTAssertEqual(val, 0)
  }

  func testListnerCanListenToStateForKeyAndTypeThatMatchesAndANotifier() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())

    var changed = false
    var val = 0

    let notifier: ListenerNotifier<MyState1> = { new, old, l in l.notify(new) }
    store.addListener(withId: "1", stateKey: "MyState1", type: MyState1.self, notifier: notifier) { x in
      changed = true
      val = x.value
    }

    store.dispatch(action: IncrementAction())
    XCTAssertTrue(changed)
    XCTAssertEqual(val, 10)
  }

  func testListnerCanListenToStateForKeyAndTypeThatMatchesAndANotifierThatNeverNotifies() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())

    var changed = false
    var val = 0

    let notifier: ListenerNotifier<MyState1> = { new, old, l in  }
    store.addListener(withId: "1", stateKey: "MyState1", type: MyState1.self, notifier: notifier) { x in
      changed = true
      val = x.value
    }

    store.dispatch(action: IncrementAction())
    XCTAssertFalse(changed)
    XCTAssertEqual(val, 0)
  }

  func testListnerCanListenToStateForKeyAndTypeThatMatchesAndANotifierThatAlwaysNotifiesButStateIsWrong() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())

    var changed = false
    var val = 0

    let notifier: ListenerNotifier<MyState1> = { new, old, l in  }
    store.addListener(withId: "1", stateKey: "MyState2", type: MyState1.self, notifier: notifier) { x in
      changed = true
      val = x.value
    }

    store.dispatch(action: IncrementAction())
    XCTAssertFalse(changed)
    XCTAssertEqual(val, 0)
  }

}
