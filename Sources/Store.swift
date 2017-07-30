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
/// - **state**: represents the application state. This state is partitioned into state keys. Each key can represents a full application screen, flow, component, or view controller.
/// - **reducer** represents the logic to update the state. A reducer mainly provides a function that updates the state for a paticular action.
/// - **middleware**: an object (or list of objects) that intercept an action and can enrich or alter it before finally dispatching it to the reducer.
/// - **listener**: a function that gets called when a state is changed.
public protocol Store {
  
  /// Get the store state
  var state: StoreState { get }
  
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
  
  
  /// Reset the store internal state for a specific component
  ///
  /// - Parameters:
  ///   - state: the new state to set
  ///   - component: the component to reset state for
  func reset<S, C: Component>(state: S, forComponent component: C) where C.StateType == S
  
  
  /// Resets the full internal state with a new state
  ///
  /// - Parameter state: the state to reset to
  func resetFullState(_ state: KeyedState)
  
  
  /// Dispatches an action to the store
  ///
  /// - Parameter action: the action to dispatch
  func dispatch(action: Action)
  
  
  /// Connects a component to the store
  ///
  /// - Parameter component: the component to connect
  func connect<C: Component>(component: C)
  
  
  /// Connects a component to the store
  ///
  /// - Parameter:
  ///   - component: the component to connect
  ///   - filterBlock: block to decide wheter to notify or not
  func connect<C: Component>(component: C,
                             if filterBlock: @escaping FilterFunction<C.StateType>)
  
  
  /// Connects a component to the store
  ///
  /// - Parameters:
  ///   - Parameter component: the component to connect
  ///   - stateKey: the state key to connect to in the state
  func connect<C: Component>(component: C, stateKey: StateKey)
  
  
  /// Connects a component to the store
  ///
  /// - Parameter:
  ///   - component: the component to connect
  ///   - filterBlock: block to decide wheter to notify or not
  func connect<C: Component>(component: C, stateKey: StateKey,
                             if filterBlock: @escaping FilterFunction<C.StateType>)
  
  
  /// Connects a component to the store
  ///
  /// - Parameters:
  ///   - component: the component to connect
  ///   - stateConverter: a converter that converts the `StoreState` to the actual type used by the component
  func connect<C: Component>(component: C,
                             stateConverter: @escaping StateConverter<C.StateType>)
  
  
  /// Connects an action listener to a component. Only 1 action listner can be connected for a Component
  ///
  /// - Parameters:
  ///   - component: the component to connects it to
  ///   - listener: the action listner to connect
  func connectActionListener<C: Component>(toComponent component: C,
                                           actionListener: @escaping ActionListenerFunction)
  
  
  /// Disonnects a component from the store
  ///
  /// - Parameter component: the component to disconnect
  func disconnect<C: Component>(component: C)
  
  
  /// Disconnect an action listener that was added for component
  ///
  /// - Parameter component: component to disconnect
  func disconnectActionListener<C: Component>(forComponent component: C)
  
  
  /// Add a new listner to the store
  ///
  /// - Parameters:
  ///   - id: the listener id to be used when removing the listener
  ///   - callback: callback to be notified when state changed
  func addListener(withId id: CallbackId, callback: @escaping (StoreState) -> ())
  
  
  /// Add a new listner to the store
  ///
  /// - Parameters:
  ///   - id: the listener id to be used when removing the listener
  ///   - stateKey: the state key to listen for changes
  ///   - callback: callback to be notified when state changed
  func addListener<State>(withId id: CallbackId, stateKey: StateKey,
                          callback: @escaping (State) -> ())
  
  
  /// Add a new listner to the store
  ///
  /// - Parameters:
  ///   - id: the listener id to be used when removing the listener
  ///   - stateKey: the state key to listen for changes
  ///   - filterBlock: block to decide wheter to notify or not
  ///   - callback: callback to be notified when state changed
  func addListener<State>(withId id: CallbackId, stateKey: StateKey,
                          if filterBlock: @escaping FilterFunction<State>,
                          callback: @escaping (State) -> ())
  
  
  /// Add a new listner to the store
  ///
  /// - Parameters:
  ///   - id: the listener id to be used when removing the listener
  ///   - filterBlock: block to decide wheter to notify or not
  ///   - callback: callback to be notified when state changed
  func addListener(withId id: CallbackId,
                   if filterBlock: @escaping FilterFunction<StoreState>,
                   callback: @escaping (StoreState) -> ())
  
  
  /// Add a new listner to the store
  ///
  /// - Parameters:
  ///   - id: the listener id to be used when removing the listener
  ///   - type: the type of the state callback
  ///   - callback: callback to be notified when state changed
  func addListener<State>(withId id: CallbackId, type: State.Type,
                          callback: @escaping (State) -> ())
  
  
  /// Add a new listner to the store
  ///
  /// - Parameters:
  ///   - id: the listener id to be used when removing the listener
  ///   - type: the type of the state callback
  ///   - filterBlock: block to decide wheter to notify or not
  ///   - callback: callback to be notified when state changed
  func addListener<State>(withId id: CallbackId, type: State.Type,
                          if filterBlock: @escaping FilterFunction<State>,
                          callback: @escaping (State) -> ())
  
  
  /// Add a new listner to the store
  ///
  /// - Parameters:
  ///   - id: the listener id to be used when removing the listener
  ///   - stateKey: the state key to listen for changes
  ///   - type: the type of the state callback
  ///   - callback: callback to be notified when state changed
  func addListener<State>(withId id: CallbackId, stateKey: StateKey,
                          type: State.Type, callback: @escaping (State) -> ())
  
  
  /// Add a new listner to the store
  ///
  /// - Parameters:
  ///   - id: the listener id to be used when removing the listener
  ///   - stateKey: the state key to listen for changes
  ///   - type: the type of the state callback
  ///   - filterBlock: block to decide wheter to notify or not
  ///   - callback: callback to be notified when state changed
  func addListener<State>(withId id: CallbackId, stateKey: StateKey,
                          type: State.Type,
                          if filterBlock: @escaping FilterFunction<State>,
                          callback: @escaping (State) -> ())
  
  
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
                                             state: StoreState,
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
  public static func createStore<R: Reducer, S>(reducer: R,
                                                state: S,
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
                       state: StoreState(dictionary: reducer.stateDict),
                       middleware: middleware)
  }
}
