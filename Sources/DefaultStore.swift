//
//  DefaultStore.swift
//  ReDucks
//
//  Created by Omar Abdelhafith on 18/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation


public enum Suas {
  static func performCreateStore<R: Reducer>(reducer: R,
                                             state: State,
                                             middleware: Middleware?) -> Store {
    
    let reduce: ReducerFunction<Any> = { action, state in
      guard let newState = state as? R.StateType else {
        Suas.log("When reducing state of type \(type(of: state)) was not convertible to \(R.StateType.self)\nstate: \(state)")
        return state
      }
      // Calls the any reducer. In that reducer we typecheck
      return reducer.reduce(action: action, state: newState)
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
    let oldState = state
    
    var stateKeysChanged: Set<StateKey> = Set()
    
    if state.keys.count == 1, let key = state.keys.first {
      
      // The store has a single reducer
      if let subState = state[key], let newSubState = reducer(action, subState) {
        // State was changed for key
        state[key] = newSubState
        stateKeysChanged.insert(key)
      }
    } else {
      
      // The store has a combine reducer
      if let (newState, keysChanged) = reducer(action, state) as? (State, [StateKey]) {
        // State was changed for key
        state = newState
        keysChanged.forEach({ stateKeysChanged.insert($0) })
      }
    }
    
    for listener in listeners {
      
      if let key = listener.stateKey,
        stateKeysChanged.contains(key) == false {
        // If the listener has a key, and the key is not in the `stateKeysChanged` then dont inform the listner
        continue
      }
      
      guard
        let oldSubState = getSubstate(withState: oldState, forKey: listener.stateKey),
        let newSubState = getSubstate(withState: state, forKey: listener.stateKey) else { return }
      
      if listener.filterBlock(oldSubState, newSubState) {
        listener.notify(newSubState)
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

  func performAddListener<StateType, ListenerType>(linkedToObject: NSObject? = nil,
                                                   stateKey: StateKey?,
                                                   type: StateType.Type,
                                                   if filterBlock: FilterFunction<StateType>? = nil,
                                                   stateConverter: StateConverter<ListenerType>? = nil,
                                                   callback: @escaping (ListenerType) -> ()) -> Subscription<StateType> {
    
    var currentNotificationFilter: FilterFunction<Any> = alwaysFilter


    // If there is a filter we call it before
    if let filterBlock = filterBlock {

      // If we have a notification filter, wrap it in a type erasure closure
      currentNotificationFilter = { (old: Any, new: Any) -> Bool in
        // Dynamic typechecking :(
        guard let castNew = new as? StateType, let castOld = old as? StateType else {
          Suas.log("Either new value or old value cannot be converted to type \(State.self)\nnew value: \(new)\nold value: \(old)")
          return false
        }
        
        return filterBlock(castOld, castNew)
      }
    }


    // Create a type erased infom callback
    let typeErasedCallback = { (state: Any) in

      var stateToNotify: ListenerType?

      if let stateConverter = stateConverter {
        stateToNotify = stateConverter(state as! State)
      } else {
        stateToNotify = state as? ListenerType
      }
      // If there is a stateConverter we convert and inform
      guard let newState = stateToNotify else {
        Suas.log("State cannot be converted to type \(ListenerType.self)\nstate: \(state)")
        return
      }

      callback(newState)
    }

    let id = generateId()
    // Create listener and append it
    let listener = Listener(id: id, stateKey: stateKey,
      notify: typeErasedCallback, filterBlock: currentNotificationFilter)
    
    listeners = listeners + [listener]

    let subscription = Subscription<StateType>(store: self, listener: listener)

    if let linkedToObject = linkedToObject {
      onObjectDeinit(forObject: linkedToObject,
                     connectionType: .listener,
                     callbackId: id) { subscription.removeListener() }
    }

    return subscription
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
