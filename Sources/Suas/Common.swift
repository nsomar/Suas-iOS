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
public typealias ListenerNotifier<State> = (State, State, Listener) -> Void

public typealias KeyedState = [StateKey: Any]

public typealias ReducerFunction = (Action, Any) -> Any
public typealias TypedReducerFunction<Type> = (Action, Type) -> Type
public typealias DispatchFunction = (Action) -> Void
public typealias NextFunction = DispatchFunction

public typealias MiddlewareFunction = (Action, MiddlewareAPI, NextFunction) -> Void
typealias GetStateFunction = () -> StoreState

infix operator |> : AdditionPrecedence

extension Suas {
  static func log(_ string: String) {
    print("Suas Log: \(string)")
  }
}
