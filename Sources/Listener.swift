//
//  Listener.swift
//  SuasIOS
//
//  Created by Omar Abdelhafith on 19/07/2017.
//  Copyright © 2017 Zendesk. All rights reserved.
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


/// Subscription structure that represents a listener subscription.
/// When adding a listener you get a subscription back. You can use this subscription to remove the listener, notify about the current state or link the listener lifecycle with an object.
public struct Subscription<StateType> {
  let store: Store
  let listener: Listener


  /// Notify the listener associated with this `Subscription` about the current state. Calls the listener block without dispatching an action.
  ///
  /// You can use this method to call the listener notification block with the current state, useful when you want to initialize some UI elements for example.
  ///
  /// # Example
  ///
  /// ```
  /// let subscription = store.addListener(...)
  /// subscription.informWithCurrentState()
  /// ```
  public func informWithCurrentState() {
    var stateToNotify: Any!

    if let key = listener.stateKey {

      // If there is a key, Get the state for it and covert it
      guard let state = store.state.value(forKey: key, ofType: StateType.self) else {
        Suas.log("State for key `\(key)` of type '\(StateType.self)' not found. Notification skipped.")
        return
      }
      stateToNotify = state
    } else {

      // Else get the whole state
      stateToNotify = store.state
    }

    listener.notify(stateToNotify)
  }

  /// Remove the listner associated with this subscription. After calling `removeListener` the listener won't be notified anymore.
  ///
  /// # Example
  ///
  /// ```
  /// let subscription = store.addListener(...)
  /// subscription.removeListener()
  /// ```
  public func removeListener() {
    store.removeListener(withId: listener.id)
  }

  /// Link the listener associated with this subscription with an object. When the object gets deallocated the listener is removed.
  /// Useful when adding listeners that updates a UIView. You can link the listener lifecycle to the UIView's lifecycle.
  /// When the UIView is removed (deallocated) the listener will be removed and will stop it from being notified.
  ///
  /// # Example
  ///
  /// ```
  /// let view = SomeUIVIew()
  ///
  /// // Listener updates the view
  /// let subscription = store.addListener(...)
  ///
  /// // Link the listener lifecycle to the view. No need to manually call `removeListener` anymore.
  /// subscription.linkLifeCycleTo(object: view)
  /// ```
  public func linkLifeCycleTo(object: NSObject) {
    Suas.onObjectDeinit(forObject: object,
                        callbackId: listener.id) { self.removeListener() }
  }
}

/// Subscription structure that represents a listener subscription.
/// When adding a listener you get a subscription back. You can use this subscription to remove the listener, notify about the current state or link the listener lifecycle with an object.
public struct ActionSubscription {
  let store: Store
  let listenerId: CallbackId

  /// Remove the listner associated with this subscription. After calling `removeListener` the listener won't be notified anymore.
  ///
  /// # Example
  ///
  /// ```
  /// let subscription = store.addActionListener(...)
  /// subscription.removeListener()
  /// ```
  public func removeListener() {
    store.removeActionListener(withId: listenerId)
  }

  /// Link the listener associated with this subscription with an object. When the object gets deallocated the listener is removed.
  /// Useful when adding listeners that updates a UIView. You can link the listener lifecycle to the UIView's lifecycle.
  /// When the UIView is removed (deallocated) the listener will be removed and will stop it from being notified.
  ///
  /// # Example
  ///
  /// ```
  /// let view = SomeUIVIew()
  ///
  /// // Listener updates the view
  /// let subscription = store.addActionListener(...)
  ///
  /// // Link the listener lifecycle to the view. No need to manually call `removeListener` anymore.
  /// subscription.linkLifeCycleTo(object: view)
  /// ```
  public func linkLifeCycleTo(object: NSObject) {
    Suas.onObjectDeinit(forObject: object,
                        callbackId: listenerId) { self.removeListener() }
  }
}

/// Listener filter callback that always returns true.
/// When using this filter callback the Listener will always be notified.
public let alwaysFilter: FilterFunction<Any> = { (oldSubState: Any, newSubState: Any) in
  return true
}


/// Listener filter callback that returns true if the old state and the new state are not equal.
/// You can use this filter function when adding a listener if you want your notification function to be called when the state changes.
///
/// In order to use this filter block your state types has to implement `SuasDynamicEquatable` protocol
/// Note: if you implement `Equatable` you can implement `SuasDynamicEquatable` without any extra code. You only have to include `SuasDynamicEquatable` in the list of protocols for your type (check examples).
///
/// # Example
///
/// ## Implementing SuasDynamicEquatable manually
///
/// Implementing SuasDynamicEquatable without Equatable
///
/// ```
/// // Implement SuasDynamicEquatable manually
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
///
/// let subscription = store.addListener(forStateType: MyState.self, if: EqualsFilter) { newState in
///   // use new state
/// }
/// ```
///
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
///
/// `EqualsFilter` now works with `MyState`
///
/// ```
/// let subscription = store.addListener(forStateType: MyState.self, if: EqualsFilter) { newState in
///   // use new state
/// }
/// ```
public let EqualsFilter: FilterFunction<Any> = { (oldSubState: Any, newSubState: Any) in

  if
    let newSubStateEq = newSubState as? SuasDynamicEquatable,
    let oldSubStateEq = oldSubState as? SuasDynamicEquatable {

    return !newSubStateEq.isEqual(to: oldSubStateEq)
  } else {
    return true
  }
}
