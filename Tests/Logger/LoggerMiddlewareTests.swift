//
//  LoggerMiddlewareTests.swift
//  SuasIOS
//
//  Created by Omar Abdelhafith on 22/07/2017.
//  Copyright © 2017 Zendesk. All rights reserved.
//

import Foundation

import XCTest
@testable import Suas

class LoggerMiddlewareTests: XCTestCase {

  let testDate = Date(timeIntervalSince1970: 123456)
  var startDate: DispatchTime!
  var endDate: DispatchTime!

  override func setUp() {
    startDate = DispatchTime.now()
    endDate = startDate + 0.001
  }

  func testItPrintsALog() {
    var logged = ""
    let log = LoggerMiddleware(showTimestamp: true, showDuration: true, logger: { logged = $0 })
    log.onAction(action: SomeAction(),
                 getState: getState(forState: "111"),
                 dispatch: { _ in },
                 next: { _ in })
    XCTAssertNotEqual(logged, "")
  }

  func testItPrintsWithoutTheTimeStamp() {
    let logged = LoggingParts.title(
      action: SomeAction(),
      duration: 1000000,
      date: testDate,
      showTimestamp: false,
      showDuration: false)
    XCTAssertEqual(logged, "┌───→ Action: SomeAction")
  }

  func testItPrintsWithTheTimeStamp() {
    let logged = LoggingParts.title(
      action: SomeAction(),
      duration: 1000,
      date: testDate,
      showTimestamp: true,
      showDuration: false)

    let dateString = LoggerMiddleware.dateFormatter.string(from: testDate)
    XCTAssertEqual(logged, "┌───→ Action: SomeAction @\(dateString)")
  }

  func testItPrintsWithDuration() {
    let logged = LoggingParts.title(
      action: SomeAction(),
      duration: 1000000,
      date: testDate,
      showTimestamp: false,
      showDuration: true)
    XCTAssertEqual(logged, "┌───→ Action: SomeAction (in 1000 µs)")
  }

  func testItPrintsWithTheTimeStampAndDuration() {
    let logged = LoggingParts.title(
      action: SomeAction(),
      duration: 1000000,
      date: testDate,
      showTimestamp: true,
      showDuration: true)

    let dateString = LoggerMiddleware.dateFormatter.string(from: testDate)
    XCTAssertEqual(logged, "┌───→ Action: SomeAction @\(dateString) (in 1000 µs)")
  }

  func testItPrintsIfPredicatePasses() {
    var logged = ""
    var stateReceived: State?
    var actionReceived: Action?

    let log = LoggerMiddleware(
      predicate: { state, action in
        stateReceived = state
        actionReceived = action
        return true
    },
      logger: { logged = $0 }
    )

    log.onAction(action: SomeAction(),
                 getState: getState(forState: "111"),
                 dispatch: { _ in },
                 next: { _ in })

    XCTAssert(stateReceived!.value(forKey: "a", ofType: String.self) == "111" )
    XCTAssert(actionReceived is SomeAction)
    XCTAssertNotEqual(logged, "")
  }

  func testItDoesNotPrintIfPredicateFailes() {
    var logged = ""

    let log = LoggerMiddleware(
      predicate: { state, action in return false },
      logger: { logged = $0 }
    )

    log.onAction(action: SomeAction(),
                 getState: getState(forState: "111"),
                 dispatch: { _ in },
                 next: { _ in })

    XCTAssertEqual(logged, "")
  }

  func testItTransformsTheAction() {
    var logged = ""

    let log = LoggerMiddleware(
      showTimestamp: false,
      showDuration: false,
      actionTransformer: { action in return "NewAction" },
      logger: { logged = $0 }
    )

    log.onAction(action: SomeAction(),
                 getState: getState(forState: "111"),
                 dispatch: { _ in },
                 next: { _ in })

    XCTAssertEqual(logged, "┌───→ Action: SomeAction\n├─ Prev state ► State(innerState: [\"a\": \"111\"])\n├─ Action     ► NewAction\n├─ Next state ► State(innerState: [\"a\": \"111\"])\n└───────────────────────")
  }

  func testItTransformsTheState() {
    var logged = ""

    let log = LoggerMiddleware(
      showTimestamp: false,
      showDuration: false,
      stateTransformer: { state in return "NewState" },
      logger: { logged = $0 }
    )

    log.onAction(action: SomeAction(),
                 getState: getState(forState: "111"),
                 dispatch: { _ in },
                 next: { _ in })

    XCTAssertEqual(logged, "┌───→ Action: SomeAction\n├─ Prev state ► NewState\n├─ Action     ► SomeAction(value: 10)\n├─ Next state ► NewState\n└───────────────────────")
  }

  func testItTransformsTheTitlee() {
    var logged = ""
    var action: Action?
    var date: Date = Date()
    var time: UInt64 = 0

    let log = LoggerMiddleware(
      showTimestamp: false,
      showDuration: false,
      titleFormatter: { a, d, t in
        action = a
        date = d
        time = t
        return "XXXXX:"
      },
      logger: { logged = $0 }
    )

    log.onAction(action: SomeAction(),
                 getState: getState(forState: "111"),
                 dispatch: { _ in },
                 next: { _ in })

    XCTAssert(action is SomeAction)
    XCTAssertNotNil(date)
    XCTAssert(time != 0)
    XCTAssertEqual(logged, "XXXXX:\n├─ Prev state ► State(innerState: [\"a\": \"111\"])\n├─ Action     ► SomeAction(value: 10)\n├─ Next state ► State(innerState: [\"a\": \"111\"])\n└─────")
  }

  func testItPrintsMultiLineWithNoLength() {
    let l = LoggingParts.line(prefix: "├─ Next state ► ", content: "sssdasd asd asda dsas d ddasd saasd asd saasd sad as dasd asd as", length: nil)
    XCTAssertEqual(l, "├─ Next state ► sssdasd asd asda dsas d ddasd saasd asd saasd sad as dasd asd as")
  }

  func testItPrintsMultiLineWithLength() {
    let l = LoggingParts.line(prefix: "├─ Next state ► ", content: "The World Standard Teletext (WST) uses pixel-drawing characters for some graphics. A character cell is divided in", length: 40)
    XCTAssertEqual(l, "├─ Next state ► The World Standard Tele\n│               text (WST) uses pixel-d\n│               rawing characters for s\n│               ome graphics. A charact\n│               er cell is divided in")
  }

  func getState(forState: Any) -> GetStateFunction {
    return { return State(dictionary: ["a": forState]) }
  }
}

struct SomeAction: Action {
  let value = 10
}


