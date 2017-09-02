//
//  DayTableViewCell.swift
//  Forecast
//
//  Created by Stefan Iarca on 29/08/2017.
//  Copyright © 2017 Stefan Iarca. All rights reserved.
//

import UIKit

class DayTableViewCell: UITableViewCell {

    public static var reuseIdentifier : String {
        return "DayCell"
    }
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var dayDateLabel: UILabel!
    @IBOutlet weak var dayNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    public func setupWithDay(day:Day){
        self.dayNameLabel.text = day.getDayName()
        self.dayDateLabel.text = day.getDayDate()
        
        if var relevantForecast = day.daysForecast?.detailedForecastArray.count{
            relevantForecast = relevantForecast / 2
            
            if let forecast = day.daysForecast?.detailedForecastArray[relevantForecast] {
                self.iconImageView?.image = forecast.getDescriptionImage()
            }else{
                self.iconImageView?.image = nil
            }
        }
    }
}
