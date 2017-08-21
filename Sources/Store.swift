//
//  Store.swift
//  ReDucks
//
//  Created by Omar Abdelhafith on 17/07/2017.
//  Copyright © 2017 Zendesk. All rights reserved.
//

import Foundation


/// Store that contains the application state, the reducer logic, the middleware and the listeners
///
/// The store contains four components:
/// - **state**: represents the application state. This state is partitioned into state keys. Each key can represents a full application screen, flow, or view controller.
/// - **reducer** represents the logic to update the state. A reducer mainly provides a function that updates the state for a paticular action.
/// - **middleware**: an object (or list of objects) that intercept an action and can enrich or alter it before finally dispatching it to the reducer.
/// - **listener**: a function that gets called when a state is changed.
final public class Store {

  /// Get the current state
  public var state: State
  
  var reducer: ReducerFunction<Any>
  var listeners: [Listener]
  var actionListeners: [CallbackId: ActionListenerFunction]
  var dispatchingFunction: DispatchFunction?
  var isDispatching = false
  
  init(state: State,
       reducer: @escaping ReducerFunction<Any>,
       middleware: Middleware?) {
    
    self.state = state
    self.reducer = reducer
    self.listeners = []
    self.actionListeners = [:]
    self.dispatchingFunction = nil
    
    if let middleware = middleware {
      
      self.dispatchingFunction = { [weak self] action in
        guard let sself = self else { return }
        
        middleware.onAction(
          action: action,
          getState: { sself.getState() }, // Capturing self
          dispatch: { [weak sself] action in sself?.dispatch(action: action) },
          next: { [weak sself] action in sself?.performDispatch(action: action) }
        )
      }
    } else {
      self.dispatchingFunction = self.performDispatch
    }
  }
}



/// Dispatch Actions Store Extension
extension Store {
  /// Dispatches an action to the store
  ///
  /// - Parameter action: the action to dispatch
  public func dispatch(action: Action) {
    let toDispatch = {
      // Inform the action listeners
      self.actionListeners.forEach({ $0.value(action) })
      
      self.dispatchingFunction?(action)
    }
    
    if Thread.isMainThread {
      toDispatch()
    } else {
      DispatchQueue.main.sync { toDispatch() }
    }
  }
}



/// Add Listener Store Extension
extension Store {


