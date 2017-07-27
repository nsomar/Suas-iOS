//
//  DefaultStore.swift
//  ReDucks
//
//  Created by Omar Abdelhafith on 18/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation


public enum Suas {
  static func performCreateStore<R: Reducer>(reducer: R,
                                             state: StoreState,
                                             middleware: Middleware?) -> Store {
    
    let reduce: ReducerFunction<Any> = { action, state in
      guard let newState = state as? R.StateType else {
        Suas.log("When reducing state of type \(type(of: state)) was not convertible to \(R.StateType.self)\nstate: \(state)")
        return state
      }
      // Calls the any reducer. In that reducer we typecheck
      return reducer.reduce(action: action, state: newState)
    }
    
    return Suas.DefaultStore(
      state: state,
      reducer: reduce,
      middleware: middleware)
  }
  
  class DefaultStore: Store {
    
    var state: StoreState
    var reducer: ReducerFunction<Any>
    fileprivate var listeners: [Listener]
    fileprivate var actionListeners: [CallbackId: ActionListenerFunction]
    fileprivate var dispatchingFunction: DispatchFunction?
    
    init(state: StoreState,
         reducer: @escaping ReducerFunction<Any>,
         middleware: Middleware?) {
      
      self.state = state
      self.reducer = reducer
      self.listeners = []
      self.actionListeners = [:]
      self.dispatchingFunction = nil
      
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
  
  func reset(state: Any) {
    reset(state: state, forKey: "\(type(of: state))")
  }
  
  func reset(state: Any, forKey key: StateKey) {
    self.state[key] = state
  }
  
  func reset<S, C: Component>(state: S, forComponent component: C) where C.StateType == S {
    reset(state: state, forKey: "\(type(of: state))")
  }
  
  func resetFullState(_ state: KeyedState) {
    self.state = StoreState(dictionary: state)
  }
}

extension Suas.DefaultStore {
  
  fileprivate func getState() -> StoreState {
    return self.state
  }
  
  func dispatch(action: Action) {
    let toDispatch = {
      // Inform the action listeners
      self.actionListeners.forEach({ $0.value(action) })
      
      self.dispatchingFunction?(action)
    }
    
    if Thread.isMainThread {
      toDispatch()
    } else {
      DispatchQueue.main.sync { toDispatch() }
    }
  }
  
  fileprivate func performDispatch(action: Action) {
    let oldState = state
    
    var stateKeysChanged: Set<StateKey> = Set()
    
    if state.keys.count == 1, let key = state.keys.first {
      
      // The store has a single reducer
      if let subState = state[key], let newSubState = reducer(action, subState) {
        // State was changed for key
        state[key] = newSubState
        stateKeysChanged.insert(key)
      }
    } else {
      
      // The store has a combine reducer
      if let (newState, keysChanged) = reducer(action, state) as? (StoreState, [StateKey]) {
        // State was changed for key
        state = newState
        keysChanged.forEach({ stateKeysChanged.insert($0) })
      }
    }
    
    for listener in listeners {
      
      if let key = listener.stateKey,
        stateKeysChanged.contains(key) == false {
        // If the listener has a key, and the key is not in the `stateKeysChanged` then dont inform the listner
        continue
      }
      
      guard
        let oldSubState = getSubstate(withState: oldState, forKey: listener.stateKey),
        let newSubState = getSubstate(withState: state, forKey: listener.stateKey) else { return }
      
      if listener.filterBlock(oldSubState, newSubState) {
        listener.notify(newSubState)
      }
    }
  }
  
  private func getSubstate(withState state: StoreState, forKey key: StateKey?) -> Any? {
    if let key = key {
      return state[key] ?? state
    } else {
      return state
    }
  }
}

// MARK: Adding and removing observers and middlewares

extension Suas.DefaultStore {
  
  func addListener<State>(withId id: CallbackId,
                          type: State.Type,
                          callback: @escaping (State) -> ()) {
    
    performAddListener(withId: id, stateKey: "\(type)", type: type, callback: callback)
  }
  
