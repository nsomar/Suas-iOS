//
//  StoreTests.swift
//  SuasIOSTests
//
//  Created by Omar Abdelhafith on 20/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import XCTest
@testable import Suas

class StoreTests: XCTestCase {

  func testItCanGetTheFullState() {
    let store = Suas.createStore(reducer: Reducer1() + Reducer2())

    let v1 = store.state.value(forKey: "MyState1", ofType: MyState1.self)?.value
    let v2 = store.state.value(forKey: "MyState2", ofType: MyState2.self)?.blink

    XCTAssertEqual(v1, 10)
    XCTAssertEqual(v2, 20)
  }

  func testItCanSetTheStateForAKey() {
    let store = Suas.createStore(reducer: Reducer1() + Reducer2())

    store.reset(state: "1", forKey: "MyState1")
    store.reset(state: 2, forKey: "MyState2")

    let v1 = store.state.value(forKey: "MyState1", ofType: String.self)
    let v2 = store.state.value(forKey: "MyState2", ofType: Int.self)

    XCTAssertEqual(v1, "1")
    XCTAssertEqual(v2, 2)
  }

  func testItCannotSetAWrongReducer() {
    let store = Suas.createStore(reducer: reducer1, state: 1)
    store.dispatch(action: IncrementAction())
  }

  func testItCanSetTheStateForAKeyImplicitely() {
    let store = Suas.createStore(reducer: Reducer1() + Reducer2())

    store.reset(state: MyState1(value: 50))

    let v1 = store.state.value(forKey: "MyState1", ofType: MyState1.self)?.value
    let v2 = store.state.value(forKey: "MyState2", ofType: MyState2.self)?.blink

    XCTAssertEqual(v1, 50)
    XCTAssertEqual(v2, 20)
  }

  func testItCanSetTheFullState() {
    let store = Suas.createStore(reducer: Reducer1() + Reducer2())

    store.resetFullState([
      "a": 10,
      "b": "20"
    ])

    let v1 = store.state.value(forKey: "a", ofType: Int.self)
    let v2 = store.state.value(forKey: "b", ofType: String.self)

    XCTAssertEqual(v1, 10)
    XCTAssertEqual(v2, "20")
  }

  func testItDoesNotDispatchTwice() {
    let tempReducer = BlockReducer(initialState: 1) { state, action in
      if let action = action as? TempAction {
        action.dispatch(IncrementAction())
      }
      
      return state
    }

    struct TempAction: Action {
      let dispatch: DispatchFunction
    }

    var fatalErrorCalled = false
    Suas.fatalErrorHandler = {
      fatalErrorCalled = true
    }

    let store = Suas.createStore(reducer: reducer1 + tempReducer)

    store.dispatch(action: TempAction(dispatch: store.dispatch))
    XCTAssertTrue(fatalErrorCalled)
  }

  func testItDoesDispatchTwiceOneAfterTheOther() {
    let tempReducer = BlockReducer(initialState: 1) { state, action in
      return state
    }

    struct TempAction: Action {
      let dispatch: DispatchFunction
    }

    var fatalErrorCalled = false
    Suas.fatalErrorHandler = {
      fatalErrorCalled = true
    }

    let store = Suas.createStore(reducer: reducer1 + tempReducer)

    store.dispatch(action: TempAction(dispatch: store.dispatch))
    store.dispatch(action: TempAction(dispatch: store.dispatch))
    
    XCTAssertFalse(fatalErrorCalled)
  }
}
