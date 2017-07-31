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
public protocol Store {
  
  /// Get the store state
  var state: State { get }
  
  /// Reset the store internal state for a particular key. They key will be the dynamic type of state
  ///
  /// - Parameter state: the new state
  func reset(state: Any)
  
  
  /// Reset the store internal state for a specific key
  ///
  /// - Parameters:
  ///   - state: the new state
  ///   - key: the state key to set
  func reset(state: Any, forKey key: StateKey)
  
  
  /// Resets the full internal state with a new state
  ///
  /// - Parameter state: the state to reset to
  func resetFullState(_ state: KeyedState)
  
  
  /// Dispatches an action to the store
  ///
  /// - Parameter action: the action to dispatch
  func dispatch(action: Action)
  
  
  /// Add a new listner to the store
  ///
  /// - Parameters:
  ///   - id: the listener id to be used when removing the listener
  ///   - callback: callback to be notified when state changed
  func addListener(withId id: CallbackId, callback: @escaping (State) -> ())
  
  
  /// Add a new listner to the store
  ///
  /// - Parameters:
  ///   - id: the listener id to be used when removing the listener
  ///   - callback: callback to be notified when state changed
  func addListener<StateType>(withId id: CallbackId,
                              stateConverter: @escaping StateConverter<StateType>,
                              callback: @escaping (StateType) -> ())
  
  
  /// Add a new listner to the store
  ///
  /// - Parameters:
  ///   - id: the listener id to be used when removing the listener
  ///   - filterBlock: block to decide wheter to notify or not
  ///   - callback: callback to be notified when state changed
  func addListener(withId id: CallbackId,
                   if filterBlock: @escaping FilterFunction<State>,
                   callback: @escaping (State) -> ())
  
  
  /// Add a new listner to the store
  ///
  /// - Parameters:
  ///   - id: the listener id to be used when removing the listener
  ///   - type: the type of the state callback
  ///   - callback: callback to be notified when state changed
  func addListener<StateType>(withId id: CallbackId, type: StateType.Type,
                              callback: @escaping (StateType) -> ())
  
  
  /// Add a new listner to the store
  ///
  /// - Parameters:
  ///   - id: the listener id to be used when removing the listener
  ///   - type: the type of the state callback
  ///   - filterBlock: block to decide wheter to notify or not
  ///   - callback: callback to be notified when state changed
  func addListener<StateType>(withId id: CallbackId, type: StateType.Type,
                              if filterBlock: @escaping FilterFunction<StateType>,
                              callback: @escaping (StateType) -> ())
  
  
  /// Add a new listner to the store
  ///
  /// - Parameters:
  ///   - id: the listener id to be used when removing the listener
  ///   - stateKey: the state key to listen for changes
  ///   - type: the type of the state callback
  ///   - callback: callback to be notified when state changed
  func addListener<StateType>(withId id: CallbackId, stateKey: StateKey,
                              type: StateType.Type, callback: @escaping (StateType) -> ())
  
  
  /// Add a new listner to the store
  ///
  /// - Parameters:
  ///   - id: the listener id to be used when removing the listener
  ///   - stateKey: the state key to listen for changes
  ///   - type: the type of the state callback
  ///   - filterBlock: block to decide wheter to notify or not
  ///   - callback: callback to be notified when state changed
  func addListener<StateType>(withId id: CallbackId, stateKey: StateKey,
                              type: StateType.Type,
                              if filterBlock: @escaping FilterFunction<StateType>,
                              callback: @escaping (StateType) -> ())
  
  
  /// Remove a listener from the store
  ///
  /// - Parameter id: the listener id to remove
  func removeListener(withId id: CallbackId)
  
  
  /// Add a new action listner to the store
  ///
  /// - Parameters:
  ///   - id: the action listener id to be used when removing the listener
  ///   - callback: callback to be notified when an action happens
  func addActionListener(withId id: CallbackId,
                         actionListener: @escaping ActionListenerFunction)
  
  
  /// Remove an action listener from the store
  ///
  /// - Parameter id: the action listener id to remove
  func removeActionListener(withId id: CallbackId)
}