  func addListener<State>(withId id: CallbackId,
                          type: State.Type,
                          if filterBlock: @escaping FilterFunction<State>,
                          callback: @escaping (State) -> ()) {
    
    performAddListener(withId: id, stateKey: "\(type)", type: type,
                       if: filterBlock, callback: callback)
  }
  
  func addListener<State>(withId id: CallbackId,
                          stateKey: StateKey,
                          callback: @escaping (State) -> ()) {
    
    performAddListener(withId: id, stateKey: stateKey, type: State.self, callback: callback)
  }
  
  func addListener<State>(withId id: CallbackId,
                          stateKey: StateKey,
                          if filterBlock: @escaping FilterFunction<State>,
                          callback: @escaping (State) -> ()) {
    
    performAddListener(withId: id, stateKey: stateKey, type: State.self,
                       if: filterBlock, callback: callback)
  }
  
  func addListener(withId id: CallbackId, callback: @escaping (StoreState) -> ()) {
    performAddListener(withId: id, stateKey: nil, type: StoreState.self, callback: callback)
  }
  
  func addListener(withId id: CallbackId,
                   if filterBlock: @escaping FilterFunction<StoreState>,
                   callback: @escaping (StoreState) -> ()) {
    performAddListener(withId: id, stateKey: nil, type: StoreState.self, if: filterBlock, callback: callback)
  }
  
  func addListener<State>(withId id: CallbackId, stateKey: StateKey,
                          type: State.Type, callback: @escaping (State) -> ()) {
    performAddListener(withId: id, stateKey: stateKey, type: type, callback: callback)
  }
  
  func addListener<State>(withId id: CallbackId, stateKey: StateKey,
                          type: State.Type,
                          if filterBlock: @escaping FilterFunction<State>,
                          callback: @escaping (State) -> ()) {
    performAddListener(withId: id, stateKey: stateKey, type: type, if: filterBlock, callback: callback)
  }
  
  func performAddListener<State, ListenerType>(withId id: CallbackId,
                                               stateKey: StateKey?,
                                               type: State.Type,
                                               if filterBlock: FilterFunction<State>? = nil,
                                               callback: @escaping (ListenerType) -> ()) {
    
    var currentNotificationFilter: FilterFunction<Any> = alwaysFilter
    
    if let filterBlock = filterBlock {
      // If we have a notification filter, wrap it in a type erasure closure
      currentNotificationFilter = { (old: Any, new: Any) -> Bool in
        // Dynamic typechecking :(
        guard let castNew = new as? State, let castOld = old as? State else {
          Suas.log("Either new value or old value cannot be converted to type \(State.self)\nnew value: \(new)\nold value: \(old)")
          return false
        }
        
        return filterBlock(castOld, castNew)
      }
    }
    
    // Create a type erased infom callback
    let typeErasedCallback = { (state: Any) in
      guard let castState = state as? ListenerType else {
        Suas.log("State cannot be converted to type \(State.self)\nstate: \(state)")
        return
      }
      
      callback(castState)
    }
    
    let listener = Listener(
      id: id,
      stateKey: stateKey,
      notify: typeErasedCallback,
      filterBlock: currentNotificationFilter)
    
    listeners = listeners + [listener]
  }
  
  func removeListener(withId id: CallbackId)  {
    listeners = listeners.filter { $0.id != id }
  }
}

// Action listeners
extension Suas.DefaultStore {
  func addActionListener(withId id: CallbackId,
                         actionListener: @escaping ActionListenerFunction) {
    
    actionListeners[id] = actionListener
  }
  
  func removeActionListener(withId id: CallbackId)  {
    actionListeners.removeValue(forKey: id)
  }
  
}

extension Suas {
  static func allListeners(inStore store: Store) -> [Listener] {
    return (store as! DefaultStore).listeners
  }
  
  static func allActionListeners(inStore store: Store) -> [Any] {
    return Array((store as! DefaultStore).actionListeners.keys)
  }
}

