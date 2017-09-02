//
//  DetailedForecast.swift
//  Forecast
//
//  Created by Stefan Iarca on 02/09/2017.
//  Copyright © 2017 Stefan Iarca. All rights reserved.
//

import UIKit

class Forecast: NSObject {

    static public func toCelsius(kelvin:Double) -> Double {
        return round(10 * (kelvin - 273.15)) / 10
    }
    
    static private let plistPath:String = Bundle.main.path(forResource: "Constants", ofType: "plist")!
    static private let plistTempString: String = "Good4Grill"
    static private let plistMinGrillString: String = "MinGrillHour"
    static private let plistMaxGrillString: String = "MaxGrillHour"
    
    private enum ForecastOverview : String {
        case Rain = "Rain"
        case Clear = "Clear"
        case Snow = "Snow"
        case Clouds = "Clouds"
        case Thunderstorm = "Thunderstorm"
        case Drizzle = "Drizzle"
        case Atmosphere = "Atmosphere"
        case Extreme = "Extreme"
        case Additional = "Additional"
    }
    
    let temperature:Double
    let tempMin:Double
    let tempMax:Double
    let hour:String
    
    private let weatherDescription:String
    private let overview:ForecastOverview
    
    override var description: String {
       return weatherDescription
    }
    
    public init(detailedWeather:Dictionary<String, AnyObject>){
        let mainDict = detailedWeather["main"] as! Dictionary<String, AnyObject>
        let dateString = (detailedWeather["dt_txt"] as! String).components(separatedBy: " ").last!
        let weatherDict = (detailedWeather["weather"] as! Array<Dictionary<String, AnyObject>>).first!
        
        temperature = Forecast.toCelsius(kelvin: (mainDict["temp"] as! Double))
        tempMax = Forecast.toCelsius(kelvin: (mainDict["temp_max"] as! Double))
        tempMin = Forecast.toCelsius(kelvin: (mainDict["temp_min"] as! Double))
        hour = dateString.components(separatedBy: ":")[0] + ":" + dateString.components(separatedBy: ":")[1]
        weatherDescription = weatherDict["description"] as! String
        overview = ForecastOverview(rawValue:weatherDict["main"] as! String)!
    }
    
    public func getDescriptionImage() -> UIImage {
        var imageString = overview.rawValue
        let hourComponent = Int(hour.components(separatedBy: ":").first!)!
        
        if overview == .Clear && (hourComponent > 20 || hourComponent < 6)  {
            imageString += "N"
        }
        
        return UIImage(named:imageString)!
    }
    
    public func goodForGrill() -> Bool {
        let plistData = FileManager.default.contents(atPath: Forecast.plistPath)
        do {
            let plistDict = try PropertyListSerialization.propertyList(from: plistData!, options: .mutableContainersAndLeaves, format: nil) as! [String:Any]
            let tresholdValue = plistDict[Forecast.plistTempString] as! Double
            let minHour = plistDict[Forecast.plistMinGrillString] as! Int
            let maxHour = plistDict[Forecast.plistMaxGrillString] as! Int
            
            let hourComponent = Int(hour.components(separatedBy: ":").first!)!
            
            return hourComponent > minHour && hourComponent < maxHour && (overview == .Clear && tresholdValue < self.temperature)
        } catch {
            fatalError("Error reading plist: \(error)")
        }
        
        
    }
}
