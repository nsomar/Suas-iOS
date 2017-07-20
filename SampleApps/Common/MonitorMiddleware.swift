//
//  MonitorMiddleware.swift
//  Suas
//
//  Created by Omar Abdelhafith on 20/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation
#if os(macOS)
  @testable import SuasMac
#else
  @testable import SuasIOS
#endif

protocol SuasEncodable {
  func toDictionary() -> [String: Any]
}

struct ConnectedToMonitor: Action {
  func toDictionary() -> [String : Any] {
    return [:]
  }
}

class MonitorMiddleware: Middleware {
  var api: MiddlewareAPI?

  var next: DispatchFunction?

  init() {
    MonitorService.shared.start()
  }

  func onAction(action: Action) {
    guard let api = api, let next = next else { return }
    next(action)
    sendToMonitor(state: api.state, action: action)
  }

  func sendToMonitor(state: StoreState, action: Action) {
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

    MonitorService.shared.send(data: data)
  }
}

public class MonitorService: NSObject, GCDAsyncSocketDelegate, NetServiceDelegate {

  public static let shared = MonitorService()

  var service: NetService!
  var socket: GCDAsyncSocket!
  var clients = [GCDAsyncSocket]()

  private override init() {
    super.init()
    start()
  }

  public func start() {
    //This should probably do things
    self.socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue(label: "ReduxMonitor"))
    try? self.socket.accept(onPort: 8081)
    self.service = NetService(domain: "", type: "_redux-monitor._tcp.", name: "", port: 8081)

    if let service = service {
      print("Bonjour Service started")
      service.delegate = self
      service.publish()
    }
  }

  func send(data: Data) {
    print("Sending data to clients")
    for client in clients {
      client.write(data, withTimeout: -1, tag: 0)
    }
  }

  //MARK: GCDAsyncSocket Delegates

  public func socket(_ sock: GCDAsyncSocket!, didAcceptNewSocket newSocket: GCDAsyncSocket!) {
    //Start sending stuff
    clients.append(newSocket)
    store.dispatch(action: ConnectedToMonitor())
  }
}
