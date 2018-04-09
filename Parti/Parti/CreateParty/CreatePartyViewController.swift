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
import FirebaseAuth

class CreatePartyViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Firebase Database connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    // Firebase Storage connection
    var storageRef: StorageReference!
    var storageHandle: StorageHandle?
    
    var partyObject = PartyModel()
    
    @IBOutlet weak var partyImage: UIImageView!
    @IBOutlet weak var chooseImageButton: UIButton!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var attireLabel: UILabel!
    @IBOutlet weak var attireField: UITextField!
    @IBOutlet weak var partyNameLabel: UILabel!
    @IBOutlet weak var partyNameField: UITextField!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionField: UITextField!
    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    @IBAction func guestListButton(_ sender: Any) {
    
    }
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
            
            // update user's party information
            let addParty = [partyObject.partyID: 1]
            self.databaseRef.child("users/\(self.partyObject.hostID)/hosting").updateChildValues(addParty)
            
            // update Image and store URL in party page 
            updateFirebaseStorage()

        } else {
            print("ERROR: address, attire, or name is blank")
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set firebase references
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        // get a new ID for this party
        partyObject.partyID = UUID().uuidString
        partyObject.hostID = (Auth.auth().currentUser?.uid)!
        

        
        setupPartyImage()
        setupUX()
    }
    
    private func formatDate() -> Double {
        let dateFormatter = DateFormatter()
            
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        let dateMilli = datePicker.date.timeIntervalSinceReferenceDate

        return dateMilli
    }
    
    func setupUX() {
        addressField.setBottomBorder()
        attireField.setBottomBorder()
        partyNameField.setBottomBorder()
        descriptionField.setBottomBorder()
        
        let textColor = UIColor(hex: "636e72")
        partyNameLabel.textColor = textColor
        addressLabel.textColor = textColor
        attireLabel.textColor = textColor
        descriptionLabel.textColor = textColor
        dateLabel.textColor = textColor
        timeLabel.textColor = textColor
    }
    
    func setupPartyImage () {
        
        // TODO CREATE WHITE BOARDER + DROP SHADOW
        
        // make party picture editable
        chooseImageButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectImageView)))
        chooseImageButton.isUserInteractionEnabled = true
    }
    
    // *********** LET USER SELECT PARTY IMAGE ***********
    
    /* Allows user to choose from their own images and set the UIImageView */
    @objc func handleSelectImageView() {
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
                self.dismiss(animated: false, completion: nil)
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addGuestsNewParty" {
            let destinationVC = segue.destination as! GuestListViewController
            
        }
    }
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
}

extension UITextField {
    
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        let color = UIColor(hex: "b2bec3").cgColor
        self.layer.shadowColor = color
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
    
}




