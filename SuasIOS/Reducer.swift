//
//  Reducer.swift
//  ReDucks
//
//  Created by Omar Abdelhafith on 18/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation


/// Protocol that represents a reducer
///
/// -----
/// **Example**
///
///
/// ```
/// struct MyReducer: Reducer {
///   var initialState: Any {
///     return 1
///   }
///
///   var stateKey: StateKey = "some-other-key"
///
///   func reduce(action: Action, state: Any) -> Any {
///     guard var newState = state as? Int else { return state }
///
///     if let action = action as? SomeAction {
///       return newState + 1
///     }
///
///     return state
///   }
/// }
/// ```
public protocol Reducer {

  /// Inital state value for this particular reducer
  var initialState: Any { get }

  /// The state key for this reducer. If not implemented the type of `initialState` will be used as a key (recommended)
  var stateKey: StateKey { get }

  /// Generates a new state from the old state and an action
  ///
  /// - Parameters:
  ///   - action: the action recieved
  ///   - state: the old state
  /// - Returns: the new state
  func reduce(action: Action, state: Any) -> Any
}

extension Reducer {
  var stateKey: StateKey {
    return "\(type(of: initialState))"
  }
  
  var stateDict: KeyedState {
    if let reducer = self as? CombinedReducer {
      return reducer.states
    } else {
      return [stateKey: initialState]
    }
  }
}


/// Create a reducer inline with a block
///
/// -----
/// **Example**
///
/// ```
/// let myReducer = BlockReducer(state: 1) { action, state in
///   guard let newState = state as? Int else { return state }
///
///   if action is SomeAction {
///     return newState + 1
///   }
///
///   return newState
/// }
/// ```
public final class BlockReducer<Type>: Reducer {

  /// Inital state value for this particular reducer
  public let initialState: Any

  /// The state key for this reducer. If not implemented the type of `initialState` will be used as a key (recommended)
  public let stateKey: String
  
  private let reduceFunction: TypedReducerFunction<Type>

  /// Create a reducer with a state and a reduce function
  ///
  /// - Parameters:
  ///   - state: the initial state of the reducer
  ///   - reduce: the reduce function
  public convenience init(state: Type, reduce: @escaping TypedReducerFunction<Type>) {
    self.init(state: state, key: "\(type(of: state))", reduce: reduce)
  }

  /// Create a reducer with a state, a state key, and a reduce function
  ///
  /// - Parameters:
  ///   - state: the initial state of the reducer
  ///   - key: the key to be used for this reducer state
  ///   - reduce: the reduce function
  public init(state: Type, key: StateKey, reduce: @escaping TypedReducerFunction<Type>) {
    self.stateKey = key
    self.initialState = state
    self.reduceFunction = reduce
  }
  
  public func reduce(action: Action, state: Any) -> Any {
    guard let newState = state as? Type else { return state }
    return self.reduceFunction(action, newState)
  }
}

private final class CombinedReducer: Reducer {
  
  var initialState: Any {
    return states
  }
  
  var reducers: [StateKey: Reducer]
  fileprivate var states: KeyedState
  
  init() {
    self.states = [:]
    self.reducers = [:]
  }
  
  func append(reducer: Reducer) {
    guard reducers[reducer.stateKey] == nil else {
      Suas.log("Duplicate reducer added for state key '\(reducer.stateKey)'")
      return
    }
    
    reducers[reducer.stateKey] = reducer
    states[reducer.stateKey] = reducer.initialState
  }
  
  func reduce(action: Action, state: Any) -> Any {
    guard var dictState = state as? KeyedState else {
      Suas.log("State should be a dictionary when using combined reducers")
      return state
    }
    
    for (key, value) in reducers {
      guard let subState = dictState[key] else {
        Suas.log("State key '\(key)' missing for state '\(dictState)'")
        return dictState
      }
      
      let newSubState = value.reduce(action: action, state: subState)
      dictState[key] = newSubState
    }
    
    return dictState
  }
}


/// Combines two reducers. The combined reducer calls each of its internal reducer for a each paricular state key.
///
/// -----
/// **Example**
///
/// If a store has a state with two keys "key1" and "key2". We can register a reducer for each one of these keys.
///
/// We create two reducers with `stateKey`s of "key1" and "key2"
///
/// ```
/// let myReducer1 = BlockReducer(state: 1, key: "key1") { action, state in
///   guard let newState = state as? Int else { return state }
///
///   if action is SomeAction {
///     return newState + 1
///   }
///
///   return newState
/// }
///
/// let myReducer2 = BlockReducer(state: 1, key: "key2") { action, state in
///   guard let newState = state as? Int else { return state }
///
///   if action is SomeAction {
///     return newState + 1
///   }
///
///   return newState
/// }
/// ```
/// We can then combine these 2 reducers with:
///
/// ```
/// let store = Suas.createStore(
///   reducer: myReducer1 |> myReducer2
/// )
/// ```
///
/// `myReducer1` will handle the "key1" key of state and `myReducer2` will handle the "key2" key of state
public func |>(lhs: Reducer, rhs: Reducer) -> Reducer {
  var listToAppendTo: [Reducer] = []
  
  if
    let lhs = lhs as? CombinedReducer,
    let rhs = rhs as? CombinedReducer {
    listToAppendTo = Array(lhs.reducers.values) + Array(rhs.reducers.values)
  } else if let lhs = lhs as? CombinedReducer {
    listToAppendTo = Array(lhs.reducers.values)
  } else if let rhs = rhs as? CombinedReducer {
    listToAppendTo = Array(rhs.reducers.values)
  } else {
    listToAppendTo = [lhs, rhs]
  }
  
  let combiner = CombinedReducer()
  listToAppendTo.forEach({ combiner.append(reducer: $0) })
  return combiner
}
