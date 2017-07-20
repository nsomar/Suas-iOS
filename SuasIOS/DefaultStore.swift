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

    let reduce: ReducerFunction = { action, state in
      // Calls the any reducer. In that reducer we typecheck
      return reducer.reduce(action: action, state: state)
    }

    return Suas.DefaultStore(
      state: state,
      reducer: reduce,
      middleware: middleware)
  }
  
  class DefaultStore: Store {
    
    var state: StoreState
    var reducer: ReducerFunction
    fileprivate var listeners: [Listener]
    fileprivate var actionListeners: [CallbackId: ActionListenerFunction]
    fileprivate var dispatchingFunction: DispatchFunction?
    
    init(state: StoreState,
         reducer: @escaping ReducerFunction,
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

  func resetFullState(_ state: KeyedState) {
    self.state = StoreState(dictionary: state)
  }
}

extension Suas.DefaultStore {
  
  fileprivate func getState() -> StoreState {
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

    // Inform the action listeners
    actionListeners.forEach({ $0.value(action) })

    listeners.forEach { listener in
      listener.notificationBlock(
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
  
  func addListener<State>(withId id: CallbackId,
                          type: State.Type,
                          callback: @escaping (State) -> ()) {
    
    performAddListener(withId: id, stateKey: "\(type)", type: type, callback: callback)
  }

  func addListener<State>(withId id: CallbackId,
                          type: State.Type,
                          notifier: @escaping ListenerNotifier<State>,
                          callback: @escaping (State) -> ()) {

    performAddListener(withId: id, stateKey: "\(type)", type: type,
                       notifier: notifier, callback: callback)
  }
  
  func addListener<State>(withId id: CallbackId,
                          stateKey: StateKey,
                          callback: @escaping (State) -> ()) {
    
    performAddListener(withId: id, stateKey: stateKey, type: State.self, callback: callback)
  }

  func addListener<State>(withId id: CallbackId,
                          stateKey: StateKey,
                          notifier: @escaping ListenerNotifier<State>,
                          callback: @escaping (State) -> ()) {

    performAddListener(withId: id, stateKey: stateKey, type: State.self,
                       notifier: notifier, callback: callback)
  }
  
  func addListener(withId id: CallbackId, callback: @escaping (StoreState) -> ()) {
    performAddListener(withId: id, stateKey: nil, type: StoreState.self, callback: callback)
  }

  func addListener(withId id: CallbackId,
                   notifier: @escaping ListenerNotifier<StoreState>,
                   callback: @escaping (StoreState) -> ()) {
    performAddListener(withId: id, stateKey: nil, type: StoreState.self, notifier: notifier, callback: callback)
  }
  
  func addListener<State>(withId id: CallbackId, stateKey: StateKey,
                          type: State.Type, callback: @escaping (State) -> ()) {
    performAddListener(withId: id, stateKey: stateKey, type: type, callback: callback)
  }

  func addListener<State>(withId id: CallbackId, stateKey: StateKey,
                          type: State.Type,
                          notifier: @escaping ListenerNotifier<State>,
                          callback: @escaping (State) -> ()) {
    performAddListener(withId: id, stateKey: stateKey, type: type, notifier: notifier, callback: callback)
  }

  func performAddListener<State, ListenerType>(withId id: CallbackId,
                                               stateKey: StateKey?,
                                               type: State.Type,
                                               notifier: ListenerNotifier<State>? = nil,
                                               callback: @escaping (ListenerType) -> ()) {

    var currentNotifier: ListenerNotifier<Any> = alwaysNotifier

    if let notifier = notifier {
      currentNotifier = { (new: Any, old: Any, listener: Listener) -> () in
        guard let castNew = new as? State, let castOld = old as? State else {
          Suas.log("Either new value or old value cannot be converted to type \(State.self)\nnew value: \(new)\nold value: \(old)")
          return
        }

        notifier(castNew, castOld, listener)
      }
    }

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
      notificationBlock: currentNotifier)

    listeners = listeners + [listener]
  }
  
  func removeListener(withId id: CallbackId)  {
    listeners = listeners.filter { $0.id != id }
  }
}

// Action listeners
extension Suas.DefaultStore {
  func addActionListener(withId id: CallbackId,
                         listener: @escaping ActionListenerFunction) {

    actionListeners[id] = listener
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
