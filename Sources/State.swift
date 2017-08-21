//
//  State.swift
//  ReDucks
//
//  Created by Omar Abdelhafith on 17/07/2017.
//  Copyright © 2017 Zendesk. All rights reserved.
//

import Foundation

/// Protocol used by `EqualsFilter` filter callback to compare two state values.
/// If your state implements the `Equatable` protocol there is no code required to implement `SuasDynamicEquatable`
///
/// # Example
///
/// ## Implement SuasDynamicEquatable manually
///
/// ```
/// struct MyState: SuasDynamicEquatable {
///   let value: Int
///
///   func isEqual(to other: Any) -> Bool {
///     // Cast to same type
///     guard let other = other as? MyState else { return false }
///
///     // Compare values
///     return other.value == self.value
///   }
/// }
/// ```
/// ## Implementing SuasDynamicEquatable as an extension
///
/// If your type implement equatable
///
/// ```
/// struct MyState: Equatable {
///   let value: Int
///   static func ==(lhs: MyState, rhs: MyState) -> Bool { ... }
/// }
/// ```
/// You dont need to implement `SuasDynamicEquatable` just add it as an extension to `MyState`. No extra code needed.
///
/// ```
/// extension MyState: SuasDynamicEquatable { }
/// ```
public protocol SuasDynamicEquatable {
  func isEqual(to other: Any) -> Bool
}

public extension SuasDynamicEquatable where Self: Equatable {
  public func isEqual(to other: Any) -> Bool {
    guard let other = other as? Self else { return false }
    return self == other
  }
}


/// Structure that represents the store state. The store state is kept as a `Dictionary` with `String` Keys and `Any` Values (`[String: Any]`)
///
/// For example, the state with two struct looks like:
///
/// ```
/// [
///   "TodoItems": TodoItems(....),
///   "AppSettings": AppSettings(....)
/// ]
/// ```
public struct State {
  var innerState: KeyedState


  /// Initialize a state with a dictionary
  ///
  /// - Parameter dictionary: the dictionary to initialize the state with
  public init(dictionary: [StateKey: Any]) {
    self.innerState = [:]
    dictionary.forEach({ self.innerState[$0.0] = $0.1 })
  }

  
  /// Get a value for a key
  ///
  /// - Parameter key: the key to get the value for.
  public subscript(key: String) -> Any? {
    get {
      return innerState[key]
    }
    set {
      innerState[key] = newValue
    }
  }
  
  /// Get a value for a key
  ///
  /// - Parameter key: the key to get the value for
  /// - Returns: the state value for the key if found
  public func value(forKey key: String) -> Any? {
    return  innerState[key]
  }
  
  /// Get a value for a key of specific type
  ///
  /// - Parameter type: the type to use for casting and fetching the state key
  /// - Returns: if the key is found and if its of the passed type then return it. Otherwise return nil.
  public func value<Type>(forKeyOfType type: Type.Type) -> Type? {
    let key = "\(type)"
    return  innerState[key] as? Type
  }
  
  /// Get a value for a key of specific type
  ///
  /// - Parameters:
  ///   - key: the key to get the value for
  ///   - type: the type to cast the state to
  /// - Returns: if the key is found and if its of the passed type then return it. Otherwise return nil.
  public func value<Type>(forKey key: String, ofType type: Type.Type) -> Type? {
    return  innerState[key] as? Type
  }
  
  /// Return all the keys in the state.
  public var keys: [StateKey] {
    return Array(innerState.keys)
  }
}

extension State: ExpressibleByDictionaryLiteral {
  
  /// Initialize a State with a dictionary literal
  ///
  /// - Parameter elements: the dictionary literal to initialzie the StoreSate
  public init(dictionaryLiteral elements: (StateKey, Any)...) {
    self.innerState = [:]
    elements.forEach({ self.innerState[$0.0] = $0.1 })
  }
}
