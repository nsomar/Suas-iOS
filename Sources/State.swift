//
//  File.swift
//  ReDucks
//
//  Created by Omar Abdelhafith on 17/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation


/// Internal protocol used to provide a runtime implementation of equality
public protocol SuasDynamicEquatable {
  func isEqual(to other: Any) -> Bool
}

public extension SuasDynamicEquatable where Self: Equatable {
  public func isEqual(to other: Any) -> Bool {
    guard let other = other as? Self else { return false }
    return self == other
  }
}


/// Structure that represents the store state. The store state is kept as a Dictionary with String Keys and Any Values
public struct State {
  var innerState: KeyedState
  
  
  init(dictionary: [StateKey: Any]) {
    self.innerState = [:]
    dictionary.forEach({ self.innerState[$0.0] = $0.1 })
  }

  
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
  
  /// Return all the keys in the state
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
