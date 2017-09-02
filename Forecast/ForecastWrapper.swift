//
//  Forecast.swift
//  Forecast
//
//  Created by Stefan Iarca on 29/08/2017.
//  Copyright © 2017 Stefan Iarca. All rights reserved.
//

import UIKit

//The class is a wrapper for the Forecast objects that a day has.
class ForecastWrapper: NSObject {
    
    let detailedForecastArray:Array<Forecast>
    
    //Initialize Forecasts with the JSON Dictionaries recieved form the API and add them to the object's array
    public init(weather: Array<Dictionary<String,AnyObject>>) {
        var forecastArray:Array<Forecast> = []
        
        for weatherDict in weather {
            forecastArray.append(Forecast(detailedWeather: weatherDict))
        }
        
        detailedForecastArray = forecastArray
        super.init()
    }
    
    //Check if any of the Forecasts has good grill weather
    public func forecastGrillWeather() -> Bool {
        for dForecast in detailedForecastArray {
            if dForecast.goodForGrill() {
                return true
            }
        }
        return false
    }
    
}
