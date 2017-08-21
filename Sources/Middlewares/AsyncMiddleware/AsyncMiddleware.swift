//
//  AsyncMiddleware.swift
//  SuasIOS
//
//  Created by Omar Abdelhafith on 22/07/2017.
//  Copyright © 2017 Zendesk. All rights reserved.
//

import Foundation


/// Async action this type of action is intercepted by `AsyncMiddleware` and is not dispatched to the reducer.
///
/// Recepie to use `AsyncAction`
/// 1. Create an `AsyncAction` action
/// 2. In the block passed at init. Perform any operation (dispatching it on your queue)
/// 3. When result is ready, call `dispatch` passing a new action
///
/// If the `AsyncMiddleware` receives an `AsyncAction` it does the following:
/// 1. Call action.execute passing in the dispatch and get state functions
/// 2. Stops the action from propagating to other middlewares and reducers
///
/// # Example
///
/// ## Performing an async loading from disk
///
/// ```
/// struct MyDiskAsyncAction: AsyncAction {
///
///   func execute(getState: @escaping GetStateFunction, dispatch: @escaping DispatchFunction) {
///     // Perform some work in a background thread
///     DispatchQueue(label: "MyQueue").async {
///       // Load from disk
///       // Process loaded
///       // Do more work
///
///       // Maybe consult the current state
///       let currentState = api.state
///
///       // At a latter time dont forget to dispatch
///       dispatch(DataLoadedAction(data: data))
///     }
/// }
///
/// store.dispatch(action: MyDiskAsyncAction())
/// ```
///
/// ## Performing an async network request
///
/// ```
/// struct MyURLAsyncAction: AsyncAction {
///
///   func execute(getState: @escaping GetStateFunction, dispatch: @escaping DispatchFunction) {
///     // First dispatch some action syncrhonously
///     dispatch(SomeAction(...))
///
///     let session = URLSession(configuration: .default)
///     // perform a dataTask
///     session.dataTask(with: urlRequest) { data, response, error in
///
///       if let data = data {
///         // Do something with the data
///          dispatch(RequestSucceeded(data: data))
///
///       } else if let error = error {
///
///          // Error happenend
///          dispatch(RequestFaile(data: data))
///       }
///    }
/// }
///
/// store.dispatch(action: MyURLAsyncAction())
/// ```
public protocol AsyncAction: Action {

  /// Execution block that is executed in the `AsyncMiddleware`
  /// If the `AsyncMiddleware` receives an `AsyncAction` it does the following:
  /// 1. Call action.execute passing in the dispatch and get state functions
  /// 2. Stops the action from propagating to other middlewares and reducers
  func execute(getState: @escaping GetStateFunction, dispatch: @escaping DispatchFunction)
}


/// Create an `AsyncAction` inline by passing a block to the init
/// Check `AsyncAction` for more info
///
/// SeeAlso:
/// - `AsyncAction`
///
/// # Example
///
/// Performing an async network request
///
/// ```
/// let action = BlockAsyncAction { getState, dispatch in
///
///   // Read the current state from the Store
///   getState()
///
///   // First dispatch some action syncrhonously
///   dispatch(SomeAction(...))
///
///   let session = URLSession(configuration: .default)
///   // perform a dataTask
///   session.dataTask(with: urlRequest) { data, response, error in
///
///     if let data = data {
///       // Do something with the data
///        dispatch(RequestSucceeded(data: data))
///
///     } else if let error = error {
///
///        // Error happenend
///        dispatch(RequestFaile(data: data))
///     }
///   }
/// }
///
/// store.dispatch(action: MyURLAsyncAction())
/// ```
public struct BlockAsyncAction: AsyncAction {
  private var executionBlock: (@escaping GetStateFunction, @escaping DispatchFunction) -> ()

  public init(executionBlock: @escaping (@escaping GetStateFunction, @escaping DispatchFunction) -> ()) {
    self.executionBlock = executionBlock
  }

  public func execute(getState: @escaping GetStateFunction, dispatch: @escaping DispatchFunction) {
    executionBlock(getState, dispatch)
  }
}

/// Async Middleware handles actions of type `AsyncAction`
///
/// `AsyncAction` are not dispatched to the reducer
/// When `AsyncMiddleware` intercepts an `AsyncAction` it does the following:
/// 1. Call `action.execute` on that action
/// 2. the action `execute` is executed which receives the `getState` and `dispatch` function as its parameters
/// 3. the `execute` calls dispatch as many times as wanted, dispatching new actions (can also disptach new `AsyncAction`)
///
/// SeeAlso:
/// - `AsyncAction`
public struct AsyncMiddleware: Middleware {

  public init() { }
  
  public func onAction(action: Action,
                       getState: @escaping GetStateFunction,
                       dispatch: @escaping DispatchFunction,
                       next: @escaping NextFunction) {
    if let action = action as? AsyncAction {
      action.execute(getState: getState, dispatch: dispatch)
      return
    }

    next(action)
  }
}
