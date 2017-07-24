//
//  State.swift
//  SuasIOS
//
//  Created by Omar Abdelhafith on 22/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation
import SuasMonitorMiddleware

struct FoundLocations: Encodable, SuasEncodable {
  var query: String
  var foundLocation: [Location]
}

struct MyLocations: Codable, SuasEncodable {
  var locations: [Location]
  var selectedLocation: LocationDetails?
}

struct Location: Codable, SuasEncodable {
  var name: String
  var lat: Float
  var lon: Float
  var query: String
}

struct LocationDetails: Codable, SuasEncodable {
  var temperature: String
  var location: String
  var weather: String
  var percipitation: String
  var wind: String
  var iconUrl: String
}
