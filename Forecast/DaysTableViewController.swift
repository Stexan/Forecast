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

    fileprivate let dBaseManager = DaysManager()
    private let locationManager = CLLocationManager()
    
    private var selectGrill = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = true
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        // Configure the cell...
        cell.setupWithDay(day: day)
        
        return cell
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "DayForecastSegue", sender: dBaseManager.getDaysArray()[indexPath.item])
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let dvc = segue.destination as? DetailViewController {
            
            dvc.setForecastedDay(forecastedDay:sender as! Day)
            dBaseManager.setForecastDelegate(delegate: dvc)
        }
    }
    
    @IBAction func grillButtonPressed(_ sender: UIBarButtonItem) {
        if sender.title == "Forecast"{
            sender.title = "Grill?"
            dBaseManager.toggleGrill(on: false)
            tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            tableView.reloadData()
        }else{
            sender.title = "Forecast"
            dBaseManager.toggleGrill(on: true)
            if dBaseManager.getDaysArray().count == 0 {
                tableView.tableFooterView = noGrillLabel()
            }
            tableView.reloadData()
        }
    }
    
    fileprivate func noGrillLabel() -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 80))
        label.textAlignment = .center
        
        label.text = "No grill soon guyzz :("
        
        if !dBaseManager.checkExistingForecast() {
            label.text = "Forecasts not yet available!"
        }
        return label
    }
    
    func refresh(){
        dBaseManager.updateForecasts()
    }
    

}

//MARK: ForecastUpdateDelegate
extension DaysTableViewController: ForecastUpdateDelegate {
    
    func didUpdateForecast() {
        refreshControl?.endRefreshing()
        tableView.reloadData()
        
        if ((tableView.tableFooterView as? UILabel) != nil) {
            tableView.tableFooterView = noGrillLabel()
        }
    }
}

extension DaysTableViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("app authorized!")
            manager.startUpdatingLocation()
        }else{
            print("app not authorized!")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.last == nil {
            handleFailLocation()
            print("invalid location array")
            return
        }
        
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
                manager.stopUpdatingLocation()
                let place = placemarks![0] as CLPlacemark
                
                if let locality = place.locality {
                    Location.setTown(town: locality)
                }
                if let country = place.country {
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
    
    private func handleFailLocation(){
        if dBaseManager.checkExistingForecast()  {
            dBaseManager.updateForecasts()
        }
    }
}


