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

  var state: MyLocations = MyLocationsReducer().initialState {
    didSet {
      tableView.reloadData()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "My Cities"

    store.connect(component: self)
    store.connectActionListener(toComponent: self) { action in
      if let action = action as? ShowLocationDetails {
        self.performSegue(withIdentifier: "showDetails", sender: action.location)
      }
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard
      let sender = sender as? Location,
      let vc = segue.destination as? LocationDetailsViewController
    else { return }

    vc.location = sender
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
    let action = ShowLocationDetails(location: state.locations[indexPath.row])
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
