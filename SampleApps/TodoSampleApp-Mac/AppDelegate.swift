//
//  AppDelegate.swift
//  TodoSampleApp-Mac
//
//  Created by Omar Abdelhafith on 20/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Cocoa
import Suas

let logger = LoggerMiddleware(showTimestamp: true, showDuration: true, lineLength: 100)

let store = Suas.createStore(reducer: todoReducer, middleware: logger)

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
}

