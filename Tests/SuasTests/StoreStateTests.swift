//
//  SuasIOSTests.swift
//  SuasIOSTests
//
//  Created by Omar Abdelhafith on 18/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import XCTest
@testable import Suas

class StoreStateTests: XCTestCase {

  func testItImplementsRuntimeEquatable() {
    let v1 = MyEquatableState1(val: 10)
    let v2 = MyEquatableState1(val: 10)

    XCTAssertEqual(v1.isEqual(to: v2), true)
    XCTAssertEqual(v1.isEqual(to: "x"), false)
  }

  func testItCanBeCreatedFromADictionary() {
    let s: StoreState = ["a" : 2]
    XCTAssertEqual(Array(s.innerState.keys), ["a"])
    XCTAssertEqual(Array(s.innerState.values) as! [Int], [2])
  }

  func testItCanGetAValueForAKey() {
    let s: StoreState = ["a" : 2]
    XCTAssertEqual(s["a"] as! Int, 2)
  }

#if swift(>=4.0)
  func testItCanGetAValueForAKeyAndType() {
    let s: StoreState = ["a" : 2]
    XCTAssertEqual(s[forKey: "a", ofType: Int.self], 2)
  }

  func testItReturnNulIfKeyIsNotFoundOrIsOfWrongType() {
    let s: StoreState = ["a" : 2]
    XCTAssertEqual(s[forKey: "a", ofType: String.self], nil)
    XCTAssertEqual(s[forKey: "x", ofType: Int.self], nil)
  }

  func testItCanGetAValueForAType() {
    let s: StoreState = ["Int" : 2]
    XCTAssertEqual(s[forKeyOfType: Int.self], 2)
  }

  func testItCanGetAValueForATypeAndReturnNilIfNotFound() {
    let s: StoreState = ["Int" : "xxx"]
    XCTAssertEqual(s[forKeyOfType: String.self], nil)
    XCTAssertEqual(s[forKeyOfType: Int.self], nil)
  }
#endif

  func testItCanGetAValueForAKeySwift3() {
    let s: StoreState = ["a" : 2]
    XCTAssertEqual(s.value(forKey: "a") as! Int, 2)
  }

  func testItCanGetAValueForAKeyOrFail() {
    let s: StoreState = ["a" : 2]
    XCTAssertEqual(s.valueOrFail(forKey: "a") as! Int, 2)
  }

  func testItCanGetAValueForAKeyAndTypeSwift3() {
    let s: StoreState = ["a" : 2]
    XCTAssertEqual(s.value(forKey: "a", ofType: Int.self), 2)
  }

  func testItCanGetAValueForAKeyAndTypeOrFail() {
    let s: StoreState = ["a" : 2]
    XCTAssertEqual(s.valueOrFail(forKey: "a", ofType: Int.self), 2)
  }

  func testItReturnNulIfKeyIsNotFoundOrIsOfWrongTypeSwift3() {
    let s: StoreState = ["a" : 2]

    XCTAssertEqual(s.value(forKey: "a", ofType: String.self), nil)
    XCTAssertEqual(s.value(forKey: "x", ofType: Int.self), nil)
  }

  func testItCanGetAValueForATypeSwift3() {
    let s: StoreState = ["Int" : 2]
    XCTAssertEqual(s.value(forKeyOfType: Int.self), 2)
  }

  func testItCanGetAValueForATypeAndReturnNilIfNotFoundSwift3() {
    let s: StoreState = ["Int" : "xxx"]

    XCTAssertEqual(s.value(forKeyOfType: String.self), nil)
    XCTAssertEqual(s.value(forKeyOfType: Int.self), nil)
  }
}
