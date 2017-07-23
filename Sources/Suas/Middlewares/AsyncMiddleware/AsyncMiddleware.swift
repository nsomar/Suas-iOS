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
/// let action = AsyncAction { (dispatch) in
///   DispatchQueue(label: "MyQueue").async {
///     // Load from disk
///     // Process loaded
///     // Do more work
///
///     // At a latter time dont forget to dispatch
///     dispatch(DataLoadedAction(data: data))
///   }
/// }
///
/// store.dispatch(action: action)
/// ```
public struct AsyncAction: Action {
  var executionBlock: (@escaping DispatchFunction) -> ()


  /// Creates an `AsyncAction`
  ///
  /// - Parameter executionBlock: callback to call when action is intercepted by `AsyncMiddleware`
  public init(executionBlock: @escaping (@escaping DispatchFunction) -> ()) {
    self.executionBlock = executionBlock
  }

  func execute(withDispatchingFunction dispatch: @escaping DispatchFunction) {
    executionBlock(dispatch)
  }
}


/// Async Middleware handles actions of type `AsyncAction`
///
/// `AsyncAction` are not dispatched to the reducer
/// When `AsyncMiddleware` intercepts an `AsyncAction` it does the following:
/// 1. Call `action.execute` on that action
/// 2. the action `executionBlock` is executed which receives the `dispatch` function as its sole parameter
/// 3. the `executionBlock` calls dispatch as many times as wanted, dispatching new actions (can also disptach new `AsyncAction`)
public class AsyncMiddleware: Middleware {
  public var api: MiddlewareAPI?
  public var next: DispatchFunction?

  public init() {}

  public func onAction(action: Action) {
    guard let api = api, let next = next else { return }

    if let action = action as? AsyncAction {
      action.execute(withDispatchingFunction: api.dispatch)
    }

    next(action)
  }
}
