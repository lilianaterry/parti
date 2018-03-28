//
//  EditProfileViewController.swift
//  Parti
//
//  Created by Liliana Terry on 3/27/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Firebase Database connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    // Firebase Storage connection
    var storageRef: StorageReference!
    var storageHandle: StorageHandle?
    
    var profileObject = ProfileModel()
    
    // dietary restriction buttons
    @IBOutlet weak var nutsButton: UIButton!
    @IBOutlet weak var glutenButton: UIButton!
    @IBOutlet weak var vegetarianButton: UIButton!
    @IBOutlet weak var lactoseButton: UIButton!
    @IBOutlet weak var veganButton: UIButton!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var drinkField: UITextField!
    @IBOutlet weak var trickField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var imageDidChange = false
    
    let allergyList = ["Nuts", "Gluten", "Vegetarian", "Dairy", "Vegan"]
    var allergyIcons = [UIButton]()
    var allergyChanges = [0,0,0,0,0]

    
    /* Runs when page is loaded, sets the delegate and datasource then calls method to query
     Firebase and fetch this user's information */
    override func viewDidLoad() {
        super.viewDidLoad()
        print("IN VIEW DID LOAD")
        
        // set firebase references
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()

        // setup this page with the old profile information
        profileImage.image = profileObject.image
        nameField.text = profileObject.name
        drinkField.text = profileObject.drink
        trickField.text = profileObject.trick
        
        emailField.text = Auth.auth().currentUser?.email
        
        allergyIcons = [nutsButton, glutenButton, vegetarianButton, lactoseButton, veganButton]
        
        setupAllergyIcons()
        colorIcons()
    }
    
    /* Adds color selection functionality to allergy icons */
    func setupAllergyIcons() {
        nutsButton.setImage(#imageLiteral(resourceName: "nuts-orange.png"), for: .selected)
        nutsButton.setImage(#imageLiteral(resourceName: "nut-free"), for: .normal)
        nutsButton.tag = 0
        glutenButton.setImage(#imageLiteral(resourceName: "gluten-yellow"), for: .selected)
        glutenButton.setImage(#imageLiteral(resourceName: "gluten-free"), for: .normal)
        glutenButton.tag = 1
        vegetarianButton.setImage(#imageLiteral(resourceName: "veggie-green"), for: .selected)
        vegetarianButton.setImage(#imageLiteral(resourceName: "vegetarian"), for: .normal)
        vegetarianButton.tag = 2
        lactoseButton.setImage(#imageLiteral(resourceName: "milk-blue"), for: .selected)
        lactoseButton.setImage(#imageLiteral(resourceName: "dairy"), for: .normal)
        lactoseButton.tag = 3
        veganButton.setImage(#imageLiteral(resourceName: "vegan-blue"), for: .selected)
        veganButton.setImage(#imageLiteral(resourceName: "vegan"), for: .normal)
        veganButton.tag = 4
    }
    
    /* colors icons based on what user has already chosen */
    func colorIcons() {
        let allergies = profileObject.allergiesList
        for allergy in allergies.keys {
            let index = allergyList.index(of: allergy)
            let button = allergyIcons[index!]
            button.isSelected = true
        }
    }
    
    /* changes color of allergy icons to reflect selection/deselection */
    @IBAction func toggleImage(_ sender: Any) {
        if let button = sender as? UIButton {
            let tag = button.tag
            let allergy = allergyList[tag]
            if button.isSelected {
                // set deselected
                button.isSelected = false
                allergyChanges[tag] -= 1
                profileObject.allergiesList.removeValue(forKey: allergy)
            } else {
                // set selected
                button.isSelected = true
                allergyChanges[tag] += 1
                profileObject.allergiesList[allergy] = 1
            }
        }
    }
    
    // *********** LET USER SELECT PROFILE IMAGE ***********
    
    /* Allows user to choose from their own images and set the UIImageView */
    @objc func handleSelectProfileImageView() {
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
            profileImage.image = picture
            imageDidChange = true
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
        let imageRef = storageRef.child("profilePictures/\(self.profileObject.userID)")
        
        if let uploadData = UIImagePNGRepresentation(profileImage.image!) {
            imageRef.putData(uploadData, metadata: nil, completion: {
                (metadata, error) in
                
                if (error != nil) {
                    print(error)
                    return
                }
                
                // update user's profile URL in Firebase Database
                print("Updating User's URL in Database")
                let imageURL = metadata?.downloadURL()?.absoluteString
                self.databaseRef.child("users/\(self.profileObject.userID)/imageURL").setValue(imageURL)
            })
        }
    }
    
    /* If the user clicked save, update their information in Firebase */
    func updateUserInfo() {
        // update name
        databaseRef.child("users/\(profileObject.userID)/name").setValue(nameField.text)
        
        //update drink of choice
        databaseRef.child("users/\(profileObject.userID)/name").setValue(drinkField.text)
        
        // update party trick
        databaseRef.child("users/\(profileObject.userID)/name").setValue(trickField.text)
        
        // update email
        Auth.auth().currentUser?.updateEmail(to: emailField.text!, completion: { (error) in
            if ((error) != nil) {
                print(error)
            }
        })
        
        // update password
        if (passwordField.hasText) {
            Auth.auth().currentUser?.updatePassword(to: passwordField.text!, completion: { (error) in
                if (error != nil) {
                    print(error)
                }
            })
        }
        
        // update picture
        if (imageDidChange) {
            updateFirebaseStorage()
        }
        
        // update allergies
        var index = 0
        for update in allergyChanges {
            // remove value from Firebase
            if (update == -1) {
                let allergy = allergyList[index]
                databaseRef.child("users/\(profileObject.userID)/allergyList/\(allergy)").removeValue()
            } else if (update == 1) {
                // add entry to firebase
                let allergy = [allergyList[index]: 1] as [String: Any]
                databaseRef.child("users/\(profileObject.userID)/allergyList/").updateChildValues(allergy)
            }
            
            index += 1
        }
    }
    
    /* don't save anything, go back to the original profile view */
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /* when user clicks save, THEN update all of their information to firebase */
    @IBAction func saveProfileButton(_ sender: Any) {
        updateUserInfo()
        
        performSegue(withIdentifier: "saveProfileSegue", sender: self)
    }
    
    /* sets all the values in the profile page so it doesn't have to requery firebase */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueID = segue.identifier
        if (segueID == "saveProfileSegue") {
            if let destinationVC = segue.destination as? ProfileViewController {
                destinationVC.profilePicture.image = profileImage.image
                destinationVC.nameLabel.text = nameField.text
                
                destinationVC.drinkOfChoiceLabel.text = drinkField.text
                destinationVC.partyTrickLabel.text = trickField.text
                
                // update allergies in original profile page
                var index = 0
                for update in allergyChanges {
                    // remove value from Firebase
                    if (update == -1) {
                        destinationVC.allergyIcons[index].isSelected = false
                    } else if (update == 1) {
                        // add entry to firebase
                        destinationVC.allergyIcons[index].isSelected = true
                    }
                    index += 1
                }
            }
        }
    }
    
}
