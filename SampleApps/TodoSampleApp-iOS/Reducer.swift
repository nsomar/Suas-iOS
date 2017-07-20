//
//  Reducer.swift
//  Suas-iOS-SampleApp
//
//  Created by Omar Abdelhafith on 20/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation
import SuasIOS

let emptyState = TodoState(posts:[])

let todoReducer = BlockReducer(state: emptyState) { action, state in
  var newState = state

  if let action = action as? AddTodo {
    newState.posts = newState.posts + [Post(title: action.text, isCompleted: false)]
  }

  if let action = action as? ToggleTodo {
    var post = newState.posts[action.index]
    post.isCompleted = !post.isCompleted
    newState.posts[action.index] = post
  }

  return newState
}
