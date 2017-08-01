//
//  Middleware.swift
//  SuasIOS
//
//  Created by Omar Abdelhafith on 22/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation


/// Async action this type of action is intercepted by `AsyncMiddleware` and is not dispatched to the reducer
///
/// Recepie to use `AsyncAction`
/// 1. Create an `AsyncAction` action
/// 2. In the block passed at init. Perform any operation (dispatching it on your queue)
/// 3. When result is ready, call `dispatch` passing a new action
/// --------
/// **Example:**
///
/// Performing an async loading from disk
///
/// ```
/// let action = AsyncAction { api in
///   DispatchQueue(label: "MyQueue").async {
///     // Load from disk
///     // Process loaded
///     // Do more work
///
///     // Maybe consult the current state
///     let currentState = api.state
///
///     // At a latter time dont forget to dispatch
///     dispatch(DataLoadedAction(data: data))
///   }
/// }
///
/// store.dispatch(action: action)
/// ```
public protocol AsyncAction: Action {

  /// Execution block that is executed in the `AsyncMiddleware`
  /// If the `AsyncMiddleware` receives an `AsyncAction` it does the following:
  /// 1. Call action.executionBlock passing in the dispatch and get state functions
  /// 2. Stops the action from propagating to other middlewares and reducers
  func onAction(getState: @escaping GetStateFunction, dispatch: @escaping DispatchFunction)
}


/// Create an `AsyncAction` inline by passing a block to the init
/// Check `AsyncAction` for more info
///
/// SeeAlso:
/// - `AsyncAction`
public struct BlockAsyncAction: AsyncAction {
  private var executionBlock: (GetStateFunction, DispatchFunction) -> ()

  public init(executionBlock: @escaping (GetStateFunction, DispatchFunction) -> ()) {
    self.executionBlock = executionBlock
  }

  public func onAction(getState: @escaping GetStateFunction, dispatch: @escaping DispatchFunction) {
    executionBlock(getState, dispatch)
  }
}

/// Async Middleware handles actions of type `AsyncAction`
///
/// `AsyncAction` are not dispatched to the reducer
/// When `AsyncMiddleware` intercepts an `AsyncAction` it does the following:
/// 1. Call `action.execute` on that action
/// 2. the action `executionBlock` is executed which receives the `dispatch` function as its sole parameter
/// 3. the `executionBlock` calls dispatch as many times as wanted, dispatching new actions (can also disptach new `AsyncAction`)
public struct AsyncMiddleware: Middleware {

  public func onAction(action: Action,
                       getState: @escaping GetStateFunction,
                       dispatch: @escaping DispatchFunction,
                       next: @escaping NextFunction) {
    if let action = action as? AsyncAction {
      action.onAction(getState: getState, dispatch: dispatch)
      return
    }

    next(action)
  }
}
