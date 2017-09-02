//
//  DetailViewController.swift
//  Forecast
//
//  Created by Stefan Iarca on 29/08/2017.
//  Copyright © 2017 Stefan Iarca. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityWrapperView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //The view controller's forecasted day
    fileprivate var day:Day?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = day?.getDayName()
        
        //Activity view needed
        if day != nil && (day!.checkExistingForecast() == false) {
            toggleActivityView(on: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Day setted via segue
    public func setForecastedDay(forecastedDay d:Day){
        day = d
    }
    
    //Hide or show activity indicator
    fileprivate func toggleActivityView(on:Bool){
        if on {
            activityIndicator.startAnimating()
        }else{
            activityIndicator.stopAnimating()
        }
        
        activityIndicator.isHidden = !on
        activityWrapperView.isHidden = !on
    }

}

extension DetailViewController: ForecastUpdateDelegate {
    //MARK: ForecastUpdateDelegate
    func didUpdateForecast() {
        collectionView.reloadData()
        toggleActivityView(on: false)
    }
}

extension DetailViewController: UICollectionViewDelegate {
    
}
extension DetailViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //Not yet loaded
        if day == nil || day!.daysForecast == nil {
            return 0
        }
        //Loaded and good to go
        return day!.daysForecast!.detailedForecastArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyForecastCollectionViewCell.reuseIdentifier, for: indexPath) as! HourlyForecastCollectionViewCell
        
        //Setup cell
        cell.setup(with: day?.daysForecast?.detailedForecastArray[indexPath.item])
        return cell
    
    }
}
