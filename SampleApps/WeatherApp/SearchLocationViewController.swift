//
//  ViewController.swift
//  WeatherApp-iOS
//
//  Created by Omar Abdelhafith on 22/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import UIKit
import Suas


class SearchLocationViewController: UITableViewController, UISearchResultsUpdating, Component {

  var searchController: UISearchController!

  var state: FoundLocations = FoundLocations(query: "", foundLocation: []) {
    didSet {
      tableView.reloadData()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    searchController = UISearchController(searchResultsController: nil)
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    definesPresentationContext = true
    tableView.tableHeaderView = searchController.searchBar

    store.connect(component: self)
  }

  func updateSearchResults(for searchController: UISearchController) {
    let text = searchController.searchBar.text ?? ""
    guard text.characters.count > 2 else { return }

    let string = text.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
    let url = URL(string: "https://autocomplete.wunderground.com/aq?query=\(string)")!

    let action = AsyncAction.forURLSession(url: url) { data, resp, error, dispatch in
      let resp = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
      let result = resp["RESULTS"] as! [[String: Any]]

      let cities = result.map({
        Location(name: $0["name"] as! String,
                 lat: Float($0["lat"] as! String)!,
                 lon: Float($0["lon"] as! String)!)
      })

      dispatch(LocationsAdded(query: text, locations: cities))
    }
    
    store.dispatch(action: action)
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return state.foundLocation.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
    cell.textLabel?.text = state.foundLocation[indexPath.row].name
    return cell
  }
}
