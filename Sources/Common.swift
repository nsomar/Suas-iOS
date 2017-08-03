//
//  Common.swift
//  ReDucks
//
//  Created by Omar Abdelhafith on 18/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation

public typealias StateKey = String
public typealias CallbackId = String

public typealias ListenerFunction<Type> = (Type) -> Void
public typealias ActionListenerFunction = (Action) -> Void
public typealias FilterFunction<StateType> = (StateType, StateType) -> Bool

public typealias StateSelector<SelectedType> =  (State) -> (SelectedType?)

public typealias KeyedState = [StateKey: Any]

public typealias ReducerFunction<Type> = (Type, Action) -> Type?
public typealias DispatchFunction = (Action) -> Void
public typealias NextFunction = DispatchFunction

public typealias MiddlewareFunction = (Action, GetStateFunction, DispatchFunction, NextFunction) -> Void
public typealias GetStateFunction = () -> State


extension Suas {
  // For testing
  static var fatalErrorHandler: (() -> ())? = nil

  static func log(_ string: @autoclosure () -> String) {
    #if DEBUG
      print("🔼 Suas: \(string())")
    #endif
  }

  static func fatalError() {
    #if DEBUG
      let fatalError = fatalErrorHandler ?? { Swift.fatalError() }
      fatalError()
    #else
    #endif
  }
}
