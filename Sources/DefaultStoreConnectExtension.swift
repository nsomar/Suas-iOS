//
//  DefaultStoreConnectExtension.swift
//  SuasIOS
//
//  Created by Omar Abdelhafith on 20/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation

// MARK: Registartion

extension Store {
  
  enum ConnectionType: String {
    case listener = "connectListener"
    case actionListener = "connectActionListener"
  }
  
  func onObjectDeinit(forObject object: NSObject,
                                  connectionType: ConnectionType,
                                  callbackId: String,
                                  callback: @escaping () -> ()) {
    let key = "Suas-DeinitCallback-REMOVABLE-OBJECT-ON-COMPONENT-\(connectionType.rawValue)"
    let rem = DeinitCallback(callback: callback)
    objc_setAssociatedObject(object, key, rem, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
  }
}

// MARK: Un Registration

extension Store {
  
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

public struct Subscription<StateType> {
  let store: Store
  let listener: Listener

  public func removeListener() {
    store.removeListener(withId: listener.id)
  }

  public func notifyCurrentState() {
    var stateToNotify: Any!

    if let key = listener.stateKey {

      // If there is a key, Get the state for it and covert it
      guard let state = store.state.value(forKey: key, ofType: StateType.self) else {
        return
      }
      stateToNotify = state
    } else {

      // Else get the whole state
      stateToNotify = store.state
    }

    listener.notify(stateToNotify)
  }
}

public struct ActionSubscription {
  let store: Store
  let listenerID: CallbackId

  public func removeListener() {
    store.removeActionListener(withId: listenerID)
  }
}
