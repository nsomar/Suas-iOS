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
  
  func testItCallsTheFilterToBeNotifiedAboutTheChange() {
    let store = Suas.createStore(reducer: reducer1)
    
    var changed = false
    var filterCalled = true
    
    store.addListener(
      withId: "1",
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
    
    store.addListener(
      withId: "1",
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
  
  func testListnerCanListenToFullStateWithFilter() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())
    
    var changed = false
    var keys: [String] = []
    
    store.addListener(withId: "1", if: { _, _ in return true }) { val in
      changed = true
      keys = val.keys
    }
    
    store.dispatch(action: IncrementAction())
    XCTAssertTrue(changed)
    XCTAssertTrue(keys.contains("MyState1"))
    XCTAssertTrue(keys.contains("MyState2"))
  }
  
  //  func testListnerCanListenToStateForKey() {
  //    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())
  //
  //    var changed = false
  //    var val = 0
  //
  //    store.addListener(withId: "1", stateKey: "MyState1") { (x: MyState1) in
  //      changed = true
  //      val = x.value
  //    }
  //
  //    store.dispatch(action: IncrementAction())
  //    XCTAssertTrue(changed)
  //    XCTAssertEqual(val, 30)
  //  }

  //  func testListnerCanListenToStateForKeyWithFilterThatAlwaysReturnsTrue() {
  //    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())
  //
  //    var changed = false
  //    var val = 0
  //
  //    store.addListener(withId: "1", stateKey: "MyState1",
  //                      if: { _, _ in return true }) { (x: MyState1) in
  //                        changed = true
  //                        val = x.value
  //    }
  //
  //    store.dispatch(action: IncrementAction())
  //    XCTAssertTrue(changed)
  //    XCTAssertEqual(val, 30)
  //  }

  //  func testListnerCanListenToStateForKeyWithFilterThatNeverReturnsTrue() {
  //    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())
  //
  //    var changed = false
  //    var val = 0
  //
  //    store.addListener(withId: "1", stateKey: "MyState1",
  //                      if: { _, _ in return false }) { (x: MyState1) in
  //                        changed = true
  //                        val = x.value
  //    }
  //
  //    store.dispatch(action: IncrementAction())
  //    XCTAssertFalse(changed)
  //    XCTAssertEqual(val, 0)
  //  }

  //  func testListnerCanListenToStateForKeyWithFilterWithATypeThatMatches() {
  //    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())
  //
  //    var changed = false
  //    var val = 0
  //
  //    store.addListener(withId: "1", stateKey: "MyState1",
  //                      if: { _, _ in return true }) { (x: MyState1) in
  //                        changed = true
  //                        val = x.value
  //    }
  //
  //    store.dispatch(action: IncrementAction())
  //    XCTAssertTrue(changed)
  //    XCTAssertEqual(val, 30)
  //  }

  
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
    XCTAssertEqual(val, 30)
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
  
  func testListnerCanListenToStateForKeyAndTypeThatMatchesAndAFilter() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())
    
    var changed = false
    var val = 0
    
    store.addListener(withId: "1", stateKey: "MyState1", type: MyState1.self,
                      if: { _, _ in return true }) { x in
                        changed = true
                        val = x.value
    }
    
    store.dispatch(action: IncrementAction())
    XCTAssertTrue(changed)
    XCTAssertEqual(val, 30)
  }
  
  func testListnerCanListenToStateForKeyAndTypeThatMatchesAndAFilterThatNeverReturnsTrue() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())
    
    var changed = false
    var val = 0
    
    store.addListener(withId: "1", stateKey: "MyState1", type: MyState1.self,
                      if: { _, _ in return false }) { x in
                        changed = true
                        val = x.value
    }
    
    store.dispatch(action: IncrementAction())
    XCTAssertFalse(changed)
    XCTAssertEqual(val, 0)
  }
  
  func testListnerCanListenToStateForKeyAndTypeThatMatchesAndAFilterThatAlwaysReturnsTrueButStateIsWrong() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())
    
    var changed = false
    var val = 0
    
    store.addListener(withId: "1", stateKey: "MyState2", type: MyState1.self,
                      if: { _, _ in return false }) { x in
                        changed = true
                        val = x.value
    }
    
    store.dispatch(action: IncrementAction())
    XCTAssertFalse(changed)
    XCTAssertEqual(val, 0)
  }
  
  func testItAddsActionListener() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())
    
    var actionReceived: Action? = nil
    store.addActionListener(withId: "1") { action in
      actionReceived = action
    }
    
    store.dispatch(action: IncrementAction())
    XCTAssertTrue(actionReceived is IncrementAction)
  }
  
  func testItRemovesAnActionListener() {
    let store = Suas.createStore(reducer: Reducer1() |> Reducer2())
    
    var actionReceived: Action? = nil
    store.addActionListener(withId: "1") { action in
      actionReceived = action
    }
    store.removeActionListener(withId: "1")
    
    store.dispatch(action: IncrementAction())
    XCTAssertNil(actionReceived)
  }
  
  //  func testItDoesNotNotifyIfKeyIsNotChanged() {
  //    struct Action1: Action {}
  //
  //    let reducer1 = BlockReducer(state: 1, key: "key1") { action, state in
  //      if action is Action1 {
  //        return state
  //      }
  //      return nil
  //    }
  //
  //    let reducer2 = BlockReducer(state: 1, key: "key2") { action, state in
  //      return nil
  //    }
  //
  //    let store = Suas.createStore(reducer: reducer1 |> reducer2)
  //
  //    var listener1Notified = false
  //    var listener2Notified = false
  //
  //    store.addListener(withId: "1", stateKey: "key1") { (s: Int) in
  //      listener1Notified = true
  //    }
  //
  //    store.addListener(withId: "2", stateKey: "key2") { (s: Int) in
  //      listener2Notified = true
  //    }
  //
  //    store.dispatch(action: Action1())
  //    XCTAssertTrue(listener1Notified)
  //    XCTAssertFalse(listener2Notified)
  //  }

  //  func testItDoesNotNotifyIfKeyIsNoneChanged() {
  //    struct Action1: Action {}
  //
  //    let reducer1 = BlockReducer(state: 1, key: "key1") { action, state in
  //      return nil
  //    }
  //
  //    let reducer2 = BlockReducer(state: 1, key: "key2") { action, state in
  //      return nil
  //    }
  //
  //    let store = Suas.createStore(reducer: reducer1 |> reducer2)
  //
  //    var listener1Notified = false
  //    var listener2Notified = false
  //
  //    store.addListener(withId: "1", stateKey: "key1") { (s: Int) in
  //      listener1Notified = true
  //    }
  //
  //    store.addListener(withId: "2", stateKey: "key2") { (s: Int) in
  //      listener2Notified = true
  //    }
  //
  //    store.dispatch(action: Action1())
  //    XCTAssertFalse(listener1Notified)
  //    XCTAssertFalse(listener2Notified)
  //  }

  //  func testListenersWithnoKeyAlwaysGetNotified() {
  //    struct Action1: Action {}
  //
  //    let reducer1 = BlockReducer(state: 1, key: "key1") { action, state in
  //      return nil
  //    }
  //
  //    let reducer2 = BlockReducer(state: 1, key: "key2") { action, state in
  //      return nil
  //    }
  //
  //    let store = Suas.createStore(reducer: reducer1 |> reducer2)
  //
  //    var listener1Notified = false
  //    var listener2Notified = false
  //    var listener3Notified = false
  //
  //    store.addListener(withId: "1", stateKey: "key1") { (s: Int) in
  //      listener1Notified = true
  //    }
  //
  //    store.addListener(withId: "2", stateKey: "key2") { (s: Int) in
  //      listener2Notified = true
  //    }
  //
  //    store.addListener(withId: "3") { (_) in
  //      listener3Notified = true
  //    }
  //
  //    store.dispatch(action: Action1())
  //    XCTAssertFalse(listener1Notified)
  //    XCTAssertFalse(listener2Notified)
  //    XCTAssertTrue(listener3Notified)
  //  }

  func testItCanAddAListenerWithAStateConverter() {
    let store = Suas.createStore(reducer: reducer1)

    var changed = false
    var newState = 0


    store.addListener(
      withId: "1",
      stateConverter: { _ in return 10 },
      callback: { state in
        changed = true
        newState = state
    })


    store.dispatch(action: IncrementAction())
    XCTAssertTrue(changed)
    XCTAssertEqual(newState, 10)
  }
}
