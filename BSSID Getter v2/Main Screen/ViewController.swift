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
    
    // Return IP address of WiFi interface (en0) as a String, or `nil`
    func getWiFiAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                let interface = ptr?.pointee
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    
                    if let name: String = String(cString: (interface?.ifa_name)!), name == "en0" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address
    }
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var BSSIDLabel: UILabel!
    @IBOutlet weak var addNameButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
   
    
    func getWiFiSsid() -> String? {
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    // Changed line below from the "ssid =" to return the value directly.
                    return interfaceInfo[kCNNetworkInfoKeyBSSID as String] as? String
                }
            }
        }
        // Changed this to return nil
        return nil
    }
    
    var names = AccessPointList.empty()
    var currentBSSID = ""
    
    @objc func reloadUI() {
        print("Reloading UI...")
        names = AccessPointList.load() ?? AccessPointList.empty()
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    let bssid = interfaceInfo[kCNNetworkInfoKeyBSSID as String] as! String
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
                    infoLabel.text = "SSID: \(interfaceInfo[kCNNetworkInfoKeySSID as String] as! String)\nIP Address: \(getWiFiAddress() ?? "N/A")"
                    return
                }
            }
        }
        label.text = "Not Connected"
        infoLabel.text = "You are not connected to a WiFi Network."
        BSSIDLabel.text = ""
        #if targetEnvironment(simulator)
        let bssid = "SIMULATOR"
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
        infoLabel.text = "SSID: Simulator WiFi\nIP Address: 0.0.0.0"
        #endif
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

