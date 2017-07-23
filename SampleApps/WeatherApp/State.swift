//
//  State.swift
//  SuasIOS
//
//  Created by Omar Abdelhafith on 22/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation
import SuasMonitorMiddleware

struct WeatherState: Encodable, SuasEncodable {
  var foundLocations: FoundLocations
}

struct FoundLocations: Encodable, SuasEncodable {
  var query: String
  var foundLocation: [Location]
}

struct Location: Encodable, SuasEncodable {
  var name: String
  var lat: Float
  var lon: Float
}

struct Progress: Encodable, SuasEncodable {
  var count: Int
}
