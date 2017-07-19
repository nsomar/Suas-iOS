//
//  DefaultStore.swift
//  ReDucks
//
//  Created by Omar Abdelhafith on 18/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation

enum Suas {
  static func performCreateStore(reducer: Reducer,
                                 state: StoreState,
                                 middleware: Middleware?,
                                 notifier: ListenerNotifier?) -> Store {
    return Suas.DefaultStore(
      state: state,
      reducer: reducer.reduce,
      notifier: notifier,
      middleware: middleware,
      observers: [])
  }
  
  fileprivate class DefaultStore: Store {
    
    fileprivate var state: StoreState
    fileprivate var reducer: ReducerFunction
    fileprivate var notifier: ListenerNotifier?
    fileprivate var listeners: [Listener]
    fileprivate var dispatchingFunction: DispatchFunction?
    
    init(state: StoreState,
         reducer: @escaping ReducerFunction,
         notifier: ListenerNotifier?,
         middleware: Middleware?,
         observers: [Listener]) {
      
      self.state = state
      self.reducer = reducer
      self.listeners = observers
      self.dispatchingFunction = nil
      self.notifier = notifier ?? alwaysNotifier
      
      if let middleware = middleware {
        middleware.api = MiddlewareAPI(dispatch: self.dispatch, getState: self.getState)
        self.dispatchingFunction = middleware.onAction
        middleware.next = performDispatch
      } else {
        self.dispatchingFunction = self.performDispatch
      }
    }
  }
}


// MARK: Initialization and Reduce registration

extension Suas.DefaultStore {
  fileprivate func reset(state: Any) {
    reset(state: state, forKey: "\(type(of: state))")
  }
  
  fileprivate func reset(state: Any, forKey key: StateKey) {
    self.state = [key: state]
  }
}

extension Suas.DefaultStore {
  
  fileprivate func getState() -> Any {
    return self.state
  }
  
  func dispatch(action: Action) {
    self.dispatchingFunction?(action)
  }
  
  fileprivate func performDispatch(action: Action) {
    let oldState = state
    
    if let key = state.keys.first, state.keys.count == 1 {
      let newState = reducer(action, state[key]!)
      state = [key: newState]
    } else {
      state = reducer(action, state) as! StoreState
    }
    
    listeners.forEach { listener in
      self.notifier?(
        getSubstate(withState: state, forKey: listener.stateKey),
        getSubstate(withState: oldState, forKey: listener.stateKey),
        listener
      )
    }
  }
  
  private func getSubstate(withState state: StoreState, forKey key: StateKey?) -> Any {
    if let key = key {
      return state[key] ?? state
    } else {
      return state
    }
  }
}

// MARK: Adding and removing observers and middlewares

extension Suas.DefaultStore {
  
  fileprivate func addListener<State>(withId id: CallbackId,
                                      type: State.Type,
                                      callback: @escaping (State) -> ()) {
    
    performAddListener(withId: id, stateKey: "\(type)", type: type, callback: callback)
  }
  
  fileprivate func addListener<State>(withId id: CallbackId,
                                      stateKey: StateKey,
                                      callback: @escaping (State) -> ()) {
    
    performAddListener(withId: id, stateKey: stateKey, type: State.self, callback: callback)
  }
  
  fileprivate func addListener(withId id: CallbackId, callback: @escaping (Any) -> ()) {
    performAddListener(withId: id, stateKey: nil, type: Any.self, callback: callback)
  }
  
  fileprivate func addListener<State>(withId id: CallbackId, stateKey: StateKey, type: State.Type, callback: @escaping (State) -> ()) {
    performAddListener(withId: id, stateKey: stateKey, type: type, callback: callback)
  }
  
  fileprivate func performAddListener<State>(withId id: CallbackId,
                                             stateKey: StateKey?,
                                             type: State.Type,
                                             callback: @escaping (State) -> ()) {
    
    let observer = { (state: Any) in
      guard let state = state as? State else { return }
      callback(state)
    }
    listeners = listeners + [Listener(id: id, stateKey: stateKey, listener: observer)]
  }
  
  fileprivate func removeListener(withId id: CallbackId)  {
    listeners = listeners.filter { $0.id != id }
  }
}


// MARK: Registartion

extension Suas.DefaultStore {
  
  fileprivate func connect<C: Component>(component: C) {
    connect(component: component, forStateKey: "\(C.StateType.self)")
  }
  
  fileprivate func connect<C: Component>(component: C, forStateKey stateKey: StateKey) {
    let callbackId = getId(forAny: component)
    
    addListener(
      withId: callbackId,
      stateKey: stateKey,
      type: C.StateType.self) { [weak component] newState in
        component?.setIfChanged(newState)
    }
    
    onObjectDeinit(forComponent: component,
                   callbackId: callbackId) { self.removeListener(withId: callbackId) }
  }
  
  fileprivate func connect<C: Component>(component: C, stateConverter: StateConverter<C.StateType>) {
    let callbackId = getId(forAny: component)
    
    addListener(
      withId: callbackId,
      type: StoreState.self) { newState in
        component.setIfChanged(stateConverter.convert(newState))
    }
    
    onObjectDeinit(forComponent: component,
                   callbackId: callbackId) { self.removeListener(withId: callbackId) }
  }
  
  fileprivate func connect<C: Component>(component: C, forStateKey stateKey: StateKey, withListener listener: @escaping ListenerFunction) {
    let callbackId = getId(forAny: component)
    
    addListener(
      withId: callbackId,
      stateKey: stateKey,
      type: C.StateType.self) { newState in
        listener(newState)
    }
    
    onObjectDeinit(forComponent: component,
                   callbackId: callbackId) { self.removeListener(withId: callbackId) }
  }
  
  private func onObjectDeinit(forComponent component: Any, callbackId: String, callback: @escaping () -> ()) {
    if let object = component as? NSObject {
      let rem = DeinitCallback(callback: callback)
      
      objc_setAssociatedObject(object, "removebale", rem, .OBJC_ASSOCIATION_RETAIN)
    }
  }
}


// MARK: Un Registration

extension Suas.DefaultStore {

  fileprivate func disconnect<C: Component>(component: C) {
    removeListener(withId: getId(forAny: component))
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

