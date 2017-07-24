//
//  LocationsListViewController.swift
//  WeatherApp-iOS
//
//  Created by Omar Abdelhafith on 23/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import UIKit
import Suas

class LocationsListViewController: UITableViewController, Component {

  @IBOutlet var locationDetails: LocationDetailsView!

  var state: MyLocations = MyLocationsReducer().initialState {
    didSet {
      tableView.reloadData()
      if let selectedLocation = state.selectedLocation {
        tableView.tableHeaderView = locationDetails
        locationDetails.state = selectedLocation
      }
      store.dispatch(action: createSaveToDiskAction(locations: state))
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    locationDetails.removeFromSuperview()
    tableView.tableHeaderView = nil
    title = "My Cities"

    store.connect(component: self, notifier: compareNotifier)
    store.dispatch(action: createLoadFromDiskAction())
  }

//  func aa() {
//    let path = Bundle.main.path(forResource: "mockdetails", ofType: "json")!
//    let action = AsyncAction.fordiskRead(path: path) { data, dispatch in
//      let json = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
//      let currentInfo = json["current_observation"] as! [String: Any]
//
//      let location = LocationDetails(
//        temperature: currentInfo["temperature_string"] as! String,
//        location: (currentInfo["display_location"] as! [String: Any])["full"] as! String,
//        weather: currentInfo["weather"] as! String,
//        percipitation: currentInfo["wind_string"] as! String,
//        wind: currentInfo["precip_today_string"] as! String,
//        iconUrl: currentInfo["icon_url"] as! String
//      )
//      dispatch(ShowLocationDetails(location: location))
//    }
//    store.dispatch(action: action);
//  }
}

extension LocationsListViewController {

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return state.locations.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
    cell.location = state.locations[indexPath.row]
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let action = FetchLocationDetails(location: state.locations[indexPath.row])
    store.dispatch(action: action)
  }
}

class LocationCell: UITableViewCell {
  @IBOutlet weak var cityName: UILabel!

  var location: Location! {
    didSet {
      guard let l = location else { return }
      cityName.text = l.name
    }
  }
}
