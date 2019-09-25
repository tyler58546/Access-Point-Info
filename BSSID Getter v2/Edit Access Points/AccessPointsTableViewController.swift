//
//  AccessPointsTableViewController.swift
//  BSSID Getter v2
//
//  Created by Tyler Knox on 9/21/19.
//  Copyright © 2019 Tyler Knox. All rights reserved.
//

import UIKit

class AccessPointsTableViewController: UITableViewController {
    
    func getAccessPoints() -> AccessPointList {
        if let ap = AccessPointList.load() {
            return ap
        }
        let defaultAccessPoints = AccessPointList(fromDict: [
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
        ])
        defaultAccessPoints.save()
        return defaultAccessPoints
    }
    
    var data:AccessPointList = AccessPointList.empty()

    @IBAction func saveAccessPoint(_ segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func deleteAccessPoint(_ segue: UIStoryboardSegue) {
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openDetail" {
            if let dest = segue.destination as? AccessPointDetailTableViewController {
                dest.selectedAccessPoint = (sender as! AccessPointTableViewCell).accessPoint!
                dest.selectedAccessPointID = (sender as! AccessPointTableViewCell).id
                dest.prevView = self
            }
        }
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addItem(_ sender: Any) {
        var n = 1
        while (data.itemExists(withName: "Unnamed \(n)")) {
            n += 1
        }
        data.addItem(AccessPoint(name: "Unnamed \(n)", BSSID: ""))
        data.save()
        tableView.reloadData()
        let ip = IndexPath(row: data.getID(fromName: "Unnamed \(n)")!, section: 0)
        tableView.selectRow(at: ip, animated: true, scrollPosition: .bottom)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        data = getAccessPoints()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accessPoint", for: indexPath) as! AccessPointTableViewCell

        // Configure the cell...
        cell.accessPoint = 	data.data[indexPath.row]
        cell.id = indexPath.row

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            data.removeItem(id: indexPath.row)
            data.save()
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } /*else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    */
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
