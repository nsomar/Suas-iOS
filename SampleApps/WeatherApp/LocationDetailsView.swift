//
//  LocationDetailsView.swift
//  WeatherApp-iOS
//
//  Created by Omar Abdelhafith on 23/07/2017.
//  Copyright © 2017 Omar Abdelhafith. All rights reserved.
//

import UIKit
import Suas

class LocationDetailsView: UIView {

  var location: LocationDetails? {
    didSet {
      guard let location = location else { return }

      tempLabel.text = "\(location.temperature) in \(location.location)"
      weatherLabel.text = location.weather
      percipLabel.text = "Percip: \(location.weather)"
      windLabel.text = "Wind: \(location.wind)"

      URLSession(configuration: .default).dataTask(with: URL(string: location.iconUrl)!) { data, _, _ in
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
