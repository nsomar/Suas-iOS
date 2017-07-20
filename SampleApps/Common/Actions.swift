//
//  Actions.swift
//  Suas-iOS-SampleApp
//
//  Created by Omar Abdelhafith on 20/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation
#if os(macOS)
  @testable import SuasMac
#else
  @testable import SuasIOS
#endif

struct AddTodo: Action, SuasEncodable {
  let text: String

  func toDictionary() -> [String: Any] {
    return [
      "text": text
    ]
  }
}

struct ToggleTodo: Action, SuasEncodable {
  let index: Int
  
  func toDictionary() -> [String: Any] {
    return [
      "index": index
    ]
  }
}
