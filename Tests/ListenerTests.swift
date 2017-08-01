//
//  SuasIOSTests.swift
//  SuasIOSTests
//
//  Created by Omar Abdelhafith on 18/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import XCTest
@testable import Suas

class ListenerTests: XCTestCase {
  
  func testItCanListenToAChange() {
    let store = Suas.createStore(reducer: reducer1)
    
    var changed = false
    
    _ = store.addListener(type: MyState1.self) { val in
      changed = true
    }
    
    store.dispatch(action: IncrementAction())
    XCTAssertTrue(changed)
  }
  
  func testItCanRemoveAListener() {
    let store = Suas.createStore(reducer: reducer1)
    
    var changed = false
    
    let sub = store.addListener(type: MyState1.self) { val in
      changed = true
    }

    sub.removeListener()
    
    store.dispatch(action: IncrementAction())
    XCTAssertFalse(changed)
  }
  
  func testItCanListenToAChangeAndMakesSureThatTypeIsCorrect() {
    let store = Suas.createStore(reducer: reducer1)
    
    var changed = false
    
    _ = store.addListener(type: MyState2.self) { val in
      changed = true
    }
    
    store.dispatch(action: IncrementAction())
    XCTAssertFalse(changed)
  }
  
  func testItCanListenToAChangeAndMakesSureThatTypeIsCorrect2() {
    let store = Suas.createStore(reducer: reducer1,
                                 state: ["x": MyState1(value: 10)])
    
    var changed = false
    
    _ = store.addListener(stateKey: "x", type: MyState2.self) { val in
      changed = true
    }
    
    store.dispatch(action: IncrementAction())
    XCTAssertFalse(changed)
  }
  
  func testItCallsTheFilterToBeNotifiedAboutTheChange() {
    let store = Suas.createStore(reducer: reducer1)
    
    var changed = false
    var filterCalled = true
    
    _ = store.addListener(
      type: MyState1.self,
      if: { old, new in
        filterCalled = true
        return true
    },
      callback: { val in changed = true })
    
    store.dispatch(action: IncrementAction())
    
    XCTAssertTrue(changed)
    XCTAssertTrue(filterCalled)
  }
  
  func testIfTheFilterDoseNotCallNotifyThenCallbackIsNotCalled() {
    let store = Suas.createStore(reducer: reducer1)
    
    var changed = false
    var filterCalled = true
    
    _ = store.addListener(
      type: MyState1.self,
      if: { old, new in
        filterCalled = true
        return false
    },
      callback: { val in changed = true })
    
    store.dispatch(action: IncrementAction())
    
    XCTAssertFalse(changed)
    XCTAssertTrue(filterCalled)
  }
  
  func testListnerCanListenToFullState() {
    let store = Suas.createStore(reducer: Reducer1() + Reducer2())
    
    var changed = false
    var keys: [String] = []
    
    _ = store.addListener { val in
      changed = true
      keys = val.keys
    }
    
    store.dispatch(action: IncrementAction())
    XCTAssertTrue(changed)
    XCTAssertTrue(keys.contains("MyState1"))
    XCTAssertTrue(keys.contains("MyState2"))
  }
  
  func testListnerCanListenToFullStateWithFilter() {
    let store = Suas.createStore(reducer: Reducer1() + Reducer2())
    
    var changed = false
    var keys: [String] = []
    
    _ = store.addListener(if: { _, _ in return true }) { val in
      changed = true
      keys = val.keys
    }
    
    store.dispatch(action: IncrementAction())
    XCTAssertTrue(changed)
    XCTAssertTrue(keys.contains("MyState1"))
    XCTAssertTrue(keys.contains("MyState2"))
  }
  
  func testListnerCanListenToStateForKey() {
    let store = Suas.createStore(reducer: Reducer1() + Reducer2())

    var changed = false
    var val = 0

    _ = store.addListener(stateKey: "MyState1", type: MyState1.self) { (x: MyState1) in
      changed = true
      val = x.value
    }

    store.dispatch(action: IncrementAction())
    XCTAssertTrue(changed)
    XCTAssertEqual(val, 30)
  }

