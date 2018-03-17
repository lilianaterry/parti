//
//  ProfileViewController.swift
//  Parti
//
//  Created by Liliana Terry on 3/16/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//


import UIKit
import FirebaseDatabase
import FirebaseStorage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    var userID = "abMlbWBVzHVdD1vL1SVIQfLcVmT2"

    // Firebase connection
    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    var profileObject = ProfileModel()
 
    /* Runs when page is loaded, sets the delegate and datasource then calls method to query
     Firebase and fetch this user's information */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set firebase reference
        ref = Database.database().reference()
        
        // create circular mask on image
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2
        self.profilePicture.clipsToBounds = true
        
        // TODO CREATE WHITE BOARDER + DROP SHADOW
        
        // make Profile picture editable
        profilePicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        profilePicture.isUserInteractionEnabled = true
        
        // query Firebase to get the current user's information
        populateProfilePage()
        
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
        print(info)
        
        // Allows user to upload cropped image to make sure profile picture is square
        if let croppedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            print("cropped")
            print(croppedImage.size)
            selectedPicture = croppedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            print("original")
            print(originalImage.size)
            selectedPicture = originalImage
        }
        
        // if a new image was selected, update Firebase and user's phone
        if let picture = selectedPicture {
            print("did reach here")
            profilePicture.image = picture
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
    
    /* Creates an instance of the ProfileModel class and fills in all relevant information
     from Firebase query. Sets the global PartyObject to this filled-in object */
    func populateProfilePage() {
        databaseHandle = ref?.child("users/\(userID)").observe(.value, with: { (snapshot) in
            let profileID = snapshot.key
            let data = snapshot.value as! [String: Any]
            
            var profileObject = ProfileModel()
            //profileObject.profilePicture = data["profilePicture"] as! UIImage
            profileObject.name = data["name"] as! String
            print(profileObject.name)
            
            self.profileObject = profileObject
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
}
