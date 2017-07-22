//
//  Middleware.swift
//  Suas-iOS-SampleApp
//
//  Created by Omar Abdelhafith on 20/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation
@testable import Suas

let loggerMiddleware = BlockMiddleware { action, api, next in
  print("\n==========================================================================")
  print("\nAction:\n\(action)")
  print("\nOld State:\n\(api.state)")
  next(action)
  print("\nNew State:\n\(api.state)")
  print("\n==========================================================================\n")
}
