//
//  Middleware.swift
//  ReDucks
//
//  Created by Omar Abdelhafith on 18/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation
import Swift


/// Middleware api parameters to be used when dispatching a new action from a middleware. Or to get the current state that the store has
public struct MiddlewareAPI {

  /// Dispatch function to be used from the middleware to dispatch
  public var dispatch: DispatchFunction

  /// Gets the current state that the store has
  public var state: StoreState {
    return getState()
  }

  var getState: GetStateFunction
}


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
public protocol Middleware: class {

  /// The middleware api that allows a middleware to dispatcha an action and read the store current state
  var api: MiddlewareAPI? { get set }

  /// Function representing the next middleware action. In the last middleware next represents the dispatcher function which causes a state change when called
  var next: DispatchFunction? { get set }

  /// Function called when an action is dispatched
  ///
  /// - Parameter action: the dispatched action
  ///
  /// It is a requirement for the middleware to call `next(action)` inside this function. Failling to call next will cause the action to not be dispatched to the reducer
  func onAction(action: Action)
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

  /// The middleware api that allows a middleware to dispatcha an action and read the store current state
  public var api: MiddlewareAPI?

  /// Function representing the next middleware action. In the last middleware next represents the dispatcher function which causes a state change when called
  public var next: DispatchFunction?
  
  private let middlewareFunction: MiddlewareFunction

  /// Create a middleware with a callback block
  ///
  /// - Parameter actionFunction: block to be called with the action, the middleware api (containing the disptach function and the state) and the next action callback
  public init(actionFunction: @escaping MiddlewareFunction) {
    self.middlewareFunction = actionFunction
  }
  
  public func onAction(action: Action) {
    guard let api = api, let next = next else {
      Suas.log("Middleware is not setup correctly")
      return
    }
    
    middlewareFunction(action, api, next)
  }
}

private final class CombinedMiddleWare: Middleware {
  var next: DispatchFunction?  {
    didSet {
      middlewares.last?.next = next
    }
  }
  
  var api: MiddlewareAPI? {
    didSet {
      middlewares.forEach { $0.api = api }
    }
  }
  
  fileprivate var dispatchingFunction: DispatchFunction?
  fileprivate var middlewares: [Middleware]
  
  init() {
    self.middlewares = []
  }
  
  func append(middleware: Middleware) {
    middleware.next = next
    
    if dispatchingFunction == nil {
      dispatchingFunction = middleware.onAction
    } else if let lastMiddleware = middlewares.last {
      lastMiddleware.next = middleware.onAction
    }
    
    middlewares += [middleware]
  }
  
  func onAction(action: Action) {
    if let dispatchingFunction = dispatchingFunction {
      dispatchingFunction(action)
    } else {
      Suas.log("Middleware is not setup correctly")
    }
  }
}

/// Combines two middlewares. The combined middleware creates a chain of middleware. When calling next on the first middleware it progresses to the next one. The final middlware's next function calls the reducer dispatch will causes a state change
///
/// -----
/// **Example**
///
/// Combining two logging middlewares
///
/// ```
/// let middleware1 = BlockMiddleware { action, api, next in
///   print("Middleware1: The old state is \(api.state)")
///   print("Middleware1: The action is \(action)")
///   next(action)
///   print("Middleware1: The new state is \(api.state)")
/// }
///
/// let middleware2 = BlockMiddleware { action, api, next in
///   print("Middleware2: The old state is \(api.state)")
///   print("Middleware2: The action is \(action)")
///   next(action)
///   print("Middleware2: The new state is \(api.state)")
/// }
/// ```
/// We can then combine these 2 middlewares with:
///
/// ```
/// let store = Suas.createStore(
///   reducer: someReducer,
///   middleware: middleware1 |> middleware2
/// )
/// ```
public func |>(lhs: Middleware, rhs: Middleware) -> Middleware {
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

