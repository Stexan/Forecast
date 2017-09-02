//
//  DaysManager.swift
//  Forecast
//
//  Created by Stefan Iarca on 29/08/2017.
//  Copyright © 2017 Stefan Iarca. All rights reserved.
//

import UIKit

protocol ForecastUpdateDelegate {
    func didUpdateForecast()
}

class DaysManager: NSObject {
    
    //Default Number of days from plist
    static private let plistPath:String = Bundle.main.path(forResource: "Constants", ofType: "plist")!
    static private let plistNumberString: String = "DaysToForecast"
    
    //All the days to be forecasted
    fileprivate var daysArray = Array<Day>()
    
    //API Calls handler
    private let requestHandler = APIHandler()
    //Delegate which should update views when forecast is recieved
    fileprivate var forecastDelegate:ForecastUpdateDelegate?
    
    //Should return grill days
    private var grillDays:Bool = false
    
    //MARK: Initializers
    public convenience override init(){
        let plistData = FileManager.default.contents(atPath: DaysManager.plistPath)
        do {
            let plistDict = try PropertyListSerialization.propertyList(from: plistData!, options: .mutableContainersAndLeaves, format: nil) as! [String:Any]
            
            self.init(daysToInclude: (plistDict[DaysManager.plistNumberString] as! Int), forecastDelegate: nil)
        } catch {
            fatalError("Error reading plist: \(error)")
        }
    }
    
    public init(daysToInclude numberOfDays:Int,forecastDelegate updateDelegate:ForecastUpdateDelegate?){
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        for i in 0..<numberOfDays {
            if let date = calendar.date(byAdding: .day, value: i, to: NSDate() as Date, options: []) {
                daysArray.append(Day(with: date))
            }else{
                fatalError("Unable to create days!")
            }
        }
        forecastDelegate = updateDelegate
        super.init()
        requestHandler.delegate = self
    }
    //MARK: Getters And Setters
    
    //Get Days
    public func getDaysArray() ->Array<Day> {
        if grillDays {
            return daysArray.filter {$0.daysForecast != nil && $0.daysForecast!.forecastGrillWeather()}
        }
        return daysArray
    }
    
    //Set Forecast Delegate
    public func setForecastDelegate(delegate newDel:ForecastUpdateDelegate){
        forecastDelegate = newDel
    }
    
    public func toggleGrill(on:Bool){
        grillDays = on
    }
    
    //Make update request to API
    public func updateForecasts(){
        requestHandler.getWeather(town: Location.getTown(), country: Location.getCountry())
    }
    
    //Check if the API returned any forecast yet
    public func checkExistingForecast() -> Bool {
        if (self.daysArray.first != nil) {
            return self.daysArray.first!.checkExistingForecast()
        }
        return false
    }
}

extension DaysManager: APIDelegate {
    
    //MARK: APIDelegate
    //Success response function
    func handlerDidGetResults(results:Array<AnyObject>?){
        //Update days forecasts
        if let unwrappedResults = (results as? Array<ForecastWrapper>){
            for i in 0..<daysArray.count {
                if i > unwrappedResults.count {
                    return
                }
                daysArray[i].updateForecast(new: unwrappedResults[i])
            }
            //Notify delegate of the changes
            forecastDelegate?.didUpdateForecast()
        }
    }
    
    //Error function, present error in alert
    func handlerDidFailWithError(error:NSError?,description:String?){
        let alert = UIAlertController(title: "Error", message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
