//
//  Listener.swift
//  SuasIOS
//
//  Created by Omar Abdelhafith on 19/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation


/// Listener structures that represents a listener added to the store
struct Listener {

  /// The callback id for this callback
  public let id: CallbackId

  /// The state key that the listener is registered to
  public let stateKey: StateKey?

  /// The notify callback function that notifies the listener
  public let notify: ListenerFunction<Any>

  /// Block that gets called before notification. This block can decide wether we notify the listener or not
  public let filterBlock: FilterFunction<Any>
}


/// State Change filter function that always notifies the returns true always.
public let alwaysFilter: FilterFunction<Any> = { (oldSubState: Any, newSubState: Any) in
  return true
}

/// State Change filter function that notifies the returns true only if the sub state has changed.
// TODO: Pass the static type ot listener and then use it for casting
public let stateChangedFilter: FilterFunction<Any> = { (oldSubState: Any, newSubState: Any) in

  if
    let newSubStateEq = newSubState as? SuasDynamicEquatable,
    let oldSubStateEq = oldSubState as? SuasDynamicEquatable {

    return !newSubStateEq.isEqual(to: oldSubStateEq)
  } else {
    return true
  }
}


/// State Change filter function implementation that notifies the listener only if the sub state has changed.
/// Changes = Shirt .. get it :P
// TODO: Pass the static type ot listener and then use it for casting
public let 👔 = stateChangedFilter
