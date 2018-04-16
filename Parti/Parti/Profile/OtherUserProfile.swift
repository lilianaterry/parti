//
//  OtherUserProfile.swift
//  Parti
//
//  Created by Liliana Terry on 3/29/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class OtherUserProfile: UIViewController {
    
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

        setupProfilePicture()
        setupAllergyIcons()
        
        // query Firebase to get the current user's information
        populateProfilePage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // set firebase references
        //databaseRef = Database.database().reference()
        //storageRef = Storage.storage().reference()
        
        //allergyImages = [nutsButton, glutenButton, vegetarianButton, lactoseButton, veganButton]
        
        //setupProfilePicture()
        
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
        // create circular mask on image
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2
        self.profilePicture.clipsToBounds = true
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
                
                // If the user already has a profile picture, load it up!
                if let imageURL = data["imageURL"] as? String {
                    self.profileObject.imageURL = imageURL
                    let url = URL(string: imageURL)
                    URLSession.shared.dataTask(with: url!, completionHandler: { (image, response, error) in
                        if (error != nil) {
                            print(error)
                            return
                        }
                        DispatchQueue.main.async { // Make sure you're on the main thread here
                            self.profilePicture?.image = UIImage(data: image!)
                            self.profileObject.image = UIImage(data: image!)!
                        }
                    }).resume()
                }
                
                if let name = data["name"] {
                    self.profileObject.name = name as! String
                    // update profile page
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
                
                if let allergies = data["allergiesList"] {
                    let userAllergies = allergies as! [String: Any]
                    
                    print("Allergies")
                    for allergy in userAllergies.keys {
                        let indexOfAllergy = self.allergyList.index(of: allergy)
                        print(allergy)
                        //print(indexOfAllergy!)
                        self.allergyImages[indexOfAllergy!].isSelected = true
                        self.profileObject.allergiesList[allergy] = 1
                    }
                }
                
            } else {
                print("No user in Firebase yet")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }

}