  /// Add a listener to the store. The listener will be notified when the state changes.
  ///
  /// - Parameters:
  ///   - type: The type of the state to listen to. If the state type is not found, the listener will not be notified.
  ///   - stateKey: (Optional) the state key to listen to. When not passed (or passing nil) the type name from `forStateType` will be used.
  ///     Only pass when the state key for the state was changed in the reducer (99% of the times you dont need to set this parameter)
  ///   - filterBlock: (Optional) block that receives the old state and the new state and it decides wether the notification for the listener should be sent or not.
  ///     When not set, the listener is notified whenever the state changed.
  ///   - callback: Notification block called with the new state when the store's state changed.
  /// - Returns: The Listener's subscription that can be used to remove the notification and for other listener related stuff.
  ///
  /// # Example
  ///
  /// ## Adding a listener
  /// Add a simple listener for a `MyState` state type
  ///
  /// ```
  /// let subscription = store.addListener(forStateType: MyState.self) { newState in
  ///   // Do something with the state
  /// }
  /// ```
  /// ## Adding a listener with a filterBlock
  /// Adding a listener for a state of `TodoItemsState` type with a filter block.
  /// In the filterBlock we check that the new state has more items than the old state.
  /// The Listener will be notified only if the filterBlock returns true.
  ///
  /// ```
  /// let subscription = store.addListener(
  ///   forStateType: TodoItemsState.self,
  ///   if: { old, new in return old.todos.count > new.todos.count }) { newState in
  ///     // Do something with the state
  /// }
  /// ```
  /// ## Adding a listener with a state key
  /// Adding a listener for a state of `TodoItemsState` type, the reducer registered the state key to "todos"
  ///
  /// ```
  /// let subscription = store.addListener(forStateType: TodoItemsState.self, stateKey: "todos") { newState in
  ///   // Do something with the state
  /// }
  /// ```
  public func addListener<StateType>(forStateType type: StateType.Type,
                                     stateKey: StateKey? = nil,
                                     if filterBlock: FilterFunction<StateType>? = nil,
                                     callback: @escaping (StateType) -> ()) -> Subscription<StateType> {

    return performAddListener(stateKey: stateKey ?? "\(type)",
      type: type,
      if: filterBlock,
      callback: callback)
  }

  
  /// Add a listener to the store with a stateSelector
  ///
  /// - Parameters:
  ///   - filterBlock: (Optional) block that receives the old state and the new state and it decides wether the notification for the listener should be sent or not.
  ///     When not set, the listener is notified whenever the state changed.
  ///   - stateSelector: state selector block that selects a part of the full state
  ///   - callback: Notification block called with the new state when the store's state changed.
  /// - Returns: The Listener's subscription that can be used to remove the notification and for other listener related stuff.
  ///
  /// # Example
  ///
  /// ## Adding a listener with a state selector
  /// Add a simple listener for the full state with a state selector that selects part of it.
  ///
  /// Create a state selector that selects and creates a `TodoItemsState` from the full `Store` state.
  ///
  /// ```
  /// let stateSelector: StateSelector<TodoItemsState> = { state in
  ///   // Read values from the store
  ///   let value1 = state.value(forKeyOfType: SomeType.self)
  ///   let value2 = state.value(forKey: "someKey")
  ///
  ///   // Create and return a TodoItemsState
  ///   return TodoItemsState(.....)
  /// }
  /// ```
  ///
  /// Add a listener with the state selector and
  ///
  /// ```
  /// let subscription = store.addListener(stateSelector: stateSelector) { newState in
  ///   // newState here is a TodoItemsState
  /// }
  /// ```
  ///
  /// ## Adding a listener with a state selector and a filter block
  /// Add a simple listener for the full state with a state selector that selects part of it and a filter block that decide when to notify.
  ///
  /// Create a state selector that selects and creates a `TodoItemsState` from the full `Store` state.
  ///
  /// ```
  /// let stateSelector: StateSelector<TodoItemsState> = { state in
  ///   // Read values from the store
  ///   let value1 = state.value(forKeyOfType: SomeType.self)
  ///   let value2 = state.value(forKey: "someKey")
  ///
  ///   // Create and return a TodoItemsState
  ///   return TodoItemsState(.....)
  /// }
  /// ```
  ///
  /// Add a filter block that decides when to notify
  ///
  /// ```
  /// let filterBlock: FilterFunction<State> = { oldState, newState in
  ///   // Read a string from the oldState and newState
  ///   // oldState and newState are the full Store state
  ///   let value1 = oldState.value(forKey: "someKey", ofType: String.self)
  ///   let value2 = newState.value(forKey: "someKey", ofType: String.self)
  ///
  ///   // Compare
  ///   return value1 != value2
  /// }
  /// ```
  /// Add a listener with the state selector and
  ///
  /// ```
  /// let subscription = store.addListener(stateSelector: stateSelector) { newState in
  ///   // newState here is a TodoItemsState
  /// }
  /// ```
  public func addListener<StateType>(if filterBlock: FilterFunction<State>? = nil,
                                     stateSelector: @escaping StateSelector<StateType>,
                                     callback: @escaping (StateType) -> ()) -> Subscription<StateType> {
    return performAddListener(if: filterBlock,
                              stateSelector: stateSelector,
                              callback: callback)
  }


