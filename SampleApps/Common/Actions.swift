//
//  Actions.swift
//  Suas-iOS-SampleApp
//
//  Created by Omar Abdelhafith on 20/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation
@testable import Suas

struct AddTodo: Action {
  let text: String
}

struct ToggleTodo: Action {
  let index: Int
}
