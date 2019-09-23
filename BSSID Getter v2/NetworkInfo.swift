//
//  NetworkInfo.swift
//  BSSID Getter v2
//
//  Created by Tyler Knox on 9/23/19.
//  Copyright © 2019 Tyler Knox. All rights reserved.
//

import Foundation
import SystemConfiguration.CaptiveNetwork

class NetworkInfo {
    var BSSID:String
    var ipAddress:String
    var SSID:String
    var isSimulated:Bool
    
    init(BSSID:String, ipAddress:String, SSID:String, isSimulated:Bool = false) {
        self.BSSID = BSSID
        self.ipAddress = ipAddress
        self.SSID = SSID
        self.isSimulated = isSimulated
    }
    static func simulated() -> NetworkInfo {
        return NetworkInfo(BSSID: "SIMULATED", ipAddress: "0.0.0.0", SSID: "Simulator WiFi", isSimulated: true)
    }
    func update() -> Bool {
        if isSimulated {return true}
        
        //Get BSSID and SSID
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    let bssid = interfaceInfo[kCNNetworkInfoKeyBSSID as String] as! String
                    self.BSSID = bssid
                    self.SSID = interfaceInfo[kCNNetworkInfoKeySSID as String] as! String
                } else {
                    return false
                }
            }
        } else {
            return false
        }
        
        //Get IP Address
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
        if address != nil {
            self.ipAddress = address!
            return true
        }
        
        return false
    }
    static func current() -> NetworkInfo? {
        let currentNetInfo = NetworkInfo(BSSID: "", ipAddress: "", SSID: "")
        if currentNetInfo.update() {
            return currentNetInfo
        }
        return nil
    }
}

