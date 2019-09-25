//
//  AccessPoint.swift
//  BSSID Getter v2
//
//  Created by Tyler Knox on 9/21/19.
//  Copyright © 2019 Tyler Knox. All rights reserved.
//

import Foundation
import UIKit

class AccessPoint: NSObject, Codable, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(BSSID, forKey: "BSSID")
        coder.encode(backgroundImageLocation, forKey: "backgroundImageLocation")
    }
    
    required init?(coder: NSCoder) {
        self.name = coder.decodeObject(forKey: "name") as! String
        self.BSSID = coder.decodeObject(forKey: "BSSID") as! String
        self.backgroundImageLocation = (coder.decodeObject(forKey: "backgroundImageLocation") as? String)
    }
    
    let name:String
    let BSSID:String
    var backgroundImageLocation:String?
    
    init(name:String,BSSID:String, backgroundImage:UIImage? = nil, backgroundImageLocation:String? = nil) {
        self.name = name
        self.BSSID = BSSID
        self.backgroundImageLocation = backgroundImageLocation
        super.init()
        if backgroundImage != nil {
            self.setImage(backgroundImage!)
        }
    }
    
    static func fromDict(_ dict:KeyValuePairs<String, String>) -> [AccessPoint] {
        var accessPoints:[AccessPoint] = []
        for (bssid,name) in dict {
            accessPoints.append(AccessPoint(name: name, BSSID: bssid))
        }
        print("----")
        return accessPoints
    }
    
    func getImage() -> UIImage? {
        if self.backgroundImageLocation == nil {
            return nil
            
        }
        do {
            
            let fileManager = FileManager.default
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent("\(self.backgroundImageLocation!)")
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
            
        } catch {
            print("Error loading image: \(error.localizedDescription)")
            return nil
        }
    }
    func setImage(_ image:UIImage) {
        //Save image
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent("\(self.BSSID.replacingOccurrences(of: ":", with: "-")).jpeg")
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                try imageData.write(to: fileURL)
                self.backgroundImageLocation = ("\(self.BSSID.replacingOccurrences(of: ":", with: "-")).jpeg")
                print("Saved image at: \(fileURL)")
            }
        } catch {
            print(error)
        }
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
    
    func updateAccessPoint(id: Int, name: String, bssid:String, backgroundImage:UIImage? = nil) {
        
        if backgroundImage == nil {
            let bg = data[id].backgroundImageLocation
            data[id] = AccessPoint(name: name, BSSID: bssid, backgroundImageLocation: bg)
            return
        }
        data[id] = AccessPoint(name: name, BSSID: bssid, backgroundImage: backgroundImage)
    }
    
    func updateImage(id: Int, image:UIImage) {
        data[id].setImage(image)
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
    func getImage(bssid: String) -> UIImage? {
        for accessPoint in data {
            if accessPoint.BSSID == bssid {
                return accessPoint.getImage()
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
