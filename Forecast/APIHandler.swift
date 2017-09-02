//
//  APIHandler.swift
//  Forecast
//
//  Created by Stefan Iarca on 29/08/2017.
//  Copyright © 2017 Stefan Iarca. All rights reserved.
//
import UIKit

protocol APIDelegate : NSObjectProtocol{
    func handlerDidGetResults(results:Array<AnyObject>?);
    func handlerDidFailWithError(error:NSError?,description:String?);
}

class APIHandler: NSObject {
    //API constants
    private let WeatherServerAPI = "http://api.openweathermap.org/data/2.5/forecast?q="
    private let WeatherServerAPIKey = "&APPID=7bcac6120b188d53dff6ea9427ed7616"
    
    //Delegate to call
    var delegate: APIDelegate?;
    //Internal state handling
    private(set) var isQuerying = false
    
    //Call to update weather
    public func getWeather(town:String, country:String){
        //If it's already querying, don't query again
        if isQuerying{
            return
        }
        //Create the request string
        let requestString = WeatherServerAPI + town + "," + country + WeatherServerAPIKey
        
        //Start the request
        isQuerying = true
        executeQuery(withURL: URL.init(string:requestString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), respSelector: #selector(APIHandler.parseWeather(jsonResponse:)));
    }
    
    //Start query execution
    private func executeQuery(withURL queryURL:URL?,respSelector:Selector){
        //Check for problems with the url
        if queryURL == nil {
            delegate?.handlerDidFailWithError(error: nil, description: "Server Error")
            return
        }
        //Setup request
        var request:URLRequest = URLRequest.init(url: queryURL!);
        let session = URLSession.shared;
        request.httpMethod = "GET";
        request.timeoutInterval = 20
        
        //Start the querying task
        let task = session.dataTask(
            with: request,
            completionHandler: {(data, response, error) -> Void in
            //Once the task is started, we have to call the delegate back on the main thread as the task might have been started on another one
                
                if error != nil{
                    //Some error was found, fail
                    print(error!);
                    DispatchQueue.main.async(execute: {
                            self.delegate?.handlerDidFailWithError(error: error as NSError?,description: error.debugDescription);
                    });
                }
                
                if data != nil{
                    //Data recieved as JSON
                    do{
                        //Unwrap JSON
                        if let responseDict = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                            //print(responseDict);
                            
                            //perform the chosen selector to parse the JSON dictionary
                            DispatchQueue.main.async(execute: {
                                self.perform(respSelector, with: responseDict);
                            });
                            
                            
                        }else{
                            //JSON error
                            let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                            print("Error could not parse JSON: \(jsonStr ?? "Null Json String")")
                        }
                    } catch let parseError{
                        //JSON Parsing error
                        print(parseError);
                        let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                        print("Error could not parse JSON: \(jsonStr ?? "Null Json String")")
                    }
                }
                
                //print("Response: \(response)")
            }
        )
        
        task.resume()
    }
    

    //JSON Dictionary parsing fucntion
    func parseWeather(jsonResponse:NSDictionary){
        
        isQuerying = false
        var resultsArray:Array<ForecastWrapper> = []
        
        //Unwrap the weather list
        let weatherList = jsonResponse.object(forKey: "list") as! Array<Dictionary<String,AnyObject>>
        
        var oneForecastArray:Array<Dictionary<String, AnyObject>> = []
        var firstDayDelimiter = 0
        
        //The separation of the first day is needed as it might have fewer entries, if it's later than 00:00
        for i in 0..<weatherList.count {
            if getHour(dict: weatherList[i]) == "00"{
                resultsArray.append(ForecastWrapper(weather: oneForecastArray))
                oneForecastArray = []
                firstDayDelimiter = i
                break
            }
            oneForecastArray.append(weatherList[i])
        }
        
        
        //Weather every 3 hours for the rest of the days => 8 entries per day
        for i in 0..<weatherList.count - firstDayDelimiter {
            
            //On every 8th entry create a day's full forecast and clear the accumulator array for the next day
            if (i != 0 && i % 8 == 0) {
                let newF = ForecastWrapper(weather: oneForecastArray)
                resultsArray.append(newF)
                oneForecastArray = []
            }
            oneForecastArray.append(weatherList[i + firstDayDelimiter])
        }
        //Array filled, call the delegate's success function
        delegate?.handlerDidGetResults(results: resultsArray as Array<AnyObject>)
    }
    
    //Check internal state of the API
    public func queryOngoing() -> Bool {
        return isQuerying
    }
    
    //Convenience JSON unwrapping function
    private func getHour(dict: Dictionary<String, AnyObject>) -> String{
        let dateString = (dict["dt_txt"] as! String).components(separatedBy: " ").last!
        return dateString.components(separatedBy: ":").first!
    }
    
}
