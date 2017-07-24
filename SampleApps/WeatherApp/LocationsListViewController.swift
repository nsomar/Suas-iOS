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

  var state: MyLocations = store.state.valueOrFail(forKeyOfType: MyLocations.self) {
    didSet {
      tableView.reloadData()
      if let selectedLocation = state.selectedLocation {
        tableView.tableHeaderView = locationDetails
        locationDetails.location = selectedLocation
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    locationDetails.removeFromSuperview()
    tableView.tableHeaderView = nil
    title = "My Cities"

    store.connect(component: self)
    store.dispatch(action: createLoadFromDiskAction())

    store.addListener(withId: "storage", type: MyLocations.self) { locations in
      store.dispatch(action: createSaveToDiskAction(locations: locations))
    }
  }
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
    let action = createFetchLocationDetailsAction(location: state.locations[indexPath.row])
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