extension Suas {
  
  
  /// Create a store
  ///
  /// - Parameters:
  ///   - reducer: the reducer to use with the store. The reducer will be called when calling dispatch on this store
  ///   - state: the initial state to use for this store
  ///   - middleware: the store middleware
  /// - Returns: a new store
  ///
  /// -----
  /// **Example**
  ///
  /// Using a single reducer
  ///
  /// ```
  /// let store = Suas.createStore(
  ///   reducer: MyReducer()
  /// )
  /// ```
  ///
  /// Using a single reducer and some initial state
  ///
  /// ```
  /// let store = Suas.createStore(
  ///   reducer: MyReducer(),
  ///   state: ["MyReducerState": MyReducerState(val: 20)]
  /// )
  /// ```
  ///
  /// ```
  /// let store = Suas.createStore(
  ///   reducer: MyReducer(),
  ///   state: MyReducerState(val: 20)
  /// )
  /// ```
  ///
  ///
  /// Using a combination of reducers
  ///
  /// ```
  /// let store = Suas.createStore(
  ///   reducer: MyReducer() |> MyOtherReducer()
  /// )
  /// ```
  public static func createStore<R: Reducer>(reducer: R,
                                             state: State,
                                             middleware: Middleware? = nil) -> Store {
    return performCreateStore(
      reducer: reducer,
      state: state,
      middleware: middleware)
  }
  
  
  /// Create a store
  ///
  /// - Parameters:
  ///   - reducer: the reducer to use with the store. The reducer will be called when calling dispatch on this store
  ///   - state: the initial state to use for this store. The state type must be equal to the reducer `StateType`
  ///   - middleware: the store middleware
  /// - Returns: a new store
  ///
  /// -----
  /// **Example**
  ///
  /// Using a single reducer
  ///
  /// ```
  /// let store = Suas.createStore(
  ///   reducer: MyReducer()
  /// )
  /// ```
  ///
  /// Using a single reducer and some initial state
  ///
  /// ```
  /// let store = Suas.createStore(
  ///   reducer: MyReducer(),
  ///   state: ["MyReducerState": MyReducerState(val: 20)]
  /// )
  /// ```
  ///
  /// ```
  /// let store = Suas.createStore(
  ///   reducer: MyReducer(),
  ///   state: MyReducerState(val: 20)
  /// )
  /// ```
  ///
  ///
  /// Using a combination of reducers
  ///
  /// ```
  /// let store = Suas.createStore(
  ///   reducer: MyReducer() |> MyOtherReducer()
  /// )
  /// ```
  public static func createStore<R: Reducer, StateType>(reducer: R,
                                                        state: StateType,
                                                        middleware: Middleware? = nil) -> Store {
    return performCreateStore(
      reducer: reducer,
      state: ["\(type(of: state))": state],
      middleware: middleware)
  }
  
  
  /// Create a store.
  ///
  /// The state will be generated from calling `reducer.initialState`
  ///
  /// - Parameters:
  ///   - reducer: the reducer to use with the store. The reducer will be called when calling dispatch on this store
  ///   - middleware: the store middleware
  /// - Returns: a new store
  ///
  /// -----
  /// **Example**
  ///
  /// Using a single reducer
  ///
  /// ```
  /// let store = Suas.createStore(
  ///   reducer: MyReducer()
  /// )
  /// ```
  ///
  /// Using a single reducer and some initial state
  ///
  /// ```
  /// let store = Suas.createStore(
  ///   reducer: MyReducer(),
  ///   state: ["MyReducerState": MyReducerState(val: 20)]
  /// )
  /// ```
  ///
  /// ```
  /// let store = Suas.createStore(
  ///   reducer: MyReducer(),
  ///   state: MyReducerState(val: 20)
  /// )
  /// ```
  ///
  ///
  /// Using a combination of reducers
  ///
  /// ```
  /// let store = Suas.createStore(
  ///   reducer: MyReducer() |> MyOtherReducer()
  /// )
  /// ```
  public static func createStore<R: Reducer>(reducer: R,
                                             middleware: Middleware? = nil) -> Store {
    return createStore(reducer: reducer,
                       state: State(dictionary: reducer.stateDict),
                       middleware: middleware)
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
