//
//  CreatePartyViewController.swift
//  Parti
//
//  Created by Liliana Terry on 3/18/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class CreatePartyViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Firebase Database connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    // Firebase Storage connection
    var storageRef: StorageReference!
    var storageHandle: StorageHandle?
    
    var partyObject = PartyModel()
    
    @IBOutlet weak var partyImage: UIImageView!
    
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var attireField: UITextField!
    @IBOutlet weak var partyNameField: UITextField!
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    
    @IBAction func createPartyButton(_ sender: Any) {
        let filledOut = addressField.hasText && attireField.hasText && partyNameField.hasText
        if (filledOut) {
            let date = formatDate()
            
            let values = [
                "address": addressField.text!,
                "attire": attireField.text!,
                "name": partyNameField.text!,
                "date": date,
                "hostID": partyObject.hostID,
                "guestList": partyObject.guestList,
                "foodList": partyObject.foodList
                ] as [String : Any]
            
            // update Firebase accordingly
            self.databaseRef.child("parties/\(self.partyObject.partyID)").setValue(values)
            
            // update Image and store URL in party page 
            updateFirebaseStorage()
            
            // update user's party information
            let addParty = [partyObject.partyID: "1"]
            self.databaseRef.child("users/\(self.partyObject.hostID)/hosting").updateChildValues(addParty)
        } else {
            print("ERROR: address, attire, or name is blank")
        }
    }
    
    private func formatDate() -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        let strDate = dateFormatter.string(from: dateTimePicker.date)
        return strDate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set firebase references
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        // get a new ID for this party
        partyObject.partyID = UUID().uuidString
        
        setupPartyImage()
    }
    
    func setupPartyImage () {
        // create circular mask on image
        self.partyImage.layer.cornerRadius = self.partyImage.frame.size.width / 2
        self.partyImage.clipsToBounds = true
        
        // TODO CREATE WHITE BOARDER + DROP SHADOW
        
        // make party picture editable
        partyImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectImageView)))
        partyImage.isUserInteractionEnabled = true
    }
    
    // *********** LET USER SELECT PARTY IMAGE ***********
    
    /* Allows user to choose from their own images and set the UIImageView */
    @objc func handleSelectImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        // allows user to crop image to square screen
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
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
        }
        
        // Get rid of image picking screen
        dismiss(animated: true, completion: nil)
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
        print("Updating image in firebase storage")
        let imageRef = storageRef.child("partyPictures/\(self.partyObject.partyID)")
        
        if let uploadData = UIImagePNGRepresentation(self.partyImage.image!) {
            imageRef.putData(uploadData, metadata: nil, completion: {
                (metadata, error) in
                
                if (error != nil) {
                    print(error)
                    return
                }
                
                // update user's profile URL in Firebase Database
                print("Updating User's URL in Database")
                let imageURL = metadata?.downloadURL()?.absoluteString
                self.databaseRef.child("parties/\(self.partyObject.partyID)/imageURL").setValue(imageURL)
            })
        }
    }
    
}

