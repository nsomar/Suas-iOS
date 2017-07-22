//
//  AppDelegate.swift
//  Suas-iOS-SampleApp
//
//  Created by Omar Abdelhafith on 18/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import UIKit
import Suas
import SuasMonitorMiddleware

let store = Suas.createStore(reducer: todoReducer, middleware: MonitorMiddleware())

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    return true
  }
}

