//
//  State.swift
//  Suas-iOS-SampleApp
//
//  Created by Omar Abdelhafith on 20/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation

struct Todo: SuasEncodable {
  var title: String
  var isCompleted: Bool

  func toDictionary() -> [String: Any] {
    return [
      "title": title,
      "isCompleted": isCompleted
    ]
  }
}

struct TodoState: SuasEncodable {
  var todos: [Todo]

  func toDictionary() -> [String: Any] {
    return [
      "todos": todos.map({ $0.toDictionary() })
    ]
  }
}

