//
//  Store.swift
//  ReDucks
//
//  Created by Omar Abdelhafith on 17/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation


/// Store that contains the application single state, the reducer logic, the middleware and the listeners
///
/// The store contains four components
/// - **state**: represents the application state. This state is partitioned into state keys. Each key can represents a full application screen, flow, or view controller.
/// - **reducer** represents the logic to update the state. A reducer mainly provides a function that updates the state for a paticular action.
/// - **middleware**: an object (or list of objects) that intercept an action and can enrich or alter it before finally dispatching it to the reducer.
/// - **listener**: a function that gets called when a state is changed.
public class Store {
  
  /// Get the store state
  public var state: State

  var reducer: ReducerFunction<Any>
  var listeners: [Listener]
  var actionListeners: [CallbackId: ActionListenerFunction]
  var dispatchingFunction: DispatchFunction?
  var isDispatching = false

  init(state: State,
       reducer: @escaping ReducerFunction<Any>,
       middleware: Middleware?) {

    self.state = state
    self.reducer = reducer
    self.listeners = []
    self.actionListeners = [:]
    self.dispatchingFunction = nil

    if let middleware = middleware {

      self.dispatchingFunction = { [weak self] action in
        guard let sself = self else { return }

        middleware.onAction(
          action: action,
          getState: { sself.getState() }, // Capturing self
          dispatch: { [weak sself] action in sself?.dispatch(action: action) },
          next: { [weak sself] action in sself?.performDispatch(action: action) }
        )
      }
    } else {
      self.dispatchingFunction = self.performDispatch
    }
  }
}



/// Dispatch Store Extension
extension Store {
  /// Dispatches an action to the store
  ///
  /// - Parameter action: the action to dispatch
  public func dispatch(action: Action) {
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
}



/// Add Listener Store
extension Store {

  /// Add a new listner to the store
  ///
  /// - Parameters:
  ///   - id: the listener id to be used when removing the listener
  ///   - type: the type of the state callback
  ///   - callback: callback to be notified when state changed
  public func addListener<StateType>(forStateType type: StateType.Type,
                                     stateKey: StateKey? = nil,
                                     if filterBlock: FilterFunction<StateType>? = nil,
                                     callback: @escaping (StateType) -> ()) -> Subscription<StateType> {

    return performAddListener(stateKey: stateKey ?? "\(type)",
      type: type,
      if: filterBlock,
      callback: callback)
  }

  public func addListener<StateType: StateConvertible>(if filterBlock: FilterFunction<State>? = nil,
                                                       convertToStateType: StateType.Type,
                                                       callback: @escaping (StateType) -> ()) -> Subscription<State> {
    return performAddListener(stateKey: nil,
                              type: State.self,
                              if: filterBlock,
                              convertToStateType: StateType.self,
                              callback: callback)
  }

  public func addListener(if filterBlock: FilterFunction<State>? = nil,
                          callback: @escaping (State) -> ()) -> Subscription<State> {
    return performAddListener(stateKey: nil,
                              type: State.self,
                              if: filterBlock,
                              callback: callback)
  }

  /// Add a new action listner to the store
  ///
  /// - Parameters:
  ///   - id: the action listener id to be used when removing the listener
  ///   - callback: callback to be notified when an action happens
  public func addActionListener(actionListener: @escaping ActionListenerFunction) -> ActionSubscription {
    let id = generateId()
    actionListeners[id] = actionListener
    return ActionSubscription(store: self, listenerId: id)
  }
}



/// Resetting State
extension Store {

  /// Reset the store internal state for a particular key. They key will be the dynamic type of state
  ///
  /// - Parameter state: the new state
  public func reset(state: Any) {
    reset(state: state, forKey: "\(type(of: state))")
  }

  
  /// Reset the store internal state for a specific key
  ///
  /// - Parameters:
  ///   - state: the new state
  ///   - key: the state key to set
  public func reset(state: Any, forKey key: StateKey) {
    self.state[key] = state
  }


  /// Resets the full internal state with a new state
  ///
  /// - Parameter state: the state to reset to
  public func resetFullState(_ state: KeyedState) {
    self.state = State(dictionary: state)
  }
}

/// Action that is to be dispatched to the store
///
/// -----
/// **Example**
///
/// ```
/// struct ButtonTappedAction: Action { }
///
/// store.dispatch(action: ButtonTappedAction())
/// ```
public protocol Action {}
