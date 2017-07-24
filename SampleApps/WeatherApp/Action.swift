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

struct LocationSelected: Action, Encodable, SuasEncodable {
  let location: Location
}

struct FetchLocationDetails: Action, Encodable, SuasEncodable {
  let location: Location
}

struct ShowLocationDetails: Action, Encodable, SuasEncodable {
  let location: LocationDetails
}

struct MyLocationsLoadedFromDisk: Action, Encodable, SuasEncodable {
  let locations: MyLocations
}

func createDummyAction() -> Action {
  let path = Bundle.main.path(forResource: "mockdetails", ofType: "json")!
  let action = AsyncAction.fordiskRead(path: path) { data, dispatch in
    let json = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
    let currentInfo = json["current_observation"] as! [String: Any]

    let location = LocationDetails(
      temperature: currentInfo["temperature_string"] as! String,
      location: (currentInfo["display_location"] as! [String: Any])["full"] as! String,
      weather: currentInfo["weather"] as! String,
      percipitation: currentInfo["wind_string"] as! String,
      wind: currentInfo["precip_today_string"] as! String,
      iconUrl: currentInfo["icon_url"] as! String
    )
    dispatch(ShowLocationDetails(location: location))
  }

  return action
}

func createFetchLocationDetailsAction(location: Location) -> Action {
  let url = URL(string: "http://api.wunderground.com/api/c57ef60f21274475/conditions/\(location.query).json")!
  let action = AsyncAction.forURLSession(url: url) { data, response, error, dispatch in
    guard let data = data else { return }

    let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    let currentInfo = json["current_observation"] as! [String: Any]

    let location = LocationDetails(
      temperature: currentInfo["temperature_string"] as! String,
      location: (currentInfo["display_location"] as! [String: Any])["full"] as! String,
      weather: currentInfo["weather"] as! String,
      percipitation: currentInfo["wind_string"] as! String,
      wind: currentInfo["precip_today_string"] as! String,
      iconUrl: currentInfo["icon_url"] as! String
    )
    dispatch(ShowLocationDetails(location: location))
  }

  return action
}

func createLoadFromDiskAction() -> Action {
  let path = NSHomeDirectory() + "/Documents/my_locations.json"
  let action = AsyncAction.fordiskRead(path: path) { data, dispatch in
    let locations = try! JSONDecoder().decode(MyLocations.self, from: data!)
    dispatch(MyLocationsLoadedFromDisk(locations: locations))
  }

  return action
}

func createSaveToDiskAction(locations: MyLocations) -> Action {
  let path = NSHomeDirectory() + "/Documents/my_locations.json"
  let data = try! JSONEncoder().encode(locations)
  let action = AsyncAction.fordiskWrite(path: path, data: data) { _, _ in
    // ignored
  }

  return action
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
