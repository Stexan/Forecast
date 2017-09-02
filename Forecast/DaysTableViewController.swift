//
//  DaysTableViewController.swift
//  Forecast
//
//  Created by Stefan Iarca on 29/08/2017.
//  Copyright © 2017 Stefan Iarca. All rights reserved.
//

import UIKit
import CoreLocation

class DaysTableViewController: UITableViewController {

    //Object that keeps the days
    fileprivate let dBaseManager = DaysManager()
    
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TableView Setup
        self.clearsSelectionOnViewWillAppear = true
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        //Also include refresh controls
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        //LocationManager Setup
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Register self as a delegate in order to update views when needed
        dBaseManager.setForecastDelegate(delegate: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dBaseManager.getDaysArray().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DayTableViewCell.reuseIdentifier, for: indexPath) as! DayTableViewCell

        let day = dBaseManager.getDaysArray()[indexPath.item]
        // Configure the cell
        cell.setupWithDay(day: day)
        
        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Cell clicked, go to detailed description
        performSegue(withIdentifier: "DayForecastSegue", sender: dBaseManager.getDaysArray()[indexPath.item])
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller and set it's day
        if let dvc = segue.destination as? DetailViewController {
            
            dvc.setForecastedDay(forecastedDay:sender as! Day)
            dBaseManager.setForecastDelegate(delegate: dvc)
        }
    }
    
    //MARK: Grill handling
    @IBAction func grillButtonPressed(_ sender: UIBarButtonItem) {
        if sender.title == "Forecast"{
            sender.title = "Grill?"
            
            //We want to go back to the normal Forecast list
            dBaseManager.toggleGrill(on: false)
            
            //Reset tavlewView Footer
            tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            tableView.reloadData()
        }else{
            sender.title = "Forecast"
            //Want to go to the Grill list
            dBaseManager.toggleGrill(on: true)
            
            //If there are no good grill days, set the funny label
            if dBaseManager.getDaysArray().count == 0 {
                tableView.tableFooterView = noGrillLabel()
            }
            tableView.reloadData()
        }
    }
    
    //Funny label setup
    fileprivate func noGrillLabel() -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 80))
        label.textAlignment = .center
        
        label.text = "No grill soon guyzz :("
        
        //Check if there are no forecasts in list because the API didn't yet respond
        if !dBaseManager.checkExistingForecast() {
            label.text = "Forecasts not yet available!"
        }
        return label
    }
    
    //MARK: RefreshControl function
    func refresh(){
        dBaseManager.updateForecasts()
    }
}

//MARK: ForecastUpdateDelegate
extension DaysTableViewController: ForecastUpdateDelegate {
    
    //Called when a new forecast was recieved
    func didUpdateForecast() {
        refreshControl?.endRefreshing()
        tableView.reloadData()
        
        //If grill mode was on and the API response only now comes, update label accordingly
        if ((tableView.tableFooterView as? UILabel) != nil) {
            //If there are still no days update the label
            if dBaseManager.getDaysArray().count == 0 {
                tableView.tableFooterView = noGrillLabel()
            }else {
                //Else fill the footer with the dummy view
                tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            }
            
        }
    }
}

extension DaysTableViewController: CLLocationManagerDelegate {
    
    //Start updating location when permission is given
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("app authorized!")
            manager.startUpdatingLocation()
        }else{
            print("app not authorized!")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Check if location exists
        if locations.last == nil {
            handleFailLocation()
            print("invalid location array")
            return
        }
        //Get City and Country from location
        CLGeocoder().reverseGeocodeLocation(locations.last!, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                self.handleFailLocation()
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            if placemarks == nil {
                self.handleFailLocation()
                print("No placemarks found")
                return
            }
            
            if placemarks!.count > 0 {
                //Managed to find the placemark, stop updating location
                manager.stopUpdatingLocation()
                let place = placemarks![0] as CLPlacemark
                
                if let locality = place.locality {
                    //Update City
                    Location.setTown(town: locality)
                }
                if let country = place.country {
                    //Update Country
                    Location.setCountry(country: country)
                }
                
                self.dBaseManager.updateForecasts()
            } else {
                self.handleFailLocation()
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        handleFailLocation()
        print(error)
    }
    
    //Get weather with default values if location fails
    private func handleFailLocation(){
        if dBaseManager.checkExistingForecast()  {
            dBaseManager.updateForecasts()
        }
    }
}


