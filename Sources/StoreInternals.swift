//
//  StoreInternals.swift
//  ReDucks
//
//  Created by Omar Abdelhafith on 18/07/2017.
//  Copyright © 2017 Zendesk. All rights reserved.
//

import Foundation


extension Suas {
  static func performCreateStore<R: Reducer>(reducer: R,
                                             state: State,
                                             middleware: Middleware?) -> Store {

    let reduce: ReducerFunction<Any> = { state, action in
      guard let newState = state as? R.StateType else {
        Suas.log("When reducing state of type '\(type(of: state))' was not convertible to '\(R.StateType.self)'\nstate: \(state)")
        return state
      }
      // Calls the any reducer. In that reducer we typecheck
      return reducer.reduce(state: newState, action: action)
    }

    return Store(
      state: state,
      reducer: reduce,
      middleware: middleware)
  }
}


// MARK: Initialization and Reduce registration

extension Store {

  func getState() -> State {
    return self.state
  }

  func performDispatch(action: Action) {
    ensureNotDispatching()

    let oldState = state

    isDispatching = true
    let keysChanged = performReduce(action: action)
    isDispatching = false

    informListeners(keysChanged: keysChanged, oldState: oldState)
  }

  private func ensureNotDispatching() {
    if isDispatching {
      Suas.log("You must not dispatch actions in your reducer. Seriously. (╯°□°）╯︵ ┻━┻")
      Suas.fatalError()
      return
    }
  }

  private func performReduce(action: Action) -> Set<StateKey> {
    var keysChanged: Set<StateKey> = Set()

    if state.keys.count == 1, let key = state.keys.first {

      // The store has a single reducer
      if let subState = state[key], let newSubState = reducer(subState, action) {
        // State was changed for key
        state[key] = newSubState
        keysChanged.insert(key)
      }
    } else {

      // The store has a combine reducer
      if let (newState, currentKeysChanged) = reducer(state, action) as? (State, [StateKey]) {
        // State was changed for key
        state = newState

        currentKeysChanged.forEach({ keysChanged.insert($0) })
      }
    }

    return keysChanged
  }

  private func informListeners(keysChanged: Set<StateKey>, oldState: State) {
    for listener in listeners {

      if let key = listener.stateKey,
        keysChanged.contains(key) == false {
        // If the listener has a key, and the key is not in the `keysChanged` then dont inform the listner
        Suas.log("Listener notification skipped since state keys was not changed\nListener: \(listener)\nChanged keys: \(keysChanged)\nState: \(state.innerState)")
        continue
      }

      guard
        let oldSubState = getSubstate(withState: oldState, forKey: listener.stateKey),
        let newSubState = getSubstate(withState: state, forKey: listener.stateKey) else {
          Suas.log("Listener notification skipped as listener key '\(String(describing: listener.stateKey))' was not found in state\nListener: \(listener)\nState: \(state.innerState)")
          return
      }

      if listener.filterBlock(oldSubState, newSubState) {
        listener.notify(newSubState)
      } else {
        Suas.log("Listener notification skipped as listener filter block did not pass\nListener: \(listener)\nState: \(state.innerState)")
      }
    }
  }

  private func getSubstate(withState state: State, forKey key: StateKey?) -> Any? {
    if let key = key {
      return state[key] ?? state
    } else {
      return state
    }
  }
}

// MARK: Adding and removing observers and middlewares

extension Store {

  func performAddListener<StateType>(if filterBlock: FilterFunction<State>? = nil,
                                     stateSelector: @escaping StateSelector<StateType>,
                                     callback: @escaping (StateType) -> ()) -> Subscription<StateType> {



    let currentNotificationFilter = eraseNotificationFilterType(forFilter: filterBlock)

    // Create a type erased infom callback
    let typeErasedCallback = { (state: Any) in

      // If there is a stateConverter we convert and inform
      guard let newState = stateSelector(state as! State) else {
        Suas.log("State cannot be converted to type '\(StateType.self)'\nState: \(state)")
        return
      }

      callback(newState)
    }

    return addNotificaitonListener(ofType: StateType.self, stateKey: nil,
                                   notificationFilter: currentNotificationFilter, callback: typeErasedCallback)
  }

  func performAddListener<StateType, ListenerType>(stateKey: StateKey?,
                                                   type: StateType.Type,
                                                   if filterBlock: FilterFunction<StateType>? = nil,
                                                   callback: @escaping (ListenerType) -> ()) -> Subscription<StateType> {

    let currentNotificationFilter = eraseNotificationFilterType(forFilter: filterBlock)

    // Create a type erased infom callback
    let typeErasedCallback = { (state: Any) in

      // If there is a stateConverter we convert and inform
      guard let newState = state as? ListenerType else {
        Suas.log("State cannot be converted to type '\(ListenerType.self)'\nState: \(state)")
        return
      }

      callback(newState)
    }

    return addNotificaitonListener(ofType: StateType.self, stateKey: stateKey,
                                   notificationFilter: currentNotificationFilter, callback: typeErasedCallback)
  }


  private func eraseNotificationFilterType<StateType>(forFilter filterBlock: FilterFunction<StateType>?) -> FilterFunction<Any> {
    // If there is a filter we call it before
    if let filterBlock = filterBlock {

      // If we have a notification filter, wrap it in a type erasure closure
      return { (old: Any, new: Any) -> Bool in
        // Dynamic typechecking :(
        guard let castNew = new as? StateType, let castOld = old as? StateType else {
          Suas.log("Either new value or old value cannot be converted to type '\(State.self)'\nnew value: \(new)\nold value: \(old)")
          return false
        }

        return filterBlock(castOld, castNew)
      }
    }
    
    return alwaysFilter
  }

  private func addNotificaitonListener<StateType>(ofType type: StateType.Type,
                                                  stateKey: StateKey?,
                                                  notificationFilter: @escaping FilterFunction<Any>,
                                                  callback: @escaping ListenerFunction<Any>) -> Subscription<StateType> {
    // Create listener and append it
    let listener = Listener(id: generateId(),
                            stateKey: stateKey,
                            notify: callback,
                            filterBlock: notificationFilter)
    
    listeners = listeners + [listener]
    
    return Subscription<StateType>(store: self, listener: listener)
  }

  func removeListener(withId id: CallbackId)  {
    listeners = listeners.filter { $0.id != id }
  }

  func generateId() -> CallbackId {
    return UUID().uuidString
  }
}

// Action listeners
extension Store {

  func removeActionListener(withId id: CallbackId)  {
    actionListeners.removeValue(forKey: id)
  }
}

extension Suas {
  static func allListeners(inStore store: Store) -> [Listener] {
    return store.listeners
  }

  static func allActionListeners(inStore store: Store) -> [Any] {
    return Array(store.actionListeners.keys)
  }
}

