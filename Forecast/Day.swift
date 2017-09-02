//
//  Day.swift
//  Forecast
//
//  Created by Stefan Iarca on 29/08/2017.
//  Copyright © 2017 Stefan Iarca. All rights reserved.
//

import UIKit

class Day: NSObject {
    
    private(set) var daysForecast:ForecastWrapper?
    private let daysDate:Date
    //Override init to be name + date
    override var description: String {
        return getDayName() + "," + getDayDate()
    }
    //MARK: Initializer
    public init(with date:Date) {
        daysForecast = nil
        daysDate = date
        super.init()
        
    }
    
    //MARK: Date Getters
    //Get day name. If day is tomorrow or today, uses those names instead
    public func getDayName() -> String {
        if isDateAhead(daysAhead: 0) {
            return "Today"
        }
        if isDateAhead(daysAhead: 1) {
            return "Tomorrow"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        
        return formatter.string(from: daysDate)
    }
    
    //Get exact date
    public func getDayDate() -> String{
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        
        return formatter.string(from: daysDate)
    }
    
    //Check if day is "ahead" days ahead of today
    private func isDateAhead(daysAhead ahead:Int) -> Bool {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        //Today's date which we modify by adding "ahead" days to it
        let modToday = calendar.component(.day, from: (calendar.date(byAdding: .day, value: ahead, to: NSDate() as Date, options: []))! )
        //self's date
        let date = calendar.component(.day, from: daysDate)
        
        return (modToday == date)
    }
    
    //Set day's forecast
    public func updateForecast(new forecast:ForecastWrapper){
        daysForecast = forecast
    }
    
    //Check if the API returned any forecasts yet
    public func checkExistingForecast() -> Bool {
        return daysForecast != nil
    }
    
}
