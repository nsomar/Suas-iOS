//
//  Middleware.swift
//  ReDucks
//
//  Created by Omar Abdelhafith on 18/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation
import Swift

/// Middleware protocol that represnts a store middleware
///
/// A middleware can be used to implement:
/// - Logging that is called before and after the dispatcher is called
/// - Perform network calls and dispatching an action representing the result when the network returns
///
/// -----
/// **Example**
///
/// Logging middleware
///
/// ```
/// class LoggerMiddleware: Middleware {
///   var api: MiddlewareAPI?
///   var next: DispatchFunction?
///
///   func onAction(action: Action) {
///     print("The old state is \(api?.state)")
///     print("The action is \(action)")
///     next?(action)
///     print("The new state is \(api?.state)")
///   }
/// }
/// ```
///
public protocol Middleware {
  /// Function called when an action is dispatched
  ///
  /// - Parameter action: the dispatched action
  ///
  /// It is a requirement for the middleware to call `next(action)` inside this function. Failling to call next will cause the action to not be dispatched to the reducer
  func onAction(action: Action,
                getState: @escaping GetStateFunction,
                dispatch: @escaping DispatchFunction,
                next: @escaping NextFunction)
}

/// Create a middleware inline with a block
///
/// -----
/// **Example**
///
/// ```
/// let middleware = BlockMiddleware { action, api, next in
///   print("The old state is \(api.state)")
///   print("The action is \(action)")
///   next(action)
///   print("The new state is \(api.state)")
/// }
/// ```
public final class BlockMiddleware: Middleware {
  
  private let middlewareFunction: MiddlewareFunction
  
  /// Create a middleware with a callback block
  ///
  /// - Parameter actionFunction: block to be called with the action, the middleware api (containing the disptach function and the state) and the next action callback
  public init(actionFunction: @escaping MiddlewareFunction) {
    self.middlewareFunction = actionFunction
  }
  
  public func onAction(action: Action,
                       getState: @escaping GetStateFunction,
                       dispatch: @escaping DispatchFunction,
                       next: @escaping NextFunction) {
    middlewareFunction(action, getState, dispatch, next)
  }
}

final class CombinedMiddleWare: Middleware {
  fileprivate var dispatchingFunction: MiddlewareFunction?
  fileprivate var middlewares: [Middleware]
  
  init() {
    self.middlewares = []
  }
  
  func append(middleware: Middleware) {
    middlewares += [middleware]
  }
  
  func onAction(action: Action,
                getState: @escaping GetStateFunction,
                dispatch: @escaping DispatchFunction,
                next: @escaping NextFunction) {
    guard middlewares.count > 0 else {
      Suas.log("Middleware is not setup correctly")
      return
    }

    doOnAction(index: 0, action: action, getState: getState, dispatch: dispatch, next: next)
  }

  private func doOnAction(index: Int, action: Action,
                          getState: @escaping GetStateFunction,
                          dispatch: @escaping DispatchFunction,
                          next: @escaping NextFunction) {

    let currentNext = nextAction(at: index, action: action, getState: getState,
                                 dispatch: dispatch, next: next)
    let current = middlewares[index]
    current.onAction(action: action, getState: getState, dispatch: dispatch, next: currentNext)
  }

  func nextAction(at index: Int, action: Action,
                  getState: @escaping GetStateFunction,
                  dispatch: @escaping DispatchFunction,
                  next: @escaping NextFunction) -> NextFunction {
    if index >= middlewares.count - 1 {
      return next
    } else {
      return { [weak self] action in
        self?.doOnAction(index: index + 1,
                        action: action,
                        getState: getState,
                        dispatch: dispatch,
                        next: next)
      }
    }
  }
}
