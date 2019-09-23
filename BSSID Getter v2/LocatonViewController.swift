//
//  LocatonViewController.swift
//  BSSID Getter v2
//
//  Created by Tyler Knox on 9/23/19.
//  Copyright © 2019 Tyler Knox. All rights reserved.
//

import UIKit
import CoreLocation

class LocatonViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager:CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        // Do any additional setup after loading the view.
    }
    @IBAction func allow(_ sender: Any) {
        
        
        
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            self.dismiss(animated: true, completion: nil)
        case .notDetermined:
            
            locationManager?.requestWhenInUseAuthorization()
        case .denied, .restricted:
            //Open settings
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
            
        @unknown default:
            fatalError()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            self.dismiss(animated: true, completion: nil)
        }
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
