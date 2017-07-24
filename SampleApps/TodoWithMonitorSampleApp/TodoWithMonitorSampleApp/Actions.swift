//
//  Actions.swift
//  Suas-iOS-SampleApp
//
//  Created by Omar Abdelhafith on 20/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation
import Suas
import SuasMonitorMiddleware

struct AddTodo: Action, SuasEncodable {
  let text: String

  func toDictionary() -> [String : Any] {
    return [
      "text": text
    ]
  }
}

struct ToggleTodo: Action, SuasEncodable {
  let index: Int

  func toDictionary() -> [String : Any] {
    return [
      "index": index
    ]
  }
}
