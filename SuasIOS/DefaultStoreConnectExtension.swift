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

  func connect<C: Component>(component: C) {
    performConnect(component: component,
                   stateKey: "\(C.StateType.self)",
      notifier: nil,
      listener: { [weak component] newState in
        component?.setIfChanged(newState)
    })
  }

  func connect<C>(
    component: C,
    notifier: @escaping ListenerNotifier<C.StateType>)
    where C : Component {

      performConnect(component: component,
                     stateKey: "\(C.StateType.self)",
        notifier: notifier,
        listener: { [weak component] newState in
          component?.setIfChanged(newState)
      })
  }

  func connect<C: Component>(component: C,
                             stateKey: StateKey) {

    performConnect(component: component,
                   stateKey: stateKey,
                   notifier: nil,
                   listener: { [weak component] newState in
                    component?.setIfChanged(newState)
    })
  }

  func connect<C>(
    component: C,
    stateKey: StateKey,
    notifier: @escaping ListenerNotifier<C.StateType>)
    where C : Component {

      performConnect(component: component,
                     stateKey: stateKey,
                     notifier: notifier,
                     listener: { [weak component] newState in
                      component?.setIfChanged(newState)
      })
  }

  func connect<C>(
    component: C,
    listener: @escaping (StoreState) -> Void)
    where C : Component {

      performConnect(component: component,
                     stateKey: nil,
                     notifier: nil,
                     listener: listener)
  }

  func connect<C: Component>(component: C,
                             stateKey: StateKey,
                             listener: @escaping ListenerFunction<C.StateType>) {
    performConnect(component: component,
                   stateKey: stateKey,
                   notifier: nil,
                   listener: listener)
  }

  func connect<C: Component>(
    component: C,
    stateConverter: StateConverter<StoreState, C.StateType>) {

    performConnect(component: component,
                   forStateKey: nil,
                   withStateConverter: stateConverter)
  }

  func connect<C, ExpectedType>(
    component: C,
    stateKey: StateKey,
    stateConverter: StateConverter<ExpectedType, C.StateType>)
    where C : Component {

      performConnect(component: component,
                     forStateKey: stateKey,
                     withStateConverter: stateConverter)
  }

  fileprivate func onObjectDeinit(forComponent component: Any, callbackId: String, callback: @escaping () -> ()) {
    if let object = component as? NSObject {
      let rem = DeinitCallback(callback: callback)

      objc_setAssociatedObject(object, "removebale", rem, .OBJC_ASSOCIATION_RETAIN)
    }
  }
}

// MARK: Un Registration

extension Suas.DefaultStore {

  func disconnect<C: Component>(component: C) {
    removeListener(withId: getId(forAny: component))
    removeActionListener(withId: getId(forAny: component))
  }

  fileprivate func getId(forAny any: Any) -> CallbackId {
    return "\(Unmanaged<AnyObject>.passUnretained(any as AnyObject).toOpaque())"
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

// Action listeners

extension Suas.DefaultStore {

  func connectActionListener<C: Component>(toComponent component: C,
                                           listener: @escaping ActionListenerFunction) {
    let callbackId = getId(forAny: component)

    addActionListener(withId: callbackId, listener: listener)

    onObjectDeinit(forComponent: component,
                   callbackId: callbackId) { self.removeActionListener(withId: callbackId) }
  }

  func disconnectActionListener<C: Component>(forComponent component: C) {
    let callbackId = getId(forAny: component)
    self.removeActionListener(withId: callbackId)
  }
}

// Internal
extension Suas.DefaultStore {

  fileprivate func performConnect<C, ListenerType>(
    component: C,
    stateKey: StateKey?,
    notifier: ((C.StateType, C.StateType, Listener) -> Void)?,
    listener: @escaping (ListenerType) -> Void)
    where C : Component {

      let callbackId = getId(forAny: component)

      performAddListener(
        withId: callbackId,
        stateKey: stateKey,
        type: C.StateType.self,
        notifier: notifier) { newState in
          listener(newState)
      }

      onObjectDeinit(forComponent: component,
                     callbackId: callbackId) { self.removeListener(withId: callbackId) }
  }

  fileprivate func performConnect<C, ExpectedType>(
    component: C,
    forStateKey stateKey: StateKey?,
    withStateConverter stateConverter: StateConverter<ExpectedType, C.StateType>)
    where C : Component {

      let callbackId = getId(forAny: component)

      performAddListener(
        withId: callbackId,
        stateKey: stateKey,
        type: ExpectedType.self) { [weak component] (newState: ExpectedType) in
          guard let convertedValue = stateConverter.convert(newState) else {
            Suas.log("State is not convertable to \(C.StateType.self)\n\(newState)")
            return
          }
          component?.setIfChanged(convertedValue)
      }

      onObjectDeinit(forComponent: component,
                     callbackId: callbackId) { self.removeListener(withId: callbackId) }
  }
}

