//
//  TestTypes.swift
//  SuasIOSTests
//
//  Created by Omar Abdelhafith on 19/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation
@testable import Suas

struct MyState1 {
  var value = 0
}

struct MyState2 {
  var blink = 0
}

struct MyState3 {
  var otherVal = 0
}

struct MyState4 {
  var yetMoreVal = 0
}

struct IncrementAction: Action {}

let reducer1 = BlockReducer(state: MyState1(value: 0)) { action, state in
  var newState = state

  if action is IncrementAction {
    newState.value = newState.value + 1
  }

  return newState
}

class Reducer1: Reducer {
  var initialState = MyState1(value: 10)

  func reduce(action: Action, state: MyState1) -> MyState1? {
    var newState = state
    if action is IncrementAction {
      newState.value += 20
    }
    return newState
  }
}

class Reducer2: Reducer {
  var initialState = MyState2(blink: 20)

  func reduce(action: Action, state: MyState2) -> MyState2? {
    var newState = state
    if action is IncrementAction {
      newState.blink += 40
    }
    return newState
  }
}

class Reducer1Nil: Reducer {
  var initialState = MyState1(value: 10)

  func reduce(action: Action, state: MyState1) -> MyState1? {
    return nil
  }
}

class Reducer3: Reducer {
  var initialState = MyState3(otherVal: 30)

  func reduce(action: Action, state: MyState3) -> MyState3? {
    var newState = state

    if action is IncrementAction {
      newState.otherVal += 60
    }

    return newState
  }
}

class Reducer3Nil: Reducer {
  var initialState = MyState3(otherVal: 30)

  func reduce(action: Action, state: MyState3) -> MyState3? {
    return nil
  }
}

class Reducer4: Reducer {
  var initialState = MyState4(yetMoreVal:40)

  func reduce(action: Action, state: MyState4) -> MyState4? {
    var newState = state

    if action is IncrementAction {
      newState.yetMoreVal += 70
    }

    return newState
  }
}



struct MyEquatableState1: Equatable, SuasDynamicEquatable {
  var val = 20

  static func ==(lhs: MyEquatableState1, rhs: MyEquatableState1) -> Bool {
    return lhs.val == rhs.val
  }
}

class EquatableReducer: Reducer {
  var initialState = MyEquatableState1(val: 50)

  func reduce(action: Action, state: MyEquatableState1) -> MyEquatableState1? {
    var newState = state

    if action is IncrementAction {
      newState.val += 70
    }

    return newState
  }
}

let middleware1 = BlockMiddleware { action, api, next in
  next(action)
}

let middleware2 = BlockMiddleware { action, api, next in
  next(action)
}
