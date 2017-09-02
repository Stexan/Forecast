//
//  DetailViewController.swift
//  Forecast
//
//  Created by Stefan Iarca on 29/08/2017.
//  Copyright © 2017 Stefan Iarca. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController,ForecastUpdateDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityWrapperView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var day:Day?
    
    public func setForecastedDay(forecastedDay d:Day){
        day = d
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = day?.getDayName()
        
        if day != nil && (day!.checkExistingForecast() == false) {
            toggleActivityView(on: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: ForecastUpdateDelegate
    func didUpdateForecast() {
        collectionView.reloadData()
        toggleActivityView(on: false)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func toggleActivityView(on:Bool){
        if on {
            activityIndicator.startAnimating()
        }else{
            activityIndicator.stopAnimating()
        }
        
        activityIndicator.isHidden = !on
        activityWrapperView.isHidden = !on
    }

}

extension DetailViewController: UICollectionViewDelegate {
    
}
extension DetailViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if day == nil || day!.daysForecast == nil {
            return 0
        }
        return day!.daysForecast!.detailedForecastArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyForecastCollectionViewCell.reuseIdentifier, for: indexPath) as! HourlyForecastCollectionViewCell
        
        cell.setup(with: day?.daysForecast?.detailedForecastArray[indexPath.item])
        return cell
    
    }
}
