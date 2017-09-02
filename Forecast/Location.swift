import UIKit

class Location: NSObject {

    static private let plistPath:String = Bundle.main.path(forResource: "Constants", ofType: "plist")!
    static private let defaultCountryKey: String = "DefaultCountry"
    static private let defaultTownKey: String = "DefaultTown"
    
    static private let countryKey = "Country"
    static private let townKey = "userTown"
    
    
    public class func setTown(town:String) {
        UserDefaults.standard.set(town, forKey: townKey)
    }
    
    public class func setCountry(country:String) {
        UserDefaults.standard.set(country, forKey: countryKey)
    }
    
    public class func getCountry() -> String {
        let country = UserDefaults.standard.object(forKey: countryKey)
        
        if (country as? String) != nil {
            return country as! String
        }
        
        return Location.getDefaultPlist()[defaultCountryKey] as! String
    }

    public class func getTown() -> String {
        let townString = UserDefaults.standard.object(forKey: townKey)
        if (townString as? String) != nil {
            return townString! as! String
        }
        return Location.getDefaultPlist()[defaultTownKey] as! String
    }
    
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
