//
//  Reducer.swift
//  Suas-iOS-SampleApp
//
//  Created by Omar Abdelhafith on 20/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation
@testable import Suas

let emptyState = TodoState(todos:[])

let todoReducer = BlockReducer(state: emptyState) { action, state in
  var newState = state

  if let action = action as? AddTodo {
    newState.todos = newState.todos + [Todo(title: action.text, isCompleted: false)]
  }

  if let action = action as? ToggleTodo {
    var post = newState.todos[action.index]
    post.isCompleted = !post.isCompleted
    newState.todos[action.index] = post
  }

  return newState
}
