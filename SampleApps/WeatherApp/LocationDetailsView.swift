//
//  LocationDetailsView.swift
//  WeatherApp-iOS
//
//  Created by Omar Abdelhafith on 23/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import UIKit
import Suas

class LocationDetailsView: UIView, Component {

  static let empty = LocationDetails(temperature: "", location: "", weather: "", percipitation: "", wind: "", iconUrl: "")

  var state: LocationDetails = empty {
    didSet {
      tempLabel.text = "\(state.temperature) in \(state.location)"
      weatherLabel.text = state.weather
      percipLabel.text = "Percip: \(state.weather)"
      windLabel.text = "Wind: \(state.wind)"

      URLSession(configuration: .default).dataTask(with: URL(string: state.iconUrl)!) { data, _, _ in
        DispatchQueue.main.async {
          self.tempImage.image = UIImage(data: data!)
        }
      }.resume()
    }
  }

  @IBOutlet var tempLabel: UILabel!
  @IBOutlet var weatherLabel: UILabel!
  @IBOutlet var percipLabel: UILabel!
  @IBOutlet var windLabel: UILabel!
  @IBOutlet var tempImage: UIImageView!
}
