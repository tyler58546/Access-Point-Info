//
//  ViewController.swift
//  BSSID Getter v2
//
//  Created by Tyler Knox on 9/20/19.
//  Copyright © 2019 Tyler Knox. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork
import Intents
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager: CLLocationManager?
    var timer = Timer()
    
    
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var BSSIDLabel: UILabel!
    @IBOutlet weak var addNameButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var VFXView1: UIVisualEffectView!
    @IBOutlet weak var VFXView2: UIVisualEffectView!
    
   
    
    
    
    var names = AccessPointList.empty()
    var currentBSSID = ""
    
    @objc func reloadUI() {
        print("Reloading UI...")
        names = AccessPointList.load() ?? AccessPointList.empty()
        var current = NetworkInfo.current()
        #if targetEnvironment(simulator)
        current = NetworkInfo.simulated()
        #endif
        
        if let netInfo = current {
            let bssid = netInfo.BSSID
            currentBSSID = bssid
            
            if let name = names.getName(bssid: bssid) {
                label.text = name
                BSSIDLabel.text = bssid
                addNameButton.isHidden = true
            } else {
                label.text = bssid
                BSSIDLabel.text = ""
                addNameButton.isHidden = false
            }
            background.image = names.getImage(bssid: bssid)
            infoLabel.text = "SSID: \(netInfo.SSID)\nIP Address: \(netInfo.ipAddress)"
            if #available(iOS 13.0, *) {
                VFXView1.effect = UIBlurEffect(style: .systemThinMaterial)
                VFXView2.effect = UIBlurEffect(style: .systemThinMaterial)
            } else {
                // Fallback on earlier versions
                VFXView1.effect = UIBlurEffect(style: .extraLight)
                VFXView2.effect = UIBlurEffect(style: .extraLight)
            }
            
            if background.image == nil {
                VFXView1.effect = nil
                VFXView2.effect = nil
            }
            return
        }
        VFXView1.effect = nil
        VFXView2.effect = nil
        background.image = nil
        label.text = "Not Connected"
        infoLabel.text = "You are not connected to a WiFi Network."
        BSSIDLabel.text = ""
    }
    
    @IBAction func addName(_ sender: Any) {
        let alert = UIAlertController(title: "Enter a name for this access point:", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = ""
        })

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in

            if let name = alert.textFields?.first?.text {
                if name == "" { return }
                let data = AccessPointList.load() ?? AccessPointList.empty()
                data.addItem(AccessPoint(name: name, BSSID: self.currentBSSID))
                data.save()
                self.reloadUI()
            }
        }))

        self.present(alert, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(NSHomeDirectory())
        reloadUI()
        
        if #available(iOS 13.0, *) {
            //Use system settings icon
        } else {
            //Use custom settings icon
            settingsButton.setImage(UIImage(imageLiteralResourceName: "Settings"), for: .normal)
        }
        
        
        //Donate intent thing
        let intent = GetBSSIDIntent()
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate(completion: nil)
        
        VFXView1.clipsToBounds = true
        VFXView1.layer.cornerRadius = 10
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        timer.invalidate()
        
        
        
        
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(reloadUI), userInfo: nil, repeats: true)
        reloadUI()
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        if #available(iOS 13.0, *) {
            if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "LocationViewController") as! LocatonViewController
                newViewController.isModalInPresentation = true
                newViewController.modalPresentationStyle = .fullScreen
                self.present(newViewController, animated: false, completion: nil)
            }
        }
    }

}

