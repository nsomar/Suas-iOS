//
//  Action.swift
//  SuasIOS
//
//  Created by Omar Abdelhafith on 22/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import Foundation
import Suas
import SuasMonitorMiddleware

struct SearchForLocations: Action, Encodable, SuasEncodable {
  var query: String
}

struct LocationsAdded: Action, Encodable, SuasEncodable {
  var query: String
  var locations: [Location]
}

public extension Encodable {
  public func toDictionary() -> [String : Any] {
    guard
      let data = try? JSONEncoder().encode(self),
      let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
      else {
        return ["_": "_"]
    }

    return json
  }
}
