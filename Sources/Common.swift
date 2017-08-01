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

public typealias StateConverter<ToType> =  (State) -> (ToType?)

public typealias KeyedState = [StateKey: Any]

public typealias ReducerFunction<Type> = (Action, Type) -> Type?
public typealias DispatchFunction = (Action) -> Void
public typealias NextFunction = DispatchFunction

public typealias MiddlewareFunction = (Action, GetStateFunction, DispatchFunction, NextFunction) -> Void
public typealias GetStateFunction = () -> State

extension Suas {
  static func log(_ string: @autoclosure () -> String) {
    #if DEBUG
      print("🔼 Suas: \(string())")
    #endif
  }
}
