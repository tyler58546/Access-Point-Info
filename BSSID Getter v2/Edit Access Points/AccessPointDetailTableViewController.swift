//
//  AccessPointDetailTableViewController.swift
//  BSSID Getter v2
//
//  Created by Tyler Knox on 9/21/19.
//  Copyright © 2019 Tyler Knox. All rights reserved.
//

import UIKit

class AccessPointDetailTableViewController: UITableViewController {

    var selectedAccessPoint:AccessPoint?
    var selectedAccessPointID:Int?
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var BSSIDField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        nameField.text = selectedAccessPoint?.name ?? ""
        BSSIDField.text = selectedAccessPoint?.BSSID ?? ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveAccessPoint" {
            if let dest = segue.destination as? AccessPointsTableViewController {
                dest.data.updateAccessPoint(id: selectedAccessPointID!, name: nameField.text ?? "", bssid: BSSIDField.text ?? "")
                dest.data.save()
                dest.tableView.reloadData()
            }
        }
        if segue.identifier == "deleteAccessPoint" {
            if let dest = segue.destination as? AccessPointsTableViewController {
                dest.data.removeItem(id: selectedAccessPointID!)
                dest.data.save()
                dest.tableView.reloadData()
            }
        }
    }

    

}
