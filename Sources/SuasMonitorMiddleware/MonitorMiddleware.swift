//
//  MonitorMiddleware.swift
//  Suas
//
//  Created by Omar Abdelhafith on 20/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation
import Suas
import CocoaAsyncSocket

protocol SuasEncodable {
  func toDictionary() -> [String: Any]
}

private struct ConnectedToMonitor: Action {
  func toDictionary() -> [String : Any] {
    return [:]
  }
}

public class MonitorMiddleware: Middleware {
  public var api: MiddlewareAPI?
  public var next: DispatchFunction?

  private var monitorService: MonitorService

  public init() {
    monitorService = MonitorService()

    monitorService.start { [weak self] in
      self?.sendStoredState()
    }
  }

  public func onAction(action: Action) {
    guard let api = api, let next = next else { return }
    next(action)
    sendToMonitor(state: api.state, action: action)
  }

  private func sendStoredState() {
    guard let api = api else { return }
    api.dispatch(ConnectedToMonitor())
  }

  private func sendToMonitor(state: StoreState, action: Action) {
    var stateToSend: [String: Any] = [:]

    state.keys.forEach { key in
      if let value = state[key] as? SuasEncodable {
        stateToSend[key] = value.toDictionary()
      }
    }

    var map: [String: Any] = [
      "state" : stateToSend,
      "action" : "\(type(of: action))"
    ]

    if let encodableAction = action as? SuasEncodable {
      map["actionData"] = encodableAction.toDictionary()
    }

    var data = try! JSONSerialization.data(withJSONObject: map, options: [])
    let cr = "&&__&&__&&".data(using: .utf8)!

    data.append(cr)

    monitorService.send(data: data)
  }
}

fileprivate var numberOfMonitors = 0

fileprivate class MonitorService: NSObject, GCDAsyncSocketDelegate, NetServiceDelegate {

  var service: NetService!
  var socket: GCDAsyncSocket!
  var clients = [GCDAsyncSocket]()
  var onConnectBlock: (() -> ())?

  func start(onConnectBlock: @escaping () -> ()) {
    // Get a port number
    let port = numberOfMonitors + 8081

    socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue(label: "ReduxMonitor"))
    try? self.socket.accept(onPort: UInt16(port))
    self.service = NetService(domain: "", type: "_redux-monitor._tcp.", name: "", port: Int32(port))

    if let service = service {
      logString("Bonjour Service started")
      service.delegate = self
      service.publish()
    }
  }

  func send(data: Data) {
    logString("Sending data to Suas monitor")

    for client in clients {
      client.write(data, withTimeout: -1, tag: 0)
    }
  }

  //MARK: GCDAsyncSocket Delegates
  func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
    //Start sending stuff
    clients.append(newSocket)
    onConnectBlock?()
  }
}

fileprivate func logString(_ string: String) {
  print("Monitor: \(string))")
}
