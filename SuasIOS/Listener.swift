//
//  Listener.swift
//  SuasIOS
//
//  Created by Omar Abdelhafith on 19/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation


/// Listener structures that represents a listener added to the store
public struct Listener {

  /// The callback id for this callback
  let id: CallbackId

  /// The state key that the listener is registered to
  let stateKey: StateKey?

  /// The listener callback function
  let listener: ListenerFunction
}


/// Notifier function implementation that always notifies the listener when the state changes.
let alwaysNotifier = { (newSubState: Any, oldSubState: Any, listener: Listener) in
  listener.listener(newSubState)
}

/// Notifier function implementation that notifies the listener only if the sub state has changed.
public let compareNotifier = { (newSubState: Any, oldSubState: Any, listener: Listener) in
  if
    let newSubStateEq = newSubState as? __RuntimeEquatable__,
    let oldSubStateEq = oldSubState as? __RuntimeEquatable__{

    if !newSubStateEq.isEqual(to: oldSubStateEq) {
      listener.listener(newSubState)
    }
  } else {
    listener.listener(newSubState)
  }
}
