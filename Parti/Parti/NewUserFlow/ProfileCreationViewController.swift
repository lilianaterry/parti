//
//  ProfileCreationViewController.swift
//  Parti
//
//  Created by Liliana Terry on 3/21/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class ProfileCreationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Firebase Database connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    // Firebase Storage connection
    var storageRef: StorageReference!
    var storageHandle: StorageHandle?
    
    var profileObject = ProfileModel()
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var nameError: UILabel!
    @IBOutlet weak var usernameError: UILabel!
    
    @IBAction func nextButton(_ sender: Any) {
        if (!nameText.hasText) {
            nameError.text = "Please enter your name."
        } else {
            nameError.text = nil
        }
        
        // TODO: Need to error check against unique username
        if (!usernameText.hasText) {
            usernameError.text = "Please choose a username."
        } else {
            usernameError.text = nil
        }
        
        if (nameText.hasText && usernameText.hasText) {
            profileObject.name = nameText.text!
            profileObject.username = usernameText.text!.lowercased()
            if (profilePicture.image != nil) {
                profileObject.image = profilePicture.image!
            }
            checkUsername(username: (usernameText.text?.lowercased())!)
        }
    }
    
    // check if this username has already been taken
    func checkUsername(username: String) {
        databaseRef.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.exists()) {
                var valid = true
                
                let data = snapshot.value as! [String: Any]
                
                // iterate over all users and their usernames
                for user in data.keys {
                    let userInfo = data["\(user)"] as! [String: Any]
                    let currentUsername = userInfo["username"] as! String
                    
                    // if this username matches the new one, make them choose another
                    if (currentUsername == username.lowercased()) {
                        valid = false
                        break
                    }
                }
                
                if (valid) {
                    self.performSegue(withIdentifier: "createStepTwo", sender: self)
                } else {
                    self.usernameError.text = "This username is already in use."
                }
            } else {
                self.performSegue(withIdentifier: "createStepTwo", sender: self)
            }
        })
        
    }
    
    
    /* Runs when page is loaded, sets the delegate and datasource then calls method to query
     Firebase and fetch this user's information */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set firebase references
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
    
        setupProfilePicture()
        
        profileObject.userID = (Auth.auth().currentUser?.uid)!
    }
    
    /* Ensures profile picture is circular and clicable */
    func setupProfilePicture () {
        // create circular mask on image
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.height / 2
        self.profilePicture.clipsToBounds = true
        
        // TODO CREATE WHITE BOARDER + DROP SHADOW
        
        // make Profile picture editable
        profilePicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        profilePicture.isUserInteractionEnabled = true
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
            profilePicture.image = picture
            profileObject.image = picture
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

    /* If user does not complete registration process, delete their Auth info */
    @IBAction func cancelRegistration(_ sender: Any) {
        let user = Auth.auth().currentUser
        user?.delete()
        print("did Click")
        self.performSegue(withIdentifier: "cancel", sender: self)
    }
    
    /* Move to Add Friend step of registration */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueID = segue.identifier
        
        // Add Friend List Page
        if (segueID == "createStepTwo") {
            if let destinationVC = segue.destination as? CreateFriendListViewController {
                destinationVC.profileObject = profileObject
            }
        }
    }
}
