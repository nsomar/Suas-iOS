//
//  AppDelegate.swift
//  TodoSampleApp-Mac
//
//  Created by Omar Abdelhafith on 20/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Cocoa
import Suas
import SuasMonitorMiddleware

let logger = LoggerMiddleware(showTimestamp: true, showDuration: true, lineLength: 100)

let store = Suas.createStore(reducer: todoReducer,
                             middleware: MonitorMiddleware() |> logger)

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }


}

