//
//  MonitorService.swift
//  Suas
//
//  Created by Omar Abdelhafith on 21/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

fileprivate var numberOfMonitors = 0

protocol MonitorService {
  func start(onConnectBlock: @escaping () -> ())
  func send(data: Data)
}

class DefaultMonitorService: NSObject, GCDAsyncSocketDelegate, NetServiceDelegate, MonitorService {

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

func logString(_ string: String) {
  print("Monitor: \(string))")
}
