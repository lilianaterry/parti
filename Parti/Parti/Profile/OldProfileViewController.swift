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

class OldProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    
    @IBAction func logout(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print ("Logging out")
            self.performSegue(withIdentifier: "logoutSegue", sender: self)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    var allergyImages = [UIButton]()
    var allergyList = ["Nuts", "Gluten", "Vegetarian", "Dairy", "Vegan"]

    /* Runs when page is loaded, sets the delegate and datasource then calls method to query
     Firebase and fetch this user's information */
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // set firebase references
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        allergyImages = [nutsButton, glutenButton, vegetarianButton, lactoseButton, veganButton]
        
        profileObject.userID = Auth.auth().currentUser?.uid as! String
        
        setupProfilePicture()
        
        setupAllergyIcons()
        
        // query Firebase to get the current user's information
        populateProfilePage()
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
    
    func setupProfilePicture () {
        
        if (profilePicture.image == nil) {
            databaseHandle = databaseRef?.child("users/\(profileObject.userID)/imageURL").observe(.value, with: { (snapshot) in
                if (snapshot.exists()) {
                    
                    // If the user already has a profile picture, load it up!
                    if let imageURL = snapshot.value as? String {
                        self.profileObject.imageURL = imageURL
                        let url = URL(string: imageURL)
                        URLSession.shared.dataTask(with: url!, completionHandler: { (image, response, error) in
                            if (error != nil) {
                                print(error)
                                return
                            }
                            DispatchQueue.main.async { // Make sure you're on the main thread here
                                if let image = UIImage(data: image!) {
                                    self.profilePicture?.image = image
                                    self.profileObject.image = image
                                }
                            }
                        }).resume()
                        // otherwise use this temporary image
                    } else {
                        self.profilePicture?.image = #imageLiteral(resourceName: "parti_logo")
                    }
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /* Creates an instance of the ProfileModel class and fills in all relevant information
     from Firebase query. Sets the global PartyObject to this filled-in object */
    func populateProfilePage() {
        databaseHandle = databaseRef?.child("users/\(profileObject.userID)").observe(.value, with: { (snapshot) in
            if (snapshot.exists()) {
                let data = snapshot.value as! [String: Any]
            
                if let name = data["name"] {
                    self.profileObject.name = name as! String
                    self.nameLabel.text = name as! String
                }
                if let username = data["username"] {
                    self.profileObject.username = username as! String
                    self.usernameLabel.text = username as! String
                }
                if let drink = data["drinkOfChoice"] {
                    self.profileObject.drink = drink as! String
                    self.drinkOfChoiceLabel.text = drink as! String
                }
                if let trick = data["partyTrick"] {
                    self.profileObject.trick = trick as! String
                    self.partyTrickLabel.text = trick as! String
                }
                
                // color all of the allergy icons
                if let allergies = data["allergiesList"] {
                    let userAllergies = allergies as! [String: Any]
                    
                    for allergy in userAllergies.keys {
                        let indexOfAllergy = self.allergyList.index(of: allergy)
                        self.profileObject.allergiesList[allergy] = 1
                        self.allergyImages[indexOfAllergy!].isUserInteractionEnabled = false
                        self.allergyImages[indexOfAllergy!].isSelected = true
                    }
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
