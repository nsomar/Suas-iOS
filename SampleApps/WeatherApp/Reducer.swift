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

  func reduce(action: Action, state: FoundLocations) -> FoundLocations? {
    if let action = action as? LocationsAdded {
      var newState = state
      newState.foundLocation = action.locations
      newState.query = action.query
      return newState
    }

    return nil
  }
}

class MyLocationsReducer: Reducer {
  var initialState: MyLocations = MyLocations(locations: [], selectedLocation: nil)

  func reduce(action: Action, state: MyLocations) -> MyLocations? {

    if let action = action as? LocationSelected {
      var newState = state
      newState.locations += [action.location]
      return newState
    }

    if let action = action as? MyLocationsLoadedFromDisk {
      return action.locations
    }

    if let action = action as? ShowLocationDetails {
      var newState = state
      newState.selectedLocation = action.location
      return newState
    }

    return nil
  }
}
