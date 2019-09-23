//
//  AccessPoint.swift
//  BSSID Getter v2
//
//  Created by Tyler Knox on 9/21/19.
//  Copyright © 2019 Tyler Knox. All rights reserved.
//

import Foundation

class AccessPoint: NSObject, Codable, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(BSSID, forKey: "BSSID")
    }
    
    required init?(coder: NSCoder) {
        self.name = coder.decodeObject(forKey: "name") as! String
        self.BSSID = coder.decodeObject(forKey: "BSSID") as! String
    }
    
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
class AccessPointList: NSObject, Codable, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(data, forKey: "data")
    }
    
    required init?(coder: NSCoder) {
        self.data = (coder.decodeObject(forKey: "data") as? [AccessPoint]) ?? []
    }
    
    let supportsSecureCoding = true
    
    var data:[AccessPoint]
    /*init (fromNumberedDict data:[Int:[String:String]]) {
        var output:[Int:AccessPoint] = [:]
        for (id, accessPoint) in data {
            output[id] = AccessPoint(name: accessPoint.first!.value, BSSID: accessPoint.first!.key)
        }
        self.data = output
    }*/
    init (fromArray array:[AccessPoint]) {
        data = array
    }
    init (fromDict dict:[String:String]) {
        var output:[AccessPoint] = []
        for (bssid, name) in dict {
            output.append(AccessPoint(name: name, BSSID: bssid))
        }
        data = output
    }
    
    static func empty() -> AccessPointList {
        return AccessPointList(fromDict: [:])
    }
    
    func addItem(_ input:AccessPoint) {
        data.append(input)
    }
    func removeItem(id:Int) {
        data.remove(at: id)
    }
    
    func updateAccessPoint(id: Int, name: String, bssid:String) {
        data[id] = AccessPoint(name: name, BSSID: bssid)
    }
    
    func count() -> Int {
        return data.count
    }
    
    func itemExists(withName name:String) -> Bool {
        for accessPoint in data {
            if accessPoint.name == name {
                return true
            }
        }
        return false
    }
    
    func save() {
        print("saving: \(data)")
        do {
            let archived = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
            UserDefaults.standard.set(archived, forKey: "accessPoints")
        } catch {
            print("Error saving: \(error.localizedDescription)")
        }
        
        
    }
    static func load() -> AccessPointList? {
        if let loadData = UserDefaults.standard.value(forKey: "accessPoints") as? Data {
            guard let unarchived = NSKeyedUnarchiver.unarchiveObject(with: loadData) as? AccessPointList else {
                print("Failed to unarchive data")
                return nil
                
            }
            return unarchived
        }
        return nil
    }
    
    func getName(bssid: String) -> String? {
        for accessPoint in data {
            if accessPoint.BSSID == bssid {
                return accessPoint.name
            }
        }
        return nil
    }
    func getID(fromName name:String) -> Int? {
        var n = 0
        for accessPoint in data {
            if accessPoint.name == name {
                return n
            }
            n += 1
        }
        return nil
    }
}
