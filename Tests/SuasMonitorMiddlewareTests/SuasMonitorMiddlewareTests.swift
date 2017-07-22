//
//  SuasMonitorMiddlewareTests.swift
//  SuasMonitorMiddlewareTests
//
//  Created by Omar Abdelhafith on 21/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import XCTest
@testable import SuasMonitorMiddleware
@testable import Suas


class SuasMonitorMiddlewareTests: XCTestCase {

  var service: DummyService!
  let anyAPI = MiddlewareAPI(dispatch: { (action) in
  }, getState: { return StoreState(dictionary: ["a": 1]) })

  override func setUp() {
    service = DummyService()
  }

  func testItStartsTheServiceAtInit() {
    _ = MonitorMiddleware(stateEncodeCallback: nil, actionEncodeCallback: nil, monitorService: service)
    XCTAssertEqual(service.started, true)
  }

  func testWhenStartsSendsAnAction() {
    let monitor = MonitorMiddleware(stateEncodeCallback: nil, actionEncodeCallback: nil, monitorService: service)

    var actionDispatched: Action?
    let api = MiddlewareAPI(dispatch: { (action) in
      actionDispatched = action
    }, getState: { return StoreState(dictionary: ["a": 1]) })

    monitor.api = api
    service.callback?()

    XCTAssertTrue(actionDispatched is ConnectedToMonitor)
  }

  func testActionsAreSentToMonitorWhenSuasEncodable() {
    let monitor = MonitorMiddleware(stateEncodeCallback: nil, actionEncodeCallback: nil, monitorService: service)

    let state = DummyEncodableState(val: 10)
    let anyAPI = MiddlewareAPI(dispatch: { (action) in },
                               getState: { return StoreState(dictionary: ["a": state]) })
    monitor.api = anyAPI
    monitor.next = { _ in }
    service.callback?()

    monitor.onAction(action: ConnectedToMonitor())
    XCTAssertEqual(service.dataSent, "{\"actionData\":{},\"action\":\"ConnectedToMonitor\",\"state\":{\"a\":{\"val\":10}}}&&__&&__&&")
  }

  func testActionsAreSentToMonitorWhenActionBlockAndStateSuasEncodable() {
    let monitor = MonitorMiddleware(
      stateEncodeCallback: nil,
      actionEncodeCallback: { action in
        return (action as! NonEncodableAction).toDictionary()
    },
      monitorService: service)

    let state = DummyEncodableState(val: 10)
    let anyAPI = MiddlewareAPI(dispatch: { (action) in },
                               getState: { return StoreState(dictionary: ["a": state]) })
    monitor.api = anyAPI
    monitor.next = { _ in }
    service.callback?()

    monitor.onAction(action: NonEncodableAction(doit: 10))
    XCTAssertEqual(service.dataSent, "{\"actionData\":{\"doit\":10},\"action\":\"NonEncodableAction\",\"state\":{\"a\":{\"val\":10}}}&&__&&__&&")
  }

  func testActionsAreSentToMonitorWhenActionEncodableAndStateCallback1State() {
    let monitor = MonitorMiddleware(
      stateEncodeCallback: { state in
        return (state as! DummyNonEncodableState).toDictionary()
    },
      actionEncodeCallback: nil,
      monitorService: service)

    let state = DummyNonEncodableState(val2: 10)
    let anyAPI = MiddlewareAPI(dispatch: { (action) in },
                               getState: { return StoreState(dictionary: ["a": state]) })
    monitor.api = anyAPI
    monitor.next = { _ in }
    service.callback?()

    monitor.onAction(action: EncodableAction(doit2: 10))
    XCTAssertEqual(service.dataSent, "{\"actionData\":{\"doit2\":10},\"action\":\"EncodableAction\",\"state\":{\"a\":{\"val2\":10}}}&&__&&__&&")
  }

