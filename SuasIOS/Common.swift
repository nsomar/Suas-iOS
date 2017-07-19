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

public typealias ListenerFunction = (Any) -> Void

public typealias KeyedState = [StateKey: Any]

public typealias ReducerFunction = (Action, Any) -> Any
public typealias TypedReducerFunction<Type> = (Action, Type) -> Type
public typealias ListenerNotifier = (Any, Any, Listener) -> Void
public typealias DispatchFunction = (Action) -> Void
public typealias MiddlewareFunction = (Action, MiddlewareAPI, DispatchFunction) -> Void
typealias GetStateFunction = () -> Any

infix operator |> : AdditionPrecedence

extension Suas {
  static func log(_ string: String) {
    print(string)
  }
}
