//
//  SuasIOSTests.swift
//  SuasIOSTests
//
//  Created by Omar Abdelhafith on 18/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import XCTest
@testable import Suas

class StateConverterTests: XCTestCase {

  func testItConvertsATypeToAnother() {
    let converter: StateConverter<MyState1> = { state in
      return MyState1(value: state.value(forKey: "myKey", ofType: Int.self)!)
    }

    let state = converter(["myKey": 10])
    XCTAssertEqual(state!.value, 10)
  }

  func testItReturnNulIfCannotBeConverted() {
    let converter: StateConverter<MyState1> = { state in
      return nil
    }

    let state = converter(["myKey": 10])
    XCTAssertNil(state)
  }
}