  func testActionsAreSentToMonitorWhenActionEncodableAndStateMixed() {
    let monitor = MonitorMiddleware(
      stateEncodeCallback: { state in
        return (state as! DummyNonEncodableState).toDictionary()
    },
      actionEncodeCallback: nil,
      monitorService: service)

    let anyAPI = MiddlewareAPI(
      dispatch: { (action) in },
      getState: { return
        StoreState(dictionary: [
          "a": DummyNonEncodableState(val2: 10),
          "b": DummyEncodableState(val: 40)
        ])
    })
    monitor.api = anyAPI
    monitor.next = { _ in }
    service.callback?()

    monitor.onAction(action: EncodableAction(doit2: 10))
    XCTAssertEqual(service.dataSent, "{\"actionData\":{\"doit2\":10},\"action\":\"EncodableAction\",\"state\":{\"b\":{\"val\":40},\"a\":{\"val2\":10}}}&&__&&__&&")
  }

  func testActionsAreSentToMonitorWhenActionCallbackAndStateMixed() {
    let monitor = MonitorMiddleware(
      stateEncodeCallback: { state in
        return (state as! DummyNonEncodableState).toDictionary()
    },
      actionEncodeCallback: {action in
        return (action as! NonEncodableAction).toDictionary()
    },
      monitorService: service)

    let anyAPI = MiddlewareAPI(
      dispatch: { (action) in  },
      getState: { return
        StoreState(dictionary: [
          "a": DummyNonEncodableState(val2: 10),
          "b": DummyEncodableState(val: 40)
          ])
    })
    monitor.api = anyAPI
    monitor.next = { _ in }
    service.callback?()

    monitor.onAction(action: NonEncodableAction(doit: 13))
    XCTAssertEqual(service.dataSent, "{\"actionData\":{\"doit\":13},\"action\":\"NonEncodableAction\",\"state\":{\"b\":{\"val\":40},\"a\":{\"val2\":10}}}&&__&&__&&")
  }

  func testDoesNotSendIfActionIsNotSuasAndNoCallback() {
    let monitor = MonitorMiddleware(
      stateEncodeCallback: nil,
      actionEncodeCallback: nil,
      monitorService: service)

    let state = DummyEncodableState(val: 10)
    let anyAPI = MiddlewareAPI(dispatch: { (action) in },
                               getState: { return StoreState(dictionary: ["a": state]) })
    monitor.api = anyAPI
    monitor.next = { _ in }
    service.callback?()

    monitor.onAction(action: NonEncodableAction(doit: 10))
    XCTAssertEqual(service.dataSent, "")
  }

  func testDoesNotSendIfStateIsNotSuasAndNoCallback() {
    let monitor = MonitorMiddleware(
      stateEncodeCallback: nil,
      actionEncodeCallback: nil,
      monitorService: service)

    let state = DummyNonEncodableState(val2: 10)
    let anyAPI = MiddlewareAPI(dispatch: { (action) in },
                               getState: { return StoreState(dictionary: ["a": state]) })
    monitor.api = anyAPI
    monitor.next = { _ in }
    service.callback?()

    monitor.onAction(action: EncodableAction(doit2: 10))
    XCTAssertEqual(service.dataSent, "")
  }

}

struct DummyEncodableState: SuasEncodable {
  let val: Int
  func toDictionary() -> [String : Any] {
    return [
      "val": val
    ]
  }
}

struct DummyNonEncodableState {
  let val2: Int

  func toDictionary() -> [String : Any] {
    return [
      "val2": val2
    ]
  }
}

struct NonEncodableAction: Action {
  var doit: Int

  func toDictionary() -> [String : Any] {
    return [
      "doit": doit
    ]
  }
}

struct EncodableAction: Action, SuasEncodable {
  var doit2: Int

  func toDictionary() -> [String : Any] {
    return [
      "doit2": doit2
    ]
  }
}

class DummyService: MonitorService {
  var started: Bool = false
  var dataSent: String = ""
  var callback: (() -> ())? = nil

  func start(onConnectBlock: @escaping () -> ()) {
    started = true
    self.callback = onConnectBlock
  }

  func send(data: Data) {
    dataSent = String(data: data, encoding: .utf8)!
  }
}
