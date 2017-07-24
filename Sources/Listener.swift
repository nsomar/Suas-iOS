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

  /// The notify callback function that notifies the listener
  let notify: ListenerFunction<Any>

  /// Block that gets called to perform the notification. This block can decide wether we notify the listener or not
  let notificationBlock: ListenerNotifier<Any>
}


/// Notifier function implementation that always notifies the listener when the state changes.
let alwaysNotifier = { (newSubState: Any, oldSubState: Any, listener: Listener) in
  listener.notify(newSubState)
}

/// Notifier function implementation that notifies the listener only if the sub state has changed.
// TODO: Pass the static type ot listener and then use it for casting
public let compareNotifier = { (newSubState: Any, oldSubState: Any, listener: Listener) in

  if
    let newSubStateEq = newSubState as? __RuntimeEquatable__,
    let oldSubStateEq = oldSubState as? __RuntimeEquatable__{

    if !newSubStateEq.isEqual(to: oldSubStateEq) {
      listener.notify(newSubState)
    }
  } else {
    listener.notify(newSubState)
  }
}
