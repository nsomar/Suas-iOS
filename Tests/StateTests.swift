//
//  SuasIOSTests.swift
//  SuasIOSTests
//
//  Created by Omar Abdelhafith on 18/07/2017.
//  Copyright © 2017 Zendesk. All rights reserved.
//

import XCTest
@testable import Suas

class StateTests: XCTestCase {

  func testItImplementsRuntimeEquatable() {
    let v1 = MyEquatableState1(val: 10)
    let v2 = MyEquatableState1(val: 10)

    XCTAssertEqual(v1.isEqual(to: v2), true)
    XCTAssertEqual(v1.isEqual(to: "x"), false)
  }

  func testItCanBeCreatedFromADictionary() {
    let s: State = ["a" : 2]
    XCTAssertEqual(Array(s.innerState.keys), ["a"])
    XCTAssertEqual(Array(s.innerState.values) as! [Int], [2])
  }

  func testItCanGetAValueForAKey() {
    let s: State = ["a" : 2]
    XCTAssertEqual(s["a"] as! Int, 2)
  }

#if swift(>=4.0)
  func testItCanGetAValueForAKeyAndType() {
    let s: State = ["a" : 2]
    XCTAssertEqual(s[forKey: "a", ofType: Int.self], 2)
  }

  func testItReturnNulIfKeyIsNotFoundOrIsOfWrongType() {
    let s: State = ["a" : 2]
    XCTAssertEqual(s[forKey: "a", ofType: String.self], nil)
    XCTAssertEqual(s[forKey: "x", ofType: Int.self], nil)
  }

  func testItCanGetAValueForAType() {
    let s: State = ["Int" : 2]
    XCTAssertEqual(s[forKeyOfType: Int.self], 2)
  }

  func testItCanGetAValueForATypeAndReturnNilIfNotFound() {
    let s: State = ["Int" : "xxx"]
    XCTAssertEqual(s[forKeyOfType: String.self], nil)
    XCTAssertEqual(s[forKeyOfType: Int.self], nil)
  }
#endif

  func testItCanGetAValueForAKeySwift3() {
    let s: State = ["a" : 2]
    XCTAssertEqual(s.value(forKey: "a") as! Int, 2)
  }

  func testItCanGetAValueForAKeyAndTypeSwift3() {
    let s: State = ["a" : 2]
    XCTAssertEqual(s.value(forKey: "a", ofType: Int.self), 2)
  }

  func testItReturnNulIfKeyIsNotFoundOrIsOfWrongTypeSwift3() {
    let s: State = ["a" : 2]

    XCTAssertEqual(s.value(forKey: "a", ofType: String.self), nil)
    XCTAssertEqual(s.value(forKey: "x", ofType: Int.self), nil)
  }

  func testItCanGetAValueForATypeSwift3() {
    let s: State = ["Int" : 2]
    XCTAssertEqual(s.value(forKeyOfType: Int.self), 2)
  }

  func testItCanGetAValueForATypeAndReturnNilIfNotFoundSwift3() {
    let s: State = ["Int" : "xxx"]

    XCTAssertEqual(s.value(forKeyOfType: String.self), nil)
    XCTAssertEqual(s.value(forKeyOfType: Int.self), nil)
  }
}
