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
import FirebaseAuth

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Firebase Database connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    // Firebase Storage connection
    var storageRef: StorageReference!
    var storageHandle: StorageHandle?
    
    var profileObject = ProfileModel()
    
    @IBOutlet weak var nutsButton: UIButton!
    @IBOutlet weak var glutenButton: UIButton!
    @IBOutlet weak var vegetarianButton: UIButton!
    @IBOutlet weak var lactoseButton: UIButton!
    @IBOutlet weak var veganButton: UIButton!
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var drinkOfChoiceLabel: UILabel!
    @IBOutlet weak var partyTrickLabel: UILabel!
    
    var allergyIcons = [UIButton]()
    
    /* Runs when page is loaded, sets the delegate and datasource then calls method to query
     Firebase and fetch this user's information */
    override func viewDidLoad() {
        super.viewDidLoad()
        print("IN VIEW DID LOAD")
        
        // set firebase references
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        allergyIcons = [nutsButton, glutenButton, vegetarianButton, lactoseButton, veganButton]
        
        profileObject.userID = Auth.auth().currentUser?.uid as! String
        setupProfilePicture()
        
        // query Firebase to get the current user's information
        populateProfilePage()
    }
    
    func setupProfilePicture () {
        // create circular mask on image
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2
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
            profilePicture.image = picture
            updateFirebaseStorage()
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
        
        if let uploadData = UIImagePNGRepresentation(self.profilePicture.image!) {
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

    /* Creates an instance of the ProfileModel class and fills in all relevant information
     from Firebase query. Sets the global PartyObject to this filled-in object */
    func populateProfilePage() {
        databaseHandle = databaseRef?.child("users/\(profileObject.userID)").observe(.value, with: { (snapshot) in
            print("POPULATE PROFILE PAGE")
            if (snapshot.exists()) {
                let data = snapshot.value as! [String: Any]
                
                // If the user already has a profile picture, load it up!
                if let imageURL = data["imageURL"] as? String {
                    self.profileObject.imageURL = imageURL
                    let url = URL(string: imageURL)
                    URLSession.shared.dataTask(with: url!, completionHandler: { (image, response, error) in
                        if (error != nil) {
                            print(error)
                            return
                        }
                        print("about to save!!! fingers crossed!")
                        DispatchQueue.main.async { // Make sure you're on the main thread here
                            self.profilePicture?.image = UIImage(data: image!)
                        }
                    }).resume()
                }
            
                if let name = data["name"] {
                    self.profileObject.name = name as! String
                    // update profile page
                    self.nameLabel.text = self.profileObject.name
                }
                if let username = data["username"] {
                    self.profileObject.username = username as! String
                    self.usernameLabel.text = self.profileObject.username
                }
            } else {
                print("No user in Firebase yet")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    @IBAction func editButton(_ sender: Any) {
        self.performSegue(withIdentifier: "editProfileSegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueID = segue.identifier
        if (segueID == "editProfileSegue") {
            if let destinationVC = segue.destination as? EditProfileViewController {
                destinationVC.profileObject = profileObject
            }
        }
        
    }
    
}
