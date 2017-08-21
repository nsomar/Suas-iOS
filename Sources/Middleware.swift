//
//  Middleware.swift
//  ReDucks
//
//  Created by Omar Abdelhafith on 18/07/2017.
//  Copyright © 2017 Zendesk. All rights reserved.
//

import Foundation
import Swift

/// Middleware protocol that represents a suas store middleware
/// A middleware helps extending the dispatch logic of Suas.
///
/// A middleware can be used to implement:
/// - Logging that logs the state before and after the reducer changes it
/// - Perform async network calls and dispatches actions representing the result when the network returns.
/// - Other advanced usages...
///
/// # Example
///
/// Implementing a logging middleware.
///
/// ```
/// class LoggerMiddleware: Middleware {
///   var api: MiddlewareAPI?
///   var next: DispatchFunction?
///
///   func onAction(action: Action, getState: @escaping GetStateFunction, dispatch: @escaping DispatchFunction, next: @escaping NextFunction) {
///     // Read the state before any reducer changes it
///     print("The old state is \(getState())")
///
///     // Print the action
///     print("The action is \(action)")
///
///     // Continue the dispatching process..until the reducer reduces the action
///     // Not calling `next` will prevent the action from reaching the reducer
///     next?(action)
///
///     // Read the state after any reducer changes it
///     print("The new state is \(api?.state)")
///   }
/// }
/// ```
///
public protocol Middleware {
  /// Function called when an action is dispatched
  ///
  /// - Parameters:
  /// - Parameter action: the dispatched action
  ///   - getState: a function that can be used to read the current Store state
  ///   - dispatch: a function that can be used to dispatch new actions to the Store
  ///   - next: function that represents the continuation of the dispatching process. The middleware can do the following with it:
  ///     - If it calls `next` the execution will proceed and the action will eventually reach the reducer
  ///     - If it does not call, then the action is said to be handled by the current middleware.
  ///     - Middleware cancall `next` with a new action, this action is used instead of the original one.
  func onAction(action: Action,
                getState: @escaping GetStateFunction,
                dispatch: @escaping DispatchFunction,
                next: @escaping NextFunction)
}

/// Create a middleware inline with a block.
///
/// # Example
///
/// ```
/// let middleware = BlockMiddleware { action, getState, dispatch, next in
///   // Read the state before any reducer changes it
///   print("The old state is \(getState())")
///
///   // Print the action
///   print("The action is \(action)")
///
///   // Continue the dispatching process..until the reducer reduces the action
///   // Not calling `next` will prevent the action from reaching the reducer
///   next?(action)
///
///   // Read the state after any reducer changes it
///   print("The new state is \(api?.state)")
/// }
/// ```
public final class BlockMiddleware: Middleware {
  
  private let middlewareFunction: MiddlewareFunction
  
  /// Create a middleware with an onAction callback block
  ///
  /// - Parameter actionFunction: block to be called with the action, a function to get the sate, a function to dispatch, and the next action callback.
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

/// Combines two middlewares. The combined middleware creates a chain of middleware.
/// When calling next on the first middleware it progresses to the next one. The final middlware's next function calls the reducer dispatch will causes a state change.
///
/// # Example
///
/// Combining two logging middlewares
///
/// ```
/// let middleware1 = BlockMiddleware { action, getState, dispatch, next in
///   // do some middleware stuff
/// }
///
/// let middleware2 = BlockMiddleware { action, getState, dispatch, next in
///   // do some middleware stuff
/// }
///
/// ```
/// We can then combine these 2 middlewares with `+` operator as:
///
/// ```
/// let store = Suas.createStore(
///   reducer: someReducer,
///   middleware: middleware1 + middleware2
/// )
/// ```
public func +(lhs: Middleware, rhs: Middleware) -> Middleware {
  if
    let lhs = lhs as? CombinedMiddleWare,
    let rhs = rhs as? CombinedMiddleWare {
    rhs.middlewares.forEach({ lhs.append(middleware: $0) })
  } else if let lhs = lhs as? CombinedMiddleWare {
    lhs.append(middleware: rhs)
    return lhs
  } else if let rhs = rhs as? CombinedMiddleWare {
    let combiner = CombinedMiddleWare()
    combiner.append(middleware: lhs)
    rhs.middlewares.forEach({ combiner.append(middleware: $0) })
    return combiner
  }

  let combiner = CombinedMiddleWare()
  combiner.append(middleware: lhs)
  combiner.append(middleware: rhs)
  return combiner
}
