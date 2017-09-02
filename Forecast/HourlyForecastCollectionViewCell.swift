//
//  HourlyForecastCollectionViewCell.swift
//  Forecast
//
//  Created by Stefan Iarca on 02/09/2017.
//  Copyright © 2017 Stefan Iarca. All rights reserved.
//

import UIKit

class HourlyForecastCollectionViewCell: UICollectionViewCell {
    
    public static var reuseIdentifier = "HourlyForecastCell"
    
    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var maximumLabel: UILabel!
    @IBOutlet weak var minimumLabel: UILabel!
    
    //Setup cell
    public func setup(with hForecast:Forecast?) {
        if let unwrappedForecast = hForecast {
            hourLabel.text = unwrappedForecast.hour
            descriptionLabel.text = unwrappedForecast.description
            temperatureLabel.text = String(unwrappedForecast.temperature) + " °C"
            maximumLabel.text = String(unwrappedForecast.tempMin) + " °C"
            minimumLabel.text = String(unwrappedForecast.tempMax) + " °C"
            imageView.image = unwrappedForecast.getDescriptionImage()
            toggleHidden(on: false)
        }else{
            toggleHidden(on: true)
        }
    }
    
    //Hide all labels and the image view
    private func toggleHidden(on:Bool){
        wrapperView.isHidden = on
        imageView.isHidden = on
    }
}
