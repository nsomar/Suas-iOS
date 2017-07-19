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
  func isEqual(to other: Any) -> Bool {
    guard let other = other as? Self else { return false }
    
    return other == self
  }
}

public struct StoreState {
  var innerState: KeyedState
  
  public subscript(key: String) -> Any? {
    return innerState[key]
  }

  @available(swift, introduced: 4.0)
  public subscript<Type>(forKeyOfType type: Type.Type) -> Type? {
    let key = "\(type)"
    return  innerState[key] as? Type
  }

  @available(swift, introduced: 4.0)
  public subscript<Type>(forKey key: String, ofType type: Type.Type) -> Type? {
    return  innerState[key] as? Type
  }

  @available(swift, obsoleted: 4.0)
  public func getValue<Type>(forKeyOfType type: Type.Type) -> Type? {
    let key = "\(type)"
    return  innerState[key] as? Type
  }

  @available(swift, obsoleted: 4.0)
  public func getValue<Type>(forKey key: String, ofType type: Type.Type) -> Type? {
    return  innerState[key] as? Type
  }

  @available(swift, obsoleted: 4.0)
  public func getValue(forKey key: String) -> Any? {
    return  innerState[key]
  }
  
  var keys: [StateKey] {
    return Array(innerState.keys)
  }
}

extension StoreState: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (StateKey, Any)...) {
    self.innerState = [:]
    elements.forEach({ self.innerState[$0.0] = $0.1 })
  }
}

public struct StateConverter<To> {
  public let convert: (StoreState) -> (To)

  public init(convert: @escaping (StoreState) -> (To)) {
    self.convert = convert
  }
}
