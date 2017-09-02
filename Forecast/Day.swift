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
    
    override var description: String {
        return getDayName() + "," + getDayDate()
    }
    
    public init(with date:Date) {
        daysForecast = nil
        daysDate = date
        super.init()
        
    }
    
    //MARK: Date Getters
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
    
    public func getDayDate() -> String{
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        
        return formatter.string(from: daysDate)
    }
    
    private func isDateAhead(daysAhead ahead:Int) -> Bool {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        
        let today = calendar.component(.day, from: (calendar.date(byAdding: .day, value: ahead, to: NSDate() as Date, options: []))! )
        let date = calendar.component(.day, from: daysDate)
        
        return (today == date)
    }
    
    public func updateForecast(new forecast:ForecastWrapper){
        daysForecast = forecast
    }
    
    public func checkExistingForecast() -> Bool {
        return daysForecast != nil
    }
    
}
