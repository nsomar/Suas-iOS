//
//  Store.swift
//  ReDucks
//
//  Created by Omar Abdelhafith on 17/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation


/// Store that contains the application single state, the reducer logic, the middleware and the notifier
///
/// The store contains four components
/// - **state**: represents the application state. This state is partitioned into state keys. Each key can represents a full application screen, flow, component, or view controller.
/// - **reducer** represents the logic to update the state. A reducer mainly provides a function that updates the state for a paticular action.
/// - **middleware**: an object (or list of objects) that intercept an action and can enrich or alter it before finally dispatching it to the reducer.
/// - **notifier**: an function that is responsible for notifying the list of listeners the store has. This function provides an extension point that can alter the way the notification to the listeners works.
public protocol Store {

  /// Reset the store internal state
  ///
  /// - Parameter state: the new state
  func reset(state: Any)


  /// Reset the store internal state for a specific key
  ///
  /// - Parameters:
  /// - Parameter state: the new state
  ///   - key: the state key to set
  func reset(state: Any, forKey key: StateKey)


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
  /// - Parameters:
  ///   - Parameter component: the component to connect
  ///   - stateKey: the state key to connect to in the state
  func connect<C: Component>(component: C, forStateKey stateKey: StateKey)


  /// Connects a component to the store
  ///
  /// - Parameters:
  ///   - component: the component to connect
  ///   - stateKey: the state key to connect to in the state
  ///   - listener: the listener to be notified when the state for the passed key changes
  func connect<C: Component>(component: C, forStateKey stateKey: StateKey,
                             withListener listener: @escaping ListenerFunction)


  /// Connects a component to the store
  ///
  /// - Parameters:
  ///   - component: the component to connect
  ///   - stateConverter: a converter that converts the `StoreState` to the actual type used by the component
  func connect<C: Component>(component: C, stateConverter: StateConverter<C.StateType>)


  /// Disonnects a component from the store
  ///
  /// - Parameter component: the component to disconnect
  func disconnect<C: Component>(component: C)


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
  ///   - callback: callback to be notified when state changed
  func addListener(withId id: CallbackId, callback: @escaping (Any) -> ())


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
  ///   - stateKey: the state key to listen for changes
  ///   - type: the type of the state callback
  ///   - callback: callback to be notified when state changed
  func addListener<State>(withId id: CallbackId, stateKey: StateKey,
                          type: State.Type, callback: @escaping (State) -> ())


  /// Remove a listener from the store
  ///
  /// - Parameter id: the listener id to remove
  func removeListener(withId id: CallbackId)
}


extension Suas {


  /// Create a store
  ///
  /// - Parameters:
  ///   - reducer: the reducer to use with the store. The reducer will be called when calling dispatch on this store
  ///   - state: the initial state to use for this store
  ///   - middleware: the store middleware
  ///   - notifier: the store notifier
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
  /// Using a combination of reducers
  ///
  /// ```
  /// let store = Suas.createStore(
  ///   reducer: MyReducer() |> MyOtherReducer()
  /// )
  /// ```
  public static func createStore(reducer: Reducer,
                                 state: StoreState,
                                 middleware: Middleware? = nil,
                                 notifier: ListenerNotifier? = nil) -> Store {
    return performCreateStore(
      reducer: reducer,
      state: state,
      middleware: middleware,
      notifier: notifier)
  }


  /// Create a store.
  ///
  /// The state will be generated from calling `reducer.initialState`
  ///
  /// - Parameters:
  ///   - reducer: the reducer to use with the store. The reducer will be called when calling dispatch on this store
  ///   - middleware: the store middleware
  ///   - notifier: the store notifier
  /// - Returns: a new store
  public static func createStore(reducer: Reducer,
                                 middleware: Middleware? = nil,
                                 notifier: ListenerNotifier? = nil) -> Store {
    return createStore(reducer: reducer,
                       state: StoreState(innerState: reducer.stateDict),
                       middleware: middleware,
                       notifier: notifier)
  }
}