  func testListnerCanListenToStateForKeyWithFilterThatAlwaysReturnsTrue() {
    let store = Suas.createStore(reducer: Reducer1() + Reducer2())

    var changed = false
    var val = 0

    _ = store.addListener(stateKey: "MyState1",
                          type: MyState1.self,
                          if: { _, _ in return true }) { (x: MyState1) in
                            changed = true
                            val = x.value
    }

    store.dispatch(action: IncrementAction())
    XCTAssertTrue(changed)
    XCTAssertEqual(val, 30)
  }

  func testListnerCanListenToStateForKeyWithFilterThatNeverReturnsTrue() {
    let store = Suas.createStore(reducer: Reducer1() + Reducer2())

    var changed = false
    var val = 0

    _ = store.addListener(stateKey: "MyState1",
                          type: MyState1.self,
                          if: { _, _ in return false }) { (x: MyState1) in
                            changed = true
                            val = x.value
    }

    store.dispatch(action: IncrementAction())
    XCTAssertFalse(changed)
    XCTAssertEqual(val, 0)
  }

  func testListnerCanListenToStateForKeyWithFilterWithATypeThatMatches() {
    let store = Suas.createStore(reducer: Reducer1() + Reducer2())

    var changed = false
    var val = 0

    _ = store.addListener(stateKey: "MyState1",
                          type: MyState1.self,
                          if: { _, _ in return true }) { (x: MyState1) in
                            changed = true
                            val = x.value
    }

    store.dispatch(action: IncrementAction())
    XCTAssertTrue(changed)
    XCTAssertEqual(val, 30)
  }

  
  func testListnerCanListenToStateForKeyAndTypeThatMatches() {
    let store = Suas.createStore(reducer: Reducer1() + Reducer2())
    
    var changed = false
    var val = 0
    
    _ = store.addListener(stateKey: "MyState1", type: MyState1.self) { x in
      changed = true
      val = x.value
    }
    
    store.dispatch(action: IncrementAction())
    XCTAssertTrue(changed)
    XCTAssertEqual(val, 30)
  }
  
  func testListnerCanListenToStateForKeyAndTypeThatDoesNotMatch() {
    let store = Suas.createStore(reducer: Reducer1() + Reducer2())
    
    var changed = false
    var val = 0
    
    _ = store.addListener(stateKey: "MyState1", type: MyState2.self) { x in
      changed = true
      val = x.blink
    }
    
    store.dispatch(action: IncrementAction())
    XCTAssertFalse(changed)
    XCTAssertEqual(val, 0)
  }
  
  func testListnerCanListenToStateForKeyAndTypeThatMatchesAndAFilter() {
    let store = Suas.createStore(reducer: Reducer1() + Reducer2())
    
    var changed = false
    var val = 0
    
    _ = store.addListener(stateKey: "MyState1", type: MyState1.self,
                          if: { _, _ in return true }) { x in
                            changed = true
                            val = x.value
    }
    
    store.dispatch(action: IncrementAction())
    XCTAssertTrue(changed)
    XCTAssertEqual(val, 30)
  }
  
  func testListnerCanListenToStateForKeyAndTypeThatMatchesAndAFilterThatNeverReturnsTrue() {
    let store = Suas.createStore(reducer: Reducer1() + Reducer2())
    
    var changed = false
    var val = 0
    
    _ = store.addListener(stateKey: "MyState1", type: MyState1.self,
                          if: { _, _ in return false }) { x in
                            changed = true
                            val = x.value
    }
    
    store.dispatch(action: IncrementAction())
    XCTAssertFalse(changed)
    XCTAssertEqual(val, 0)
  }
  
  func testListnerCanListenToStateForKeyAndTypeThatMatchesAndAFilterThatAlwaysReturnsTrueButStateIsWrong() {
    let store = Suas.createStore(reducer: Reducer1() + Reducer2())
    
    var changed = false
    var val = 0
    
    _ = store.addListener(stateKey: "MyState2", type: MyState1.self,
                          if: { _, _ in return false }) { x in
                            changed = true
                            val = x.value
    }
    
    store.dispatch(action: IncrementAction())
    XCTAssertFalse(changed)
    XCTAssertEqual(val, 0)
  }
  
