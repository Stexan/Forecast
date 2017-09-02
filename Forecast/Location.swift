import UIKit

//This class is a used as a wrapper around UserDefaults in order to easily handle storing the location locally
//If no location is available, the Constants.plist default location is used
class Location: NSObject {
    
    //Default Location from plist
    static private let plistPath:String = Bundle.main.path(forResource: "Constants", ofType: "plist")!
    static private let defaultCountryKey: String = "DefaultCountry"
    static private let defaultTownKey: String = "DefaultTown"
    
    //User Defaults Keys
    static private let countryKey = "Country"
    static private let townKey = "userTown"
    
    //Set new town
    public class func setTown(town:String) {
        UserDefaults.standard.set(town, forKey: townKey)
    }
    
    //Set new country
    public class func setCountry(country:String) {
        UserDefaults.standard.set(country, forKey: countryKey)
    }
    
    //Get current country from UserDefaults
    public class func getCountry() -> String {
        let country = UserDefaults.standard.object(forKey: countryKey)
        
        if (country as? String) != nil {
            return country as! String
        }
        
        //If no country is available, get it from the plist
        return Location.getDefaultPlist()[defaultCountryKey] as! String
    }

    //Get current town from UserDefaults
    public class func getTown() -> String {
        let townString = UserDefaults.standard.object(forKey: townKey)
        
        if (townString as? String) != nil {
            return townString! as! String
        }
        //If no town is available, get it from the plist
        return Location.getDefaultPlist()[defaultTownKey] as! String
    }
    
    //Convenience method used to get the Constants.plist
    private class func getDefaultPlist() -> [String:Any] {
        let plistData = FileManager.default.contents(atPath: Location.plistPath)
        do {
            let plistDict = try PropertyListSerialization.propertyList(from: plistData!, options: .mutableContainersAndLeaves, format: nil) as! [String:Any]
            
            return plistDict
        } catch {
            fatalError("Error reading plist: \(error)")
        }
    }
    
}
