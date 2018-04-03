//
//  EditPartyViewController.swift
//  Parti
//
//  Created by Liliana Terry on 4/1/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class EditPartyViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Firebase Database connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    // Firebase Storage connection
    var storageRef: StorageReference!
    var storageHandle: StorageHandle?
    
    var partyObject = PartyModel()
    
    @IBOutlet weak var partyImage: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var attireField: UITextField!
    @IBOutlet weak var dateTime: UIDatePicker!
    @IBAction func updateGuestList(_ sender: Any) {
        performSegue(withIdentifier: "updateGuestList", sender: self)
    }
    @IBAction func saveButton(_ sender: Any) {
        updatePartyInfo()
        performSegue(withIdentifier: "savePartySegue", sender: self)
    }
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    var imageDidChange = false
    
    
    /* Runs when page is loaded, sets the delegate and datasource then calls method to query
     Firebase and fetch this user's information */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set firebase references
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        // setup this page with the old profile information
        partyImage.image = partyObject.image
        // create circular mask on image
        self.partyImage.layer.cornerRadius = self.partyImage.frame.size.height / 2
        self.partyImage.clipsToBounds = true
        
        nameField.text = partyObject.name
        addressField.text = partyObject.address
        attireField.text = partyObject.attire
        
        dateTime.date = getDate(date: partyObject.date)
    }
    
    // *********** LET USER SELECT PROFILE IMAGE ***********
    
    /* Allows user to choose from their own images and set the UIImageView */
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        // allows user to crop image to square screen
        picker.allowsEditing = true
        
        present(picker, animated: false, completion: nil)
    }
    
    /* Triggers image picking screen when imageView is selected */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedPicture: UIImage?
        
        // Allows user to upload cropped image to make sure profile picture is square
        if let croppedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedPicture = croppedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedPicture = originalImage
        }
        
        // if a new image was selected, update Firebase and user's phone
        if let picture = selectedPicture {
            partyImage.image = picture
            imageDidChange = true
        }
        
        // Get rid of image picking screen
        dismiss(animated: false, completion: nil)
    }
    
    /* If user clicks on Cancel instead of selecting an image */
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // *********** QUERY FIREBASE ***********
    
    func updateFirebaseStorage() {
        let imageRef = storageRef.child("partyPictures/\(self.partyObject.partyID)")
        
        if let uploadData = UIImageJPEGRepresentation(partyImage.image!, 0.1) {
            imageRef.putData(uploadData, metadata: nil, completion: {
                (metadata, error) in
                
                if (error != nil) {
                    print(error)
                    return
                }
                
                // update user's profile URL in Firebase Database
                let imageURL = metadata?.downloadURL()?.absoluteString
                self.databaseRef.child("parties/\(self.partyObject.partyID)/imageURL").setValue(imageURL)
            })
        }
    }
    
    /* put date into string format for Firebase */
    private func formatDate() -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        let strDate = dateFormatter.string(from: dateTime.date)
        return strDate
    }
    
    /* get date object from date string */
    private func getDate(date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        let dateObject = dateFormatter.date(from: date)
        
        return dateObject!
    }
    
    /* If the user clicked save, update their information in Firebase */
    func updatePartyInfo() {
        // update name
        databaseRef.child("parties/\(partyObject.partyID)/name").setValue(nameField.text)
        
        partyObject.name = nameField.text!
        
        //update address
        databaseRef.child("parties/\(partyObject.partyID)/address").setValue(addressField.text)
        partyObject.address = addressField.text!
        
        // update attire
        databaseRef.child("parties/\(partyObject.partyID)/attire").setValue(attireField.text)
        partyObject.attire = attireField.text!
        
        let date = formatDate()
        databaseRef.child("parties/\(partyObject.partyID)/date").setValue(date)
        partyObject.date = date

        // update picture
        if (imageDidChange) {
            updateFirebaseStorage()
        }
        partyObject.image = partyImage.image!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueID = segue.identifier
        
        // add guests to the page
        if (segueID == "updateGuestList") {
            if let destinationVC = segue.destination as? AddGuestsToPartyViewController {
                partyObject.hostID = (Auth.auth().currentUser?.uid)!
                destinationVC.partyObject = partyObject
            }
        // save entire page 
        } else if (segueID == "savePartySegue") {
            if let destinationVC = segue.destination as? PartyHostViewController {
                destinationVC.partyObject = partyObject
            }
        }
    }
    
}