  func testItAddsActionListener() {
    let store = Suas.createStore(reducer: Reducer1() + Reducer2())
    
    var actionReceived: Action? = nil
    _ = store.addActionListener { action in
      actionReceived = action
    }
    
    store.dispatch(action: IncrementAction())
    XCTAssertTrue(actionReceived is IncrementAction)
  }
  
  func testItRemovesAnActionListener() {
    let store = Suas.createStore(reducer: Reducer1() + Reducer2())
    
    var actionReceived: Action? = nil
    let sub = store.addActionListener { action in
      actionReceived = action
    }

    sub.removeListener()
    
    store.dispatch(action: IncrementAction())
    XCTAssertNil(actionReceived)
  }
  
  func testItDoesNotNotifyIfKeyIsNotChanged() {
    struct Action1: Action {}

    let reducer1 = BlockReducer(initialState: 1, stateKey: "key1") { state, action in
      if action is Action1 {
        return state
      }
      return nil
    }

    let reducer2 = BlockReducer(initialState: 1, stateKey: "key2") { action, state in
      return nil
    }

    let store = Suas.createStore(reducer: reducer1 + reducer2)

    var listener1Notified = false
    var listener2Notified = false

    _ = store.addListener(stateKey: "key1", type: Int.self) { (s: Int) in
      listener1Notified = true
    }

    _ = store.addListener(stateKey: "key2", type: Int.self) { (s: Int) in
      listener2Notified = true
    }

    store.dispatch(action: Action1())
    XCTAssertTrue(listener1Notified)
    XCTAssertFalse(listener2Notified)
  }

  func testItDoesNotNotifyIfKeyIsNoneChanged() {
    struct Action1: Action {}

    let reducer1 = BlockReducer(initialState: 1, stateKey: "key1") { action, state in
      return nil
    }

    let reducer2 = BlockReducer(initialState: 1, stateKey: "key2") { action, state in
      return nil
    }

    let store = Suas.createStore(reducer: reducer1 + reducer2)

    var listener1Notified = false
    var listener2Notified = false

    _ = store.addListener(stateKey: "key1", type: Int.self) { (s: Int) in
      listener1Notified = true
    }

    _ = store.addListener(stateKey: "key2", type: Int.self) { (s: Int) in
      listener2Notified = true
    }

    store.dispatch(action: Action1())
    XCTAssertFalse(listener1Notified)
    XCTAssertFalse(listener2Notified)
  }

  func testListenersWithnoKeyAlwaysGetNotified() {
    struct Action1: Action {}

    let reducer1 = BlockReducer(initialState: 1, stateKey: "key1") { action, state in
      return nil
    }

    let reducer2 = BlockReducer(initialState: 1, stateKey: "key2") { action, state in
      return nil
    }

    let store = Suas.createStore(reducer: reducer1 + reducer2)

    var listener1Notified = false
    var listener2Notified = false
    var listener3Notified = false

    _ = store.addListener(stateKey: "key1", type: Int.self) { (s: Int) in
      listener1Notified = true
    }

    _ = store.addListener(stateKey: "key2", type: Int.self) { (s: Int) in
      listener2Notified = true
    }

    _ = store.addListener { (_) in
      listener3Notified = true
    }

    store.dispatch(action: Action1())
    XCTAssertFalse(listener1Notified)
    XCTAssertFalse(listener2Notified)
    XCTAssertTrue(listener3Notified)
  }

  func testItCanAddAListenerWithAStateConverter() {
    let store = Suas.createStore(reducer: reducer1)

    var changed = false
    var newState = 0


    _ = store.addListener(
      stateConverter: { _ in return 10 },
      callback: { state in
        changed = true
        newState = state
    })


    store.dispatch(action: IncrementAction())
    XCTAssertTrue(changed)
    XCTAssertEqual(newState, 10)
  }

  func testItCanAddAListenerWithAStateConverterAndFilterThatNeverReturns() {
    let store = Suas.createStore(reducer: reducer1)

    var changed = false
    var newState = 0


    _ = store.addListener(
      if: { old, new in return false },
      stateConverter: { _ in return 10 },
      callback: { state in
        changed = true
        newState = state
    })


    store.dispatch(action: IncrementAction())
    XCTAssertFalse(changed)
    XCTAssertEqual(newState, 0)
  }

