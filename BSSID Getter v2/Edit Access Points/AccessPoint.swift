//
//  AccessPoint.swift
//  BSSID Getter v2
//
//  Created by Tyler Knox on 9/21/19.
//  Copyright © 2019 Tyler Knox. All rights reserved.
//

import Foundation

class AccessPoint {
    let name:String
    let BSSID:String
    
    init(name:String,BSSID:String) {
        self.name = name
        self.BSSID = BSSID
    }
    
    static func fromDict(_ dict:KeyValuePairs<String, String>) -> [AccessPoint] {
        var accessPoints:[AccessPoint] = []
        for (bssid,name) in dict {
            accessPoints.append(AccessPoint(name: name, BSSID: bssid))
        }
        print("----")
        return accessPoints
    }
}
class AccessPointList {
    var data:[Int:AccessPoint]
    init (fromNumberedDict data:[Int:[String:String]]) {
        var output:[Int:AccessPoint] = [:]
        for (id, accessPoint) in data {
            output[id] = AccessPoint(name: accessPoint.first!.value, BSSID: accessPoint.first!.key)
        }
        self.data = output
    }
    init (fromDict dict:[String:String]) {
        var n = 0
        var output:[Int:AccessPoint] = [:]
        for (bssid, name) in dict {
            output[n] = AccessPoint(name: name, BSSID: bssid)
            n += 1
        }
        data = output
    }
    
    static func empty() -> AccessPointList {
        return AccessPointList(fromDict: [:])
    }
    
    func addItem(_ input:AccessPoint) {
        let max = data.keys.max()!
        data[max + 1] = input
    }
    func removeItem(id:Int) {
        data[id] = nil
        var n = data.keys.max()!
        if n >= data.keys.max()! {
            return
        }
        
        var newdata = data
        newdata[n] = nil
        while (n > id) {
            newdata[n-1] = data[n]
            n -= 1
        }
        newdata[id] = data[id+1]
        data = newdata
    }
    
    func updateAccessPoint(id: Int, name: String, bssid:String) {
        data[id] = AccessPoint(name: name, BSSID: bssid)
    }
    
    func count() -> Int {
        return data.count
    }
    
    func itemExists(withName name:String) -> Bool {
        for (_, accessPoint) in data {
            if accessPoint.name == name {
                return true
            }
        }
        return false
    }
    
    func save() {
        var saveData:[Int:[String:String]] = [:]
        for (id, accessPoint) in data {
            saveData[id] = [accessPoint.BSSID:accessPoint.name]
        }
        do {
            let archived = try NSKeyedArchiver.archivedData(withRootObject: saveData, requiringSecureCoding: true)
            UserDefaults.standard.set(archived, forKey: "save")
        } catch {
            print(error.localizedDescription)
        }
        
        
    }
    static func load() -> AccessPointList? {
        if let loadData = UserDefaults.standard.value(forKey: "save") as? Data {
            let unarchived = NSKeyedUnarchiver.unarchiveObject(with: loadData) as! [Int:[String:String]]
            return AccessPointList(fromNumberedDict: unarchived)
        }
        return nil
    }
    
    func getName(bssid: String) -> String? {
        for (_, accessPoint) in data {
            if accessPoint.BSSID == bssid {
                return accessPoint.name
            }
        }
        return nil
    }
    func getID(fromName name:String) -> Int? {
        for (id, accessPoint) in data {
            if accessPoint.name == name {
                return id
            }
        }
        return nil
    }
}
