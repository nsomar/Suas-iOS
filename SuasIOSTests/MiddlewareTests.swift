//
//  MiddlewareTests.swift
//  SuasIOSTests
//
//  Created by Omar Abdelhafith on 20/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import XCTest
import SuasIOS

class MiddlewareTests: XCTestCase {

  func testItCanAddABlockMiddleware() {
    let store = Suas.createStore(reducer: Reducer1(), middleware: middleware1)
    store.dispatch(action: IncrementAction())

    let v = store.state.value(forKeyOfType: MyState1.self)?.value
    XCTAssertEqual(v, 30)
  }

  func testCallingOnActionDirectlyDoesNotWork() {
    middleware1.onAction(action: IncrementAction())
  }

  func testCallingOnActionDirectlyDoesNotWorkOnCombined() {
    (middleware1 |> middleware2).onAction(action: IncrementAction())
  }

  func testItCanAddTwoMiddlewares() {
    var m1Called = false
    var m2Called = false

    let middleware1 = BlockMiddleware { action, api, next in
      m1Called = true
      next(action)
    }

    let middleware2 = BlockMiddleware { action, api, next in
      m2Called = true
      next(action)
    }

    let store = Suas.createStore(reducer: Reducer1(), middleware: middleware1 |> middleware2)
    store.dispatch(action: IncrementAction())

    XCTAssertEqual(m1Called, true)
    XCTAssertEqual(m2Called, true)
  }

  func testCombineCanBeBefore() {
    var m1Called = false
    var m2Called = false
    var m3Called = false

    let middleware1 = BlockMiddleware { action, api, next in
      m1Called = true
      next(action)
    }

    let middleware2 = BlockMiddleware { action, api, next in
      m2Called = true
      next(action)
    }

    let middleware3 = BlockMiddleware { action, api, next in
      m3Called = true
      next(action)
    }

    let c = middleware1 |> middleware2
    let store = Suas.createStore(reducer: Reducer1(), middleware: c |> middleware3)
    store.dispatch(action: IncrementAction())

    XCTAssertEqual(m1Called, true)
    XCTAssertEqual(m2Called, true)
    XCTAssertEqual(m3Called, true)
  }

  func testCombineCanBeAfter() {
    var m1Called = false
    var m2Called = false
    var m3Called = false

    let middleware1 = BlockMiddleware { action, api, next in
      m1Called = true
      next(action)
    }

    let middleware2 = BlockMiddleware { action, api, next in
      m2Called = true
      next(action)
    }

    let middleware3 = BlockMiddleware { action, api, next in
      m3Called = true
      next(action)
    }

    let c = middleware1 |> middleware2
    let store = Suas.createStore(reducer: Reducer1(), middleware: middleware3 |> c)
    store.dispatch(action: IncrementAction())

    XCTAssertEqual(m1Called, true)
    XCTAssertEqual(m2Called, true)
    XCTAssertEqual(m3Called, true)
  }

  func testCombineTowCombines() {
    var m1Called = false
    var m2Called = false
    var m3Called = false
    var m4Called = false

    let middleware1 = BlockMiddleware { action, api, next in
      m1Called = true
      next(action)
    }

    let middleware2 = BlockMiddleware { action, api, next in
      m2Called = true
      next(action)
    }

    let middleware3 = BlockMiddleware { action, api, next in
      m3Called = true
      next(action)
    }

    let middleware4 = BlockMiddleware { action, api, next in
      m4Called = true
      next(action)
    }

    let c1 = middleware1 |> middleware2
    let c2 = middleware3 |> middleware4

    let store = Suas.createStore(reducer: Reducer1(), middleware: c1 |> c2)
    store.dispatch(action: IncrementAction())

    XCTAssertEqual(m1Called, true)
    XCTAssertEqual(m2Called, true)
    XCTAssertEqual(m3Called, true)
    XCTAssertEqual(m4Called, true)
  }

  func testMiddlewareCanReadState() {
    var val = -1
    let middleware1 = BlockMiddleware { action, api, next in
      val = api.state.value(forKeyOfType: MyState1.self)!.value
      next(action)
    }

    let store = Suas.createStore(reducer: Reducer1(), middleware: middleware1 |> middleware2)
    store.dispatch(action: IncrementAction())

    XCTAssertEqual(val, 10)
  }
}