  /// Add a listener to the store. The listener will be notified when the state changes.
  /// The listener will be notified with the full state when 
  ///
  /// - Parameters:
  ///   - filterBlock: (Optional) block that receives the old state and the new state and it decides wether the notification for the listener should be sent or not.
  ///     When not set, the listener is notified whenever the state changed.
  ///   - callback: Notification block called with the new state when the store's state changed.
  /// - Returns: The Listener's subscription that can be used to remove the notification and for other listener related stuff.
  ///
  /// # Example
  ///
  /// ## Adding a listener
  /// Add a simple listener for the full state.
  ///
  /// ```
  /// let subscription = addListener { newState in
  ///   // Do something with the state
  ///
  ///   // Get value of Any? Type with key "TheKey"
  ///   let value1 = newState.value(forKey: "TheKey")
  ///
  ///   // Get value of MyState? Type with key "MyState" (Key value = the type of the state we want)
  ///   let value2 = newState.value(forKeyOfType: MyState.self)
  ///
  ///   // Get value of MyState? Type with key "TheKey"
  ///   let value3 = newState.value(forKey: "TheKey", ofType: MyState.self)
  /// }
  /// ```
  /// ## Adding a listener with a filterBlock
  /// Adding a listener for the full state with a filter block.
  /// In the filterBlock we check that the new state has more than 10 items.
  /// The Listener will be notified only if the filterBlock returns true.
  ///
  /// ```
  /// let subscription = store.addListener(if: { oldState, newState in
  ///
  ///   // Read values from the oldState and the newState
  ///   let old = oldState.value(forKeyOfType: TodoItemsState.self)!
  ///   let new = newState.value(forKeyOfType: TodoItemsState.self)!
  ///
  ///   return new.todos.count > 10
  /// }) { newState in
  ///   // Do something with the state
  /// }
  /// ```
  public func addListener(if filterBlock: FilterFunction<State>? = nil,
                          callback: @escaping (State) -> ()) -> Subscription<State> {
    return performAddListener(stateKey: nil,
                              type: State.self,
                              if: filterBlock,
                              callback: callback)
  }
  

  /// Add a new action listner to the store. Action listeners will be notified whenever a new action is dispatched.
  /// Inside the action notification you cast to the specific ation and read the payload of the action.
  ///
  /// - Parameter actionListener: Notification block called when an action happens.
  /// - Returns: The Listener's subscription that can be used to remove the notification and for other listener related stuff.
  ///
  /// # Example
  ///
  /// Add an action listener, this action listener will be notified when an action is dispatched.
  ///
  /// ```
  /// let subscription = addActionListener { action in
  ///
  ///   // Cast to some of your actions
  ///   if let action = action as? MyButtonClickedAction {
  ///   }
  ///
  ///   // Cast to some other action
  ///   if let action = action as? SomeOtherAction {
  ///   }
  /// }
  /// ```
  public func addActionListener(actionListener: @escaping ActionListenerFunction) -> ActionSubscription {
    let id = generateId()
    actionListeners[id] = actionListener
    return ActionSubscription(store: self, listenerId: id)
  }
}



/// Resetting State
extension Store {
  
  /// Reset the store internal state for a particular key. They key will be the dynamic type of state.
  ///
  /// - Parameter state: the new state
  public func reset(state: Any) {
    reset(state: state, forKey: "\(type(of: state))")
  }
  
  
  /// Reset the store internal state for a specific key
  ///
  /// - Parameters:
  ///   - state: the new state
  ///   - key: the state key to set
  public func reset(state: Any, forKey key: StateKey) {
    self.state[key] = state
  }
  
  
  /// Resets the full internal state with a new state
  ///
  /// - Parameter state: the state to reset to
  public func resetFullState(_ state: KeyedState) {
    self.state = State(dictionary: state)
  }
}

/// Action to dispatch to the store
///
/// # Example
///
/// ```
/// struct ButtonTappedAction: Action { }
///
/// store.dispatch(action: ButtonTappedAction())
/// ```
public protocol Action {}
