//
//  LocationDetailsViewController.swift
//  WeatherApp-iOS
//
//  Created by Omar Abdelhafith on 23/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import UIKit

class LocationDetailsViewController: UIViewController {
  var location: Location?

  override func viewDidLoad() {
    super.viewDidLoad()
    guard let location = location else { return }
    
    title = location.name
  }
}
