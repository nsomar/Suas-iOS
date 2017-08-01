//
//  DefaultStoreConnectExtension.swift
//  SuasIOS
//
//  Created by Omar Abdelhafith on 20/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation

// MARK: Registartion

extension Suas {
  
  enum ConnectionType: String {
    case listener = "connectListener"
    case actionListener = "connectActionListener"
  }
  
  static func onObjectDeinit(forObject object: NSObject,
                                  connectionType: ConnectionType,
                                  callbackId: String,
                                  callback: @escaping () -> ()) {
    let key = "Suas-DeinitCallback\(callbackId)-REMOVABLE-OBJECT-ON-COMPONENT-\(connectionType.rawValue)"
    let rem = DeinitCallback(callback: callback)
    objc_setAssociatedObject(object, key, rem, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
  }
}

fileprivate class DeinitCallback: NSObject {
  private let callback: () -> ()
  
  init(callback: @escaping () -> ()) {
    self.callback = callback
  }
  
  deinit {
    callback()
  }
}
