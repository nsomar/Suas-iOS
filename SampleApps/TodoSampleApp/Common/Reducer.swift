//
//  Reducer.swift
//  Suas-iOS-SampleApp
//
//  Created by Omar Abdelhafith on 20/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation
import Suas


let todoReducer = BlockReducer(state: TodoState(todos:[])) { action, state in
  if let action = action as? AddTodo {
    var newState = state
    newState.todos = newState.todos + [Todo(title: action.text, isCompleted: false)]
    return newState
  }

  if let action = action as? ToggleTodo {
    var newState = state
    var post = newState.todos[action.index]
    post.isCompleted = !post.isCompleted
    newState.todos[action.index] = post
    return newState
  }

  return nil
}
