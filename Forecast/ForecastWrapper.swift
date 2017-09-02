//
//  Forecast.swift
//  Forecast
//
//  Created by Stefan Iarca on 29/08/2017.
//  Copyright © 2017 Stefan Iarca. All rights reserved.
//

import UIKit

class ForecastWrapper: NSObject {
        
    let detailedForecastArray:Array<Forecast>
    
    public init(weather: Array<Dictionary<String,AnyObject>>) {
        var forecastArray:Array<Forecast> = []
        
        for weatherDict in weather {
            forecastArray.append(Forecast(detailedWeather: weatherDict))
        }
        
        detailedForecastArray = forecastArray
        super.init()
    }
    
    public func forecastGrillWeather() -> Bool {
        for dForecast in detailedForecastArray {
            if dForecast.goodForGrill() {
                return true
            }
        }
        return false
    }
    
}
