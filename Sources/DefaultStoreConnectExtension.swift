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
  
  func connect<C: Component>(component: C) {
    performConnect(component: component,
                   stateKey: "\(C.StateType.self)",
      if: nil,
      listener: { [weak component] newState in
        component?.state = newState
    })
    
    setInitialData(component: component)
  }
  
  func connect<C>(
    component: C,
    if filterBlock: @escaping FilterFunction<C.StateType>)
    where C : Component {
      
      performConnect(component: component,
                     stateKey: "\(C.StateType.self)",
        if: filterBlock,
        listener: { [weak component] newState in
          component?.state = newState
      })
      
      setInitialData(component: component)
  }
  
  func connect<C: Component>(component: C,
                             stateKey: StateKey) {
    
    performConnect(component: component,
                   stateKey: stateKey,
                   if: nil,
                   listener: { [weak component] newState in
                    component?.state = newState
    })
    
    setInitialData(component: component)
  }
  
  func connect<C>(
    component: C,
    stateKey: StateKey,
    if filterBlock: @escaping FilterFunction<C.StateType>)
    where C : Component {
      
      performConnect(component: component,
                     stateKey: stateKey,
                     if: filterBlock,
                     listener: { [weak component] newState in
                      component?.state = newState
      })
      
      setInitialData(component: component)
  }
  
  func connect<C: Component>(
    component: C,
    stateConverter: StateConverter<StoreState, C.StateType>) {
    
    performConnect(component: component,
                   forStateKey: nil,
                   withStateConverter: stateConverter)
    
    setInitialData(component: component)
  }
  
  func connect<C, ExpectedType>(
    component: C,
    stateKey: StateKey,
    stateConverter: StateConverter<ExpectedType, C.StateType>)
    where C : Component {
      
      performConnect(component: component,
                     forStateKey: stateKey,
                     withStateConverter: stateConverter)
      
      setInitialData(component: component)
  }
  
  private func setInitialData<C: Component>(component: C) {
    if let componentState = state["\(C.StateType.self)"] as? C.StateType {
      component.state = componentState
    }
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
                                           actionListener: @escaping ActionListenerFunction) {
    let callbackId = getId(forAny: component)
    
    addActionListener(withId: callbackId, actionListener: actionListener)
    
    onObjectDeinit(forComponent: component,
                   connectionType: .actionListener,
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
    if filterBlock: FilterFunction<C.StateType>?,
    listener: @escaping (ListenerType) -> Void)
    where C : Component {
      
      let callbackId = getId(forAny: component)
      
      performAddListener(
        withId: callbackId,
        stateKey: stateKey,
        type: C.StateType.self,
        if: filterBlock) { newState in
          listener(newState)
      }
      
      onObjectDeinit(forComponent: component,
                     connectionType: .listener,
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
          component?.state = convertedValue
      }
      
      onObjectDeinit(forComponent: component,
                     connectionType: .listener,
                     callbackId: callbackId) { self.removeListener(withId: callbackId) }
  }
}
