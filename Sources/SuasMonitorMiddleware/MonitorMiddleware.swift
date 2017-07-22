//
//  MonitorMiddleware.swift
//  Suas
//
//  Created by Omar Abdelhafith on 20/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation
import Suas

protocol SuasEncodable {
  func toDictionary() -> [String: Any]
}

struct ConnectedToMonitor: Action, SuasEncodable {
  func toDictionary() -> [String : Any] {
    return [:]
  }
}

fileprivate let closingPlaceholder = "&&__&&__&&"

public typealias EncodingCallback<Type> = (Type) -> [String: Any]?

public class MonitorMiddleware: Middleware {
  public var api: MiddlewareAPI?
  public var next: DispatchFunction?

  private var monitorService: MonitorService

  private var stateEncodeCallback: EncodingCallback<Any>?
  private var actionEncodeCallback: EncodingCallback<Action>?

  public convenience init(stateEncodeCallback: EncodingCallback<Any>? = nil, actionEncodeCallback: EncodingCallback<Action>? = nil) {
    self.init(stateEncodeCallback: stateEncodeCallback,
              actionEncodeCallback: actionEncodeCallback,
              monitorService: DefaultMonitorService())
  }

  init(stateEncodeCallback: EncodingCallback<Any>? = nil, actionEncodeCallback: EncodingCallback<Action>? = nil, monitorService: MonitorService) {
    self.stateEncodeCallback = stateEncodeCallback
    self.actionEncodeCallback = actionEncodeCallback

    self.monitorService = monitorService

    self.monitorService.start { [weak self] in
      self?.sendInitialState()
    }
  }

  public func onAction(action: Action) {
    guard let api = api, let next = next else { return }

    next(action)
    sendToMonitor(state: api.state, action: action)
  }

  private func sendInitialState() {
    guard let api = api else { return }
    api.dispatch(ConnectedToMonitor())
  }

  private func sendToMonitor(state: StoreState, action: Action) {
    guard
      let stateDict = dictionary(forState: state),
      let actionDict = dictionary(forAction: action) else {
        logString("Action and/or State can not be converted to [String: Any]\n" +
          "State: \(state)\n" +
          "Action: \(action)\n" +
          "\n" +
          "State and Action can either implement the `SuasEncodable` or pass `EncodingCallback` when creating the `MonitorMiddleware`")
        return
    }

    let dictionaryToSend: [String: Any] = [
      "action" : "\(type(of: action))",
      "actionData": actionDict,
      "state" : stateDict
    ]

    var data = try! JSONSerialization.data(withJSONObject: dictionaryToSend, options: [])
    data.append(closingPlaceholder.data(using: .utf8)!)

    monitorService.send(data: data)
  }

  private func dictionary(forState state: StoreState) -> [String: Any]? {
    var stateToSend: [String: Any] = [:]

    state.keys.forEach { key in
      guard let value = state[key] else { return }

      if let encodableValue = value as? SuasEncodable {
        stateToSend[key] = encodableValue.toDictionary()
      } else if let callback = stateEncodeCallback, let stateValue = callback(value) {
        stateToSend[key] = stateValue
      } else {
        logString("State key \(key) was with value \(String(describing: state[key])) does not implement `SuasEncodable`. Skipping key")
      }
    }

    return stateToSend.isEmpty ? nil : stateToSend
  }

  private func dictionary(forAction action: Action) -> [String: Any]? {
    if let action = action as? SuasEncodable {
      return action.toDictionary()
    }

    if let callback = actionEncodeCallback {
      return callback(action)
    }

    return nil
  }

}
