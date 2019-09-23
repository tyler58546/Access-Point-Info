//
//  BSSIDIntentHandler.swift
//  BSSIDIntents
//
//  Created by Tyler Knox on 9/21/19.
//  Copyright © 2019 Tyler Knox. All rights reserved.
//

import Foundation
import SystemConfiguration.CaptiveNetwork

class BSSIDIntentHandler: NSObject, GetBSSIDIntentHandling {
    
    var names:[String:String] = [
        "4c:1:43:5c:b4:16":"Fireplace - 2.4Ghz",
        "4c:1:43:5c:b4:17":"Fireplace - 5 Ghz A",
        "4c:1:43:5c:b4:18":"Fireplace - 5Ghz B",
        "4c:1:43:77:5d:f6":"Office - 2.4Ghz",
        "4c:1:43:77:5d:f7":"Office - 5Ghz A",
        "4c:1:43:77:5d:f8":"Office - 5Ghz B",
        "f8:bb:bf:28:f0:46":"Master Bedroom - 2.4 Ghz",
        "f8:bb:bf:28:f0:47":"Master Bedroom - 5 Ghz A",
        "f8:bb:bf:28:f0:48":"Master Bedroom - 5 Ghz B",
        "4c:1:43:5b:db:96":"Garage - 2.4 Ghz",
        "4c:1:43:5b:db:97":"Garage - 5 Ghz A",
        "4c:1:43:5b:db:98":"Garage - 5 Ghz B",
        "14:22:db:69:8e:e5":"Front Patio - 2.4 Ghz",
        "14:22:db:69:8e:e6":"Front Patio - 5 Ghz",
        "14:22:db:69:8f:25":"Rooftop - 2.4 Ghz",
        "14:22:db:69:8f:26":"Rooftop - 5 Ghz"
    ]
    
    
    func handle(intent: GetBSSIDIntent,
                completion: @escaping (GetBSSIDIntentResponse) -> Void) {
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    if let name = names[interfaceInfo[kCNNetworkInfoKeyBSSID as String] as! String] {
                        completion(GetBSSIDIntentResponse.success(name: name))
                    } else {
                        completion(GetBSSIDIntentResponse.unknownBSSID(name: (interfaceInfo[kCNNetworkInfoKeyBSSID as String] as! String)))
                    }
                    return
                }
            }
        }
        completion(GetBSSIDIntentResponse.nowifi(message: ""))
    }
}
