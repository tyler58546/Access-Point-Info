//
//  AccessPointDetailTableViewController.swift
//  BSSID Getter v2
//
//  Created by Tyler Knox on 9/21/19.
//  Copyright © 2019 Tyler Knox. All rights reserved.
//

import UIKit
import Photos

class AccessPointDetailTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    

    var selectedAccessPoint:AccessPoint?
    var selectedAccessPointID:Int?
    var newImage:UIImage? = nil
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var BSSIDField: UITextField!
    @IBOutlet weak var bgImage: UIImageView!
    
    @IBAction func enter(_ sender: Any) {
        if let s = sender as? UITextField {
            s.endEditing(false)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == IndexPath(row: 1, section: 1) {
            BSSIDField.text = NetworkInfo.current()?.BSSID ?? ""
            BSSIDField.endEditing(false)
            tableView.deselectRow(at: indexPath, animated: true)
        }
        if indexPath == IndexPath(row: 1, section: 2) {
            //Open image picker
            
            let photos = PHPhotoLibrary.authorizationStatus()
            if photos == .notDetermined {
                PHPhotoLibrary.requestAuthorization({status in
                    if status == .authorized{
                        DispatchQueue.main.async {
                            self.pickPhoto()
                        }
                        
                    } else {}
                })
            }
            if photos == .authorized {
                pickPhoto()
            }
            
            
            
            
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func pickPhoto() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
            
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            DispatchQueue.main.async {
                self.bgImage.image = pickedImage
            }
            newImage = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nameField.text = selectedAccessPoint?.name ?? ""
        BSSIDField.text = selectedAccessPoint?.BSSID ?? ""
        bgImage.image = selectedAccessPoint?.getImage() ?? UIImage(named: "grad")
        
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveAccessPoint" {
            if let dest = segue.destination as? AccessPointsTableViewController {
                dest.data.updateAccessPoint(id: selectedAccessPointID!, name: nameField.text ?? "", bssid: BSSIDField.text ?? "")
                if newImage != nil {
                    dest.data.updateImage(id: selectedAccessPointID!, image: newImage!)
                    
                    
                    
                }
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