  func testItCanAddAListenerWithAStateConverterAndFilterThatAlwaysReturns() {
    let store = Suas.createStore(reducer: reducer1)

    var changed = false
    var newState = 0


    _ = store.addListener(
      if: { old, new in return true },
      stateConverter: { _ in return 10 },
      callback: { state in
        changed = true
        newState = state
    })


    store.dispatch(action: IncrementAction())
    XCTAssertTrue(changed)
    XCTAssertEqual(newState, 10)
  }

  func testItCanNotifyAboutTheCurrentStateEvenWithoutAction() {
    let store = Suas.createStore(reducer: reducer1)

    var changed = false
    var newState: MyState1?

    let sub = store.addListener(type: MyState1.self) { state in
      changed = true
      newState = state
    }

    sub.informWithCurrentState()

    XCTAssertTrue(changed)
    XCTAssertEqual(newState!.value, 0)

    store.reset(state: MyState1(value: 20))
    sub.informWithCurrentState()

    XCTAssertTrue(changed)
    XCTAssertEqual(newState!.value, 20)
  }

  func testItDoesNotNotifyAboutTheCurrentStateWhenStateKeyIsNotThere() {
    let store = Suas.createStore(reducer: reducer1)

    var changed = false
    var newState = ""

    let sub = store.addListener(type: String.self) { state in
      changed = true
      newState = state
    }

    sub.informWithCurrentState()

    XCTAssertFalse(changed)
    XCTAssertEqual(newState, "")
  }

  func testWhenItTriggerNotificationItPassesThroughStateConverter() {
    let store = Suas.createStore(reducer: reducer1)

    var changed = false
    var newState = 0

    let sub = store.addListener(
      stateConverter: { state in return 50 }
    ) { state in
      changed = true
      newState = state
    }

    store.reset(state: MyState1(value: 20))
    sub.informWithCurrentState()

    XCTAssertTrue(changed)
    XCTAssertEqual(newState, 50)

    store.reset(state: MyState1(value: 20))
    sub.informWithCurrentState()

    XCTAssertTrue(changed)
    XCTAssertEqual(newState, 50)
  }

  func testAddingListenersLinkedToObjects() {
    let store = Suas.createStore(reducer: Reducer1() + Reducer2())

    callAndForget(store: store)
    store.dispatch(action: IncrementAction())
    XCTAssertEqual(Suas.allListeners(inStore: store).count, 0)
  }

  func callAndForget(store: Store) {
    let obj = NSObject()
    let sub = store.addListener(stateKey: "MyState1", type: Int.self) { _ in }
    sub.linkLifeCycleTo(object: obj)
    XCTAssertEqual(Suas.allListeners(inStore: store).count, 1)
  }

  func testAddingMultipleListenersLinkedToObjects() {
    let store = Suas.createStore(reducer: Reducer1() + Reducer2())

    callAndForgetMulti(store: store)
    store.dispatch(action: IncrementAction())
    XCTAssertEqual(Suas.allListeners(inStore: store).count, 0)
  }

  func callAndForgetMulti(store: Store) {
    let obj = NSObject()

    let sub1 = store.addListener(stateKey: "MyState1", type: Int.self) { _ in }
    sub1.linkLifeCycleTo(object: obj)

    let sub2 = store.addListener(stateKey: "MyState1", type: Int.self) { _ in }
    sub2.linkLifeCycleTo(object: obj)

    XCTAssertEqual(Suas.allListeners(inStore: store).count, 2)
  }


  func testItDisconnectsAnActionListenersOnDeinit() {
    let store = Suas.createStore(reducer: Reducer1(), state: MyState1(value: 5))
    callAndForget2(store: store)
    XCTAssertEqual(Suas.allActionListeners(inStore: store).count, 0)
  }

  func callAndForget2(store: Store) {
    let obj = NSObject()
    let sub = store.addActionListener { _ in }
    sub.linkLifeCycleTo(object: obj)
    XCTAssertEqual(Suas.allActionListeners(inStore: store).count, 1)
  }
}
