//
//  DefaultStoreConnectExtension.swift
//  SuasIOS
//
//  Created by Omar Abdelhafith on 20/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation

// MARK: Registartion

extension Suas.DefaultStore {
  
  enum ConnectionType: String {
    case listener = "connectListener"
    case actionListener = "connectActionListener"
  }
  
  fileprivate func onObjectDeinit(forComponent component: Any,
                                  connectionType: ConnectionType,
                                  callbackId: String,
                                  callback: @escaping () -> ()) {
    if component is NSObject {
      let key = "Suas-DeinitCallback-REMOVABLE-OBJECT-ON-COMPONENT-\(connectionType.rawValue)"
      let rem = DeinitCallback(callback: callback)
      objc_setAssociatedObject(component, key, rem, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
}

// MARK: Un Registration

extension Suas.DefaultStore {
  
  //  func disconnect<C: Component>(component: C) {
  //    removeListener(withId: getId(forAny: component))
  //    removeActionListener(withId: getId(forAny: component))
  //  }
  //
  //  fileprivate func getId(forAny any: Any) -> CallbackId {
  //    return "\(Unmanaged<AnyObject>.passUnretained(any as AnyObject).toOpaque())"
  //  }
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

//onObjectDeinit(forComponent: component,
//               connectionType: .listener,
//               callbackId: callbackId) { self.removeListener(withId: callbackId) }
