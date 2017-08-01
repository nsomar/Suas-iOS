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
///   var initialState: Int {
///     return 1
///   }
///
///   func reduce(action: Action, state: Int) -> Int? {
///
///     if let action = action as? SomeAction {
///       // state changed, listeners will be notified
///       return state + 1
///     }
///
///     // returning nil means the state did not change and listeners wont be notified
///     return nil
///   }
/// }
/// ```
///
/// Note: Returning `nil` from `reduce` signifies that the state did not change which will not inform the listeners
public protocol Reducer {
  associatedtype StateType
  
  /// Inital state value for this particular reducer
  var initialState: StateType { get }
  
  /// The state key for this reducer. If not implemented the type of `initialState` will be used as a key (recommended)
  var stateKey: StateKey { get }
  
  /// Generates a new state from the old state and an action
  ///
  /// - Parameters:
  ///   - action: the action recieved
  ///   - state: the old state
  /// - Returns: the new state
  ///
  /// Note: Returning `nil` from `reduce` signifies that the state did not change which will not inform the listeners
  func reduce(action: Action, state: StateType) -> StateType?
}

extension Reducer {
  func reduce(action: Action, state: Any) -> Any? {
    guard let newState = state as? Self.StateType else {
      Suas.log("When reducing state of type '\(type(of: state))' was not convertible to '\(Self.StateType.self)'\nState: \(state)")
      return state
    }
    
    return reduce(action: action, state: newState)
  }
}

extension Reducer {
  public var stateKey: StateKey {
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
///
/// Note: Returning `nil` from `BlockReducer` signifies that the state did not change which will not inform the listeners
public final class BlockReducer<StateType>: Reducer {
  
  /// Inital state value for this particular reducer
  public let initialState: StateType
  
  /// The state key for this reducer. If not implemented the type of `initialState` will be used as a key (recommended)
  public let stateKey: String
  
  private let reduceFunction: ReducerFunction<StateType>
  
  /// Create a reducer with a state and a reduce function
  ///
  /// - Parameters:
  ///   - state: the initial state of the reducer
  ///   - reduce: the reduce function
  public convenience init(initialState: StateType, reduce: @escaping ReducerFunction<StateType>) {
    self.init(initialState: initialState, stateKey: "\(type(of: initialState))", reduce: reduce)
  }
  
  /// Create a reducer with a state, a state key, and a reduce function
  ///
  /// - Parameters:
  ///   - state: the initial state of the reducer
  ///   - key: the key to be used for this reducer state
  ///   - reduce: the reduce function
  public init(initialState: StateType, stateKey: StateKey, reduce: @escaping ReducerFunction<StateType>) {
    self.initialState = initialState
    self.stateKey = stateKey
    self.reduceFunction = reduce
  }
  
  public func reduce(action: Action, state: StateType) -> StateType? {
    return self.reduceFunction(action, state)
  }
}


/// Reducer that represents a combination of two reducers
/// This reducers is not to be implemented by hand. This reducer is internal implementation only
public final class CombinedReducer: Reducer {
  
  public var initialState: Any {
    return states
  }
  
  var reducers: [StateKey: ReducerFunction<Any>]
  fileprivate var states: KeyedState
  
  init() {
    self.states = [:]
    self.reducers = [:]
  }
  
  func append(reducerWithKey stateKey: StateKey, funciton: @escaping ReducerFunction<Any>, state: Any) {
    guard reducers[stateKey] == nil else {
      Suas.log("Duplicate reducer added for state key '\(stateKey)'")
      return
    }
    
    reducers[stateKey] = funciton
    states[stateKey] = state
  }
  
  public func reduce(action: Action, state: Any) -> Any? {
    guard var dictState = state as? State else {
      Suas.log("State should be a dictionary when using combined reducers\nState: \(state)")
      return (state, [])
    }
    
    var stateKeysChanged: [StateKey] = []
    
    for (key, reducer) in reducers {
      guard let subState = dictState[key] else {
        Suas.log("State key '\(key)' missing in state '\(dictState)'")
        continue
      }
      
      if let newSubState = reducer(action, subState) {
        dictState[key] = newSubState
        stateKeysChanged.append(key)
      }
    }
    
    return (dictState, stateKeysChanged)
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
///   reducer: myReducer1 + myReducer2
/// )
/// ```
///
/// `myReducer1` will handle the "key1" key of state and `myReducer2` will handle the "key2" key of state
public func +<R1: Reducer, R2: Reducer>(lhs: R1, rhs: R2) -> CombinedReducer {
  var listToAppendTo: [(StateKey, Any, ReducerFunction<Any>)] = []
  
  if
    let lhs = lhs as? CombinedReducer,
    let rhs = rhs as? CombinedReducer {
    // Add left reducers, then right reducers
    for (key, reducer) in lhs.reducers {
      listToAppendTo.append((key, lhs.states[key]!, reducer))
    }
    
    for (key, reducer) in rhs.reducers {
      listToAppendTo.append((key, rhs.states[key]!, reducer))
    }
  } else if let lhs = lhs as? CombinedReducer {
    // Adds left reducers, then single right subreducer
    for (key, reducer) in lhs.reducers {
      listToAppendTo.append((key, lhs.states[key]!, reducer))
    }
    listToAppendTo.append((rhs.stateKey, rhs.initialState, rhs.reduce))
  } else if let rhs = rhs as? CombinedReducer {
    // Adds single left reducer, then right reducers
    listToAppendTo.append((lhs.stateKey, lhs.initialState, lhs.reduce))
    for (key, reducer) in rhs.reducers {
      listToAppendTo.append((key, rhs.states[key]!, reducer))
    }
  } else {
    // Adds single left reducer, then single right reducer
    listToAppendTo.append((lhs.stateKey, lhs.initialState, lhs.reduce))
    listToAppendTo.append((rhs.stateKey, rhs.initialState, rhs.reduce))
  }
  
  // Create a combiner
  let combiner = CombinedReducer()
  listToAppendTo.forEach({ combiner.append(reducerWithKey: $0.0, funciton: $0.2, state: $0.1) })
  return combiner
}
