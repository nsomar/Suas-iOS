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
      newState.query = action.query
    }

    return newState
  }
}

class MyLocationsReducer: Reducer {
  var initialState: MyLocations = MyLocations(locations: [], selectedLocation: nil)

  func reduce(action: Action, state: MyLocations) -> MyLocations {
    var newState = state

    if let action = action as? LocationSelected {
      newState.locations += [action.location]
    }

    if let action = action as? ShowLocationDetails {
      newState.selectedLocation = action.location
    }

    return newState
  }
}
