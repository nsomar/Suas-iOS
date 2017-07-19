//
//  SuasIOSTests.swift
//  SuasIOSTests
//
//  Created by Omar Abdelhafith on 18/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import XCTest
import SuasIOS

class ReducerTests: XCTestCase {

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testItReducesWithABlockWithState() {
    struct MyState {
      var value = 0
    }

    struct IncrementAction: Action {}

    let r = BlockReducer(state: MyState(value: 0)) { action, state in
      var newState = state

      if action is IncrementAction {
        newState.value = newState.value + 1
      }

      return newState
    }

    let state = MyState(value: 0)
    let newState = r.reduce(action: IncrementAction(), state: state)

    XCTAssertEqual((newState as! MyState).value, 1)
  }
}
