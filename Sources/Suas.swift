//
//  Suas.swift
//  SuasIOS
//
//  Created by Omar Abdelhafith on 31/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation

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
  ///   reducer: MyReducer() + MyOtherReducer()
  /// )
  /// ```
  public static func createStore<R: Reducer>(reducer: R,
                                             state: KeyedState,
                                             middlewares: [Middleware] = []) -> Store {
    return performCreateStore(
      reducer: reducer,
      state: State(dictionary: state),
      middlewares: middlewares)
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
  ///   reducer: MyReducer() + MyOtherReducer()
  /// )
  /// ```
  public static func createStore<R: Reducer, StateType>(reducer: R,
                                                        state: StateType,
                                                        middlewares: [Middleware] = []) -> Store {
    return performCreateStore(
      reducer: reducer,
      state: ["\(type(of: state))": state],
      middlewares: middlewares)
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
  ///   reducer: MyReducer() + MyOtherReducer()
  /// )
  /// ```
  public static func createStore<R: Reducer>(reducer: R,
                                             middlewares: [Middleware] = []) -> Store {
    return performCreateStore(reducer: reducer,
                              state: State(dictionary: reducer.stateDict),
                              middlewares: middlewares)
  }

}
