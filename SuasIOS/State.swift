//
//  File.swift
//  ReDucks
//
//  Created by Omar Abdelhafith on 17/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation


/// Protcol that represents a state of a component
///
/// ## Example
///
/// ```
///
/// ```
public protocol State: Equatable, __RuntimeEquatable__ {

  /// Runtime equality check. No need to implement this method as it will be implemented by an extension on `__RuntimeEquatable__`
  ///
  /// - Parameter other: other value to compare to
  /// - Returns: true if equal, otherwise false
  func isEqual(to other: Any) -> Bool
}


/// Internal protocol used to provide a runtime implementation of equality
public protocol __RuntimeEquatable__ {
  func isEqual(to other: Any) -> Bool
}

extension State {

  /// Default implementation of isEqual. Dynamic cast the parameter to Self and then performs `==` on the two parameters
  ///
  /// - Parameter other: other value to compare to
  /// - Returns: true if equal, otherwise false
  public func isEqual(to other: Any) -> Bool {
    guard let other = other as? Self else { return false }
    
    return other == self
  }
}


/// Structure that represents the store state. The store state is kept as a Dictionary with String Keys and Any Values
public struct StoreState {
  var innerState: KeyedState

  /// Get a value for a key
  ///
  /// - Parameter key: the key to get the value for
  public subscript(key: String) -> Any? {
    get {
      return innerState[key]
    }
    set {
      innerState[key] = newValue
    }
  }

#if swift(>=4.0)
  /// Get a value for a key of specific type
  ///
  /// - Parameter forKeyOfType: the type to use for casting and fetching the state key
  @available(swift, introduced: 4.0)
  public subscript<Type>(forKeyOfType type: Type.Type) -> Type? {
    let key = "\(type)"
    return  innerState[key] as? Type
  }

  /// Get a value for a key of specific type
  ///
  /// - Parameter key: the key to get the value for
  /// - Parameter type: the type to cast the state to
  @available(swift, introduced: 4.0)
  public subscript<Type>(forKey key: String, ofType type: Type.Type) -> Type? {
    return  innerState[key] as? Type
  }
#endif

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
  /// - Returns: if the key is found and if its of the passed type then return it. Otherwise return nil
  public func value<Type>(forKeyOfType type: Type.Type) -> Type? {
    let key = "\(type)"
    return  innerState[key] as? Type
  }

  /// Get a value for a key of specific type
  ///
  /// - Parameters:
  ///   - key: the key to get the value for
  ///   - type: the type to cast the state to
  /// - Returns: if the key is found and if its of the passed type then return it. Otherwise return nil
  public func value<Type>(forKey key: String, ofType type: Type.Type) -> Type? {
    return  innerState[key] as? Type
  }
  
  var keys: [StateKey] {
    return Array(innerState.keys)
  }
}

extension StoreState: ExpressibleByDictionaryLiteral {

  /// Initialize a StoreState with a dictionary literal
  ///
  /// - Parameter elements: the dictionary literal to initialzie the StoreSate
  public init(dictionaryLiteral elements: (StateKey, Any)...) {
    self.innerState = [:]
    elements.forEach({ self.innerState[$0.0] = $0.1 })
  }

  init(dictionary: [StateKey: Any]) {
    self.innerState = [:]
    dictionary.forEach({ self.innerState[$0.0] = $0.1 })
  }
}

public struct StateConverter<From, To> {
  public let convert: (From) -> (To?)

  public init(convert: @escaping (From) -> (To?)) {
    self.convert = convert
  }
}
