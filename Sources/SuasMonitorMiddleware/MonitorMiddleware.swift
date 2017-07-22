//
//  MonitorMiddleware.swift
//  Suas
//
//  Created by Omar Abdelhafith on 20/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation
import Suas

struct ConnectedToMonitor: Action, SuasEncodable {
  func toDictionary() -> [String : Any] {
    return [:]
  }
}

fileprivate let closingPlaceholder = "&&__&&__&&"

public typealias EncodingCallback<Type> = (Type) -> [String: Any]?


/// Middle ware that transmits the state and actions to the `SuasMonitor` mac app
///
/// MonitorMiddleware needs to convert actions and states to [String: Any] so that it can transmit them to the `SuasMonitor` mac app. That can be done with:
/// - Implement `SuasEncodable` in your Actions and States. `MonitorMiddleware` will use this protocol to convert the action and state to [String: Any]
/// - OR implement `stateEncoder` and `actionEncoder`: `MonitorMiddleware` will call these callbacks passing the state and action. The callbacks inturn have to return a `[String: Any]`
public class MonitorMiddleware: Middleware {

  public var api: MiddlewareAPI?
  public var next: DispatchFunction?

  private var monitorService: MonitorService

  private var stateEncoder: EncodingCallback<Any>?
  private var actionEncoder: EncodingCallback<Action>?

  /// Create a MonitorMiddleware
  ///
  /// - Parameters:
  ///   - stateEncoder: (optional) callback that converts a state type to [String: Any]
  ///   - actionEncoder: (optional) callback that converts an action type to [String: Any]
  public convenience init(stateEncoder: EncodingCallback<Any>? = nil, actionEncoder: EncodingCallback<Action>? = nil) {
    self.init(stateEncoder: stateEncoder,
              actionEncoder: actionEncoder,
              monitorService: DefaultMonitorService())
  }

  init(stateEncoder: EncodingCallback<Any>? = nil, actionEncoder: EncodingCallback<Action>? = nil, monitorService: MonitorService) {
    self.stateEncoder = stateEncoder
    self.actionEncoder = actionEncoder

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
    guard let stateDict = dictionary(forState: state) else {
      logError("State", "stateEncoder", state)
      return
    }

    guard let actionDict = dictionary(forAction: action) else {
      logError("Action", "actionEncoder", action)
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

  private func logError(_ type: String, _ callback: String, _ value: Any) {
    logString("\(type) can not be converted to [String: Any]\n" +
      "\(type): \(value)\n" +
      "-> State and Action can either implement the `SuasEncodable` or set `\(callback)` when creating the `MonitorMiddleware`")
  }

  private func dictionary(forState state: StoreState) -> [String: Any]? {
    var stateToSend: [String: Any] = [:]

    state.keys.forEach { key in
      guard let value = state[key] else { return }

      if let encodableValue = value as? SuasEncodable {
        stateToSend[key] = encodableValue.toDictionary()
      } else if let callback = stateEncoder, let stateValue = callback(value) {
        stateToSend[key] = stateValue
      } else {
        logString([
          "State with key: \(key)",
          "Value: \(String(describing: state[key]!))",
          "does not implement `SuasEncodable`. Skipping key"
          ].joined(separator: "\n"))
      }
    }

    return stateToSend.isEmpty ? nil : stateToSend
  }

  private func dictionary(forAction action: Action) -> [String: Any]? {
    if let action = action as? SuasEncodable {
      return action.toDictionary()
    }

    if let callback = actionEncoder {
      return callback(action)
    }

    return nil
  }
}
