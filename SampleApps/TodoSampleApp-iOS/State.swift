//
//  State.swift
//  Suas-iOS-SampleApp
//
//  Created by Omar Abdelhafith on 20/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation

struct Post {
  var title: String
  var isCompleted: Bool
}

struct TodoState {
  var posts: [Post]
}

