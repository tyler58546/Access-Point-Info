//
//  AccessPointTableViewCell.swift
//  BSSID Getter v2
//
//  Created by Tyler Knox on 9/21/19.
//  Copyright © 2019 Tyler Knox. All rights reserved.
//

import UIKit

class AccessPointTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var BSSIDLabel: UILabel!
    var id:Int?
    
    var accessPoint:AccessPoint? {
        didSet {
            guard let accessPoint = accessPoint else { return }
            
            nameLabel.text = accessPoint.name
            BSSIDLabel.text = accessPoint.BSSID
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
