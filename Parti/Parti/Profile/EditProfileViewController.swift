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
    
    let colors = UIExtensions()
    
    var imageDidChange = false
    
    let allergyList = ["Nuts", "Vegetarian", "Gluten", "Vegan", "Dairy"]
    var allergyIcons = [UIButton]()
    var allergyChanges = [0,0,0,0,0]
    
    /* Runs when page is loaded, sets the delegate and datasource then calls method to query
     Firebase and fetch this user's information */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set firebase references
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()

        // setup this page with the old profile information
        profileImage.image = profileObject.image
        // create circular mask on image
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2
        self.profileImage.clipsToBounds = true
        
        nameField.text = profileObject.name
        drinkField.text = profileObject.drink
        trickField.text = profileObject.trick
        
        emailField.text = Auth.auth().currentUser?.email
        
        allergyIcons = [nutsButton, vegetarianButton, glutenButton, veganButton, lactoseButton]
        
        setupAllergyIcons()
        
    }
    
    /* Adds color selection functionality to allergy icons */
    func setupAllergyIcons() {
        nutsButton.tag = 0
        vegetarianButton.tag = 1
        glutenButton.tag = 2
        veganButton.tag = 3
        lactoseButton.tag = 4
                
        for allergy in allergyIcons {
            allergy.tintColor = colors.mediumGrey
        }
        
        for allergy in profileObject.allergiesList.keys {
            let indexOfAllergy = allergyList.index(of: allergy)
            allergyIcons[indexOfAllergy!].tintColor = colors.darkMint
        }
    }
    
    /* changes color of allergy icons to reflect selection/deselection */
    @IBAction func toggleImage(_ sender: Any) {
        if let button = sender as? UIButton {
            let tag = button.tag
            let allergy = allergyList[tag]
            if button.tintColor == colors.darkMint {
                // set deselected
                button.tintColor = colors.mediumGrey
                allergyChanges[tag] -= 1
                profileObject.allergiesList.removeValue(forKey: allergy)
            } else {
                // set selected
                button.tintColor = colors.darkMint
                allergyChanges[tag] += 1
                profileObject.allergiesList[allergy] = 1
            }
        }
    }
    
    // *********** LET USER SELECT PROFILE IMAGE ***********
    
    /* Allows user to choose from their own images and set the UIImageView */
    @IBAction func editPicture(_ sender: Any) {
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
            profileImage.image = picture
            imageDidChange = true
        }
        
        // Get rid of image picking screen
        dismiss(animated: false, completion: nil)
    }
    
    /* If user clicks on Cancel instead of selecting an image */
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // *********** QUERY FIREBASE ***********
    
    func updateFirebaseStorage() {
        let imageRef = storageRef.child("profilePictures/\(self.profileObject.userID)")
            
        if let uploadData = UIImageJPEGRepresentation(profileImage.image!, 0.1) {
            imageRef.putData(uploadData, metadata: nil, completion: {
                (metadata, error) in
                
                if (error != nil) {
                    return
                }
                
                // update user's profile URL in Firebase Database
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
        databaseRef.child("users/\(profileObject.userID)/drinkOfChoice").setValue(drinkField.text)
        
        // update party trick
        databaseRef.child("users/\(profileObject.userID)/partyTrick").setValue(trickField.text)
        
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
                databaseRef.child("users/\(profileObject.userID)/allergiesList/\(allergy)").removeValue()
            } else if (update == 1) {
                // add entry to firebase
                let allergy = [allergyList[index]: 1] as [String: Any]
                databaseRef.child("users/\(profileObject.userID)/allergiesList/").updateChildValues(allergy)
            }
            
            index += 1
        }
    }
    
    /* don't save anything, go back to the original profile view */
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    /* when user clicks save, THEN update all of their information to firebase */
    @IBAction func saveProfileButton(_ sender: Any) {
        updateUserInfo()
        self.performSegue(withIdentifier: "saveProfile", sender: self)
    }
    
    
    // Go back to profile page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueID = segue.identifier
        
        // Add Friend List Page
        if (segueID == "saveProfile") {
            if let destinationVC = segue.destination as? ProfileViewController {
                destinationVC.profilePicture.image = profileImage.image
            }
        }
    }
    
}
