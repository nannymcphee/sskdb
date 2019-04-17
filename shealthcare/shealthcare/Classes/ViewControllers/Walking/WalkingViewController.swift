//
//  WalkingViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 05/04/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit
import MBCircularProgressBar

import CoreMotion

import MapKit

extension WalkingViewController {
    // MARK: - function
    func display() {
        labelToday.text = Date().toString("yyyy.MM.dd (E)")
        
        viewProgress.maxValue = CGFloat(self.todayMaxValue)
        viewProgress.value = CGFloat(self.todayValue)
        
        self.labelTodayWalking.text = NSNumber(value: self.todayValue).comma
        
        let percent:CGFloat = CGFloat(self.yearValue) / CGFloat(self.yearMaxValue)
        barProgress(view: viewBar, percent: percent)
        self.labelYearPercent.text = String(format: "%d%%", Int(percent))
        self.labelYearWalking.text = String(format: "%@보/년", NSNumber(value: self.yearValue).comma)
        
        self.labelTodayCal.text = calorie(NSNumber(value: self.todayDistance))
        self.labelTodayDistince.text = distanceKm(NSNumber(value: self.todayDistance))
        self.labelTodayTime.text = walkingSecond(NSNumber(value: self.todayDistance))
    }
    func barProgress(view:UIView, percent:CGFloat) {
        let filteredConstraints = view.constraints.filter { $0.identifier == "width" }
        if let constraint = filteredConstraints.first {
            let newConstraint = constraint.constraintWithMultiplier(percent)
            view.removeConstraint(constraint)
            view.addConstraint(newConstraint)
            view.layoutIfNeeded()
        }
    }
    
    func distanceKm(_ distance:NSNumber) -> String {
        return String(format: "%.1f", distance.floatValue / 1000.0)
    }
    
    func calorie(_ distance:NSNumber) -> String {
        if let user = Global.UserInfo {
            let _weight:Float = Float(user["weightEnd"]!)!
            let calMile = 3.7103 + 0.2678 * _weight + (0.0359 * (_weight * 60 * 0.0006213) * 2) * _weight
            let cal = distance.floatValue * calMile * 0.0006213
            return String(format: "%.1f", cal)
        }
        return "0"
    }
    
    func walkingSecond(_ distance:NSNumber) -> String {
        let seconds = roundf(distance.floatValue * (165.0 * 0.0037)) / 1.1
        let hour = Int(seconds / 3600.0)
        let min = Int(seconds.truncatingRemainder(dividingBy: 3600.0) / 60.0)
        let sec = Int(seconds.truncatingRemainder(dividingBy: 3600.0).truncatingRemainder(dividingBy: 60.0))
        return String(format: "%02d:%02d:%02d", hour, min, sec)
    }
}

extension WalkingViewController: MKMapViewDelegate {
    
}
extension WalkingViewController: CLLocationManagerDelegate {
    
}

class WalkingViewController: UIViewController {
    
    @IBOutlet weak var viewContents: UIView!
    @IBOutlet weak var viewMapContents: UIView!
    
    
    @IBOutlet weak var labelToday: UILabel!
    
    @IBOutlet weak var viewProgress: MBCircularProgressBarView!
    
    @IBOutlet weak var viewBar: UIView!
    @IBOutlet weak var labelYearPercent: UILabel!
    @IBOutlet weak var labelYearWalking: UILabel!
    
    @IBOutlet weak var labelTodayCal: UILabel!
    @IBOutlet weak var labelTodayDistince: UILabel!
    @IBOutlet weak var labelTodayTime: UILabel!
    
    
    var todayMaxValue:Int = 10000
    var todayValue:Int = 0
    var todayDistance:Int = 0
    var yearMaxValue:Int = 3000000
    var yearValue:Int = 0
    
    var pedometerToday = CMPedometer()
    var pedometerYear = CMPedometer()
    
    
    let locationManager = CLLocationManager()
    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBOutlet weak var labelTodayWalking: UILabel!
    
    @IBOutlet weak var buttonStart: UIButton!
    @IBOutlet weak var buttonPause: UIButton!
    @IBOutlet weak var buttonStop: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        display()
        
//        let group = DispatchGroup()
        if CMPedometer.isStepCountingAvailable() {
            let startDateToday = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
            pedometerToday.startUpdates(from: startDateToday) { (data, error) in
                DispatchQueue.main.async(execute: {
                    if let data = data {
                        self.todayValue = data.numberOfSteps.intValue
                        self.todayDistance = data.distance!.intValue
                        self.display()
                    }
                })
            }
            let startDateYear = Date().toString("yyyy0101000000").toDate("yyyyMMddHHmmss")!
            pedometerYear.startUpdates(from: startDateYear) { (data, error) in
                DispatchQueue.main.async(execute: {
                    if let data = data {
                        self.yearValue = data.numberOfSteps.intValue
                        self.display()
                    }
                })
            }
        }
        
        self.viewContents.visibility = .visible
        self.viewMapContents.visibility = .gone
        self.buttonPause.visibility = .gone
        self.buttonStop.visibility = .gone
    }
    
    // MARK: - Action
    @IBAction func actionDismissButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionGraphButton(_ sender: Any) {
        let vc = UIStoryboard(name: "Walking", bundle: nil).instantiateViewController(withIdentifier: "WalkingGraphViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func actionGpsButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.viewMapContents.visibility = .visible
            self.viewContents.visibility = .gone
        } else {
            self.viewMapContents.visibility = .gone
            self.viewContents.visibility = .visible
        }
        
        
        if sender.isSelected {
            locationManager.delegate = self
            
            buttonStart.visibility = .visible
            buttonStop.visibility = .gone
            buttonPause.visibility = .gone
        } else {
            buttonStart.visibility = .gone
            buttonStop.visibility = .visible
            buttonPause.visibility = .visible
        }
    }
    
    
    @IBAction func actionStartButton(_ sender: Any) {
        locationManager.pausesLocationUpdatesAutomatically = false
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // 사용자의 현재위치 표시
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        buttonStart.visibility = .gone
        buttonStop.visibility = .visible
        buttonPause.visibility = .visible
    }
    
    @IBAction func actionPauseButton(_ sender: Any) {
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    @IBAction func actionStopButton(_ sender: Any) {
        buttonStart.visibility = .visible
        buttonStop.visibility = .gone
        buttonPause.visibility = .gone
        
        locationManager.stopUpdatingLocation()
        mapView.showsUserLocation = false
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
