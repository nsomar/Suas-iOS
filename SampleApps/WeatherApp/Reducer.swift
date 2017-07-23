//
//  Reducer.swift
//  SuasIOS
//
//  Created by Omar Abdelhafith on 22/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation
import Suas

class FindLocationReducer: Reducer {
  var initialState: FoundLocations = FoundLocations(query: "", foundLocation: [])

  func reduce(action: Action, state: FoundLocations) -> FoundLocations {
    var newState = state

    if let action = action as? LocationsAdded {
      newState.foundLocation = action.locations
    }

    return newState
  }
  
}
