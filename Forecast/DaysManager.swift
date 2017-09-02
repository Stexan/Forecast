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

    static private let plistPath:String = Bundle.main.path(forResource: "Constants", ofType: "plist")!
    static private let plistNumberString: String = "DaysToForecast"
    
    fileprivate var daysArray = Array<Day>()
    fileprivate var grillDaysArray = Array<Day>()
    
    private let requestHandler = APIHandler()
    fileprivate var forecastDelegate:ForecastUpdateDelegate?
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
    
    public func getDaysArray() ->Array<Day> {
        if grillDays {
            return daysArray.filter {$0.daysForecast != nil && $0.daysForecast!.forecastGrillWeather()}
        }
        return daysArray
    }
    
    public func toggleGrill(on:Bool){
        grillDays = on
    }
    
    public func setForecastDelegate(delegate newDel:ForecastUpdateDelegate){
        forecastDelegate = newDel
    }
    
    public func updateForecasts(){
        requestHandler.getWeather(town: Location.getTown(), country: Location.getCountry())
    }
    
    public func checkExistingForecast() -> Bool {
        if (self.daysArray.first != nil) {
            return self.daysArray.first!.checkExistingForecast()
        }
        return false
    }
}

extension DaysManager: APIDelegate {
    
    //MARK: APIDelegate
    func handlerDidGetResults(results:Array<AnyObject>?){
        forecastDelegate?.didUpdateForecast()
        if let unwrappedResults = (results as? Array<ForecastWrapper>){
            for i in 0..<daysArray.count {
                daysArray[i].updateForecast(new: unwrappedResults[i])
            }
            forecastDelegate?.didUpdateForecast()
        }
    }
    
    func handlerDidFailWithError(error:NSError?,description:String?){
        let alert = UIAlertController(title: "Error", message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
