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
    let WeatherServerAPI = "http://api.openweathermap.org/data/2.5/forecast?q="
    let WeatherServerAPIKey = "&APPID=7bcac6120b188d53dff6ea9427ed7616"
    
    var delegate: APIDelegate?;
    private(set) var isQuerying = false
    
    private func executeQuery(withURL queryURL:URL?,respSelector:Selector){
        
        if queryURL == nil {
            delegate?.handlerDidFailWithError(error: nil, description: "Server Error")
            return
        }
        
        var request:URLRequest = URLRequest.init(url: queryURL!);
        let session = URLSession.shared;
        request.httpMethod = "GET";
        request.timeoutInterval = 20
        
        
        let task = session.dataTask(
            with: request,
            completionHandler: {(data, response, error) -> Void in
                
                if error != nil{
                    print(error!);
                    DispatchQueue.main.async(execute: {
                            self.delegate?.handlerDidFailWithError(error: error as NSError?,description: error.debugDescription);
                    });
                }
                
                //assert(data != nil, "RESPONSE DATA IS NIL");
                if data != nil{
                    do{
                        if let responseDict = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                            //print(responseDict);
                            
                            DispatchQueue.main.async(execute: {
                                self.perform(respSelector, with: responseDict);
                            });
                            
                            
                        }else{
                            let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                            print("Error could not parse JSON: \(jsonStr ?? "Null Json String")")
                        }
                    } catch let parseError{
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

    public func getWeather(town:String, country:String){
        if isQuerying{
            return
        }
        
        let requestString = WeatherServerAPI + town + "," + country + WeatherServerAPIKey
        
        isQuerying = true
        executeQuery(withURL: URL.init(string:requestString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!), respSelector: #selector(APIHandler.parseWeather(jsonResponse:)));
    }
    
    func parseWeather(jsonResponse:NSDictionary){
        
        isQuerying = false
        var resultsArray:Array<ForecastWrapper> = []
        
        let weatherList = jsonResponse.object(forKey: "list") as! Array<Dictionary<String,AnyObject>>
        
        var oneForecastArray:Array<Dictionary<String, AnyObject>> = []
        var firstDayDelimiter = 0
        
        //First day weather
        for i in 0..<weatherList.count {
            if getHour(dict: weatherList[i]) == "00"{
                resultsArray.append(ForecastWrapper(weather: oneForecastArray))
                oneForecastArray = []
                firstDayDelimiter = i
                break
            }
            oneForecastArray.append(weatherList[i])
        }
        
        
        //Weather every 3 hours for the rest of the days
        for i in 0..<weatherList.count - firstDayDelimiter {
            
            if (i != 0 && i % 8 == 0) {
                let newF = ForecastWrapper(weather: oneForecastArray)
                resultsArray.append(newF)
                oneForecastArray = []
            }
            oneForecastArray.append(weatherList[i + firstDayDelimiter])
        }
        
        delegate?.handlerDidGetResults(results: resultsArray as Array<AnyObject>)
    }
    
    public func queryOngoing() -> Bool {
        return isQuerying
    }
    
    private func getHour(dict: Dictionary<String, AnyObject>) -> String{
        let dateString = (dict["dt_txt"] as! String).components(separatedBy: " ").last!
        return dateString.components(separatedBy: ":").first!
    }
    
}
