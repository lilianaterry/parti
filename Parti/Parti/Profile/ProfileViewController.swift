//
//  ViewController.swift
//  PartyUI
//
//  Created by Liliana Terry on 4/19/18.
//  Copyright © 2018 The Party App. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    // Firebase Database connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    // Firebase Storage connection
    var storageRef: StorageReference!
    var storageHandle: StorageHandle?
    
    var profileObject = ProfileModel()
    
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var imageBorder: UIView!
    @IBOutlet weak var borderWidth: NSLayoutConstraint!
    @IBOutlet weak var borderHeight: NSLayoutConstraint!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var picWidth: NSLayoutConstraint!
    @IBOutlet weak var picHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomDist: NSLayoutConstraint!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var infoBar: UIView!
    @IBOutlet weak var trickBox: UIView!
    @IBOutlet weak var drinkBox: UIView!
    @IBOutlet weak var trickTitle: UILabel!
    @IBOutlet weak var trickLabel: UILabel!
    @IBOutlet weak var drinkTitle: UILabel!
    @IBOutlet weak var drinkLabel: UILabel!
    
    @IBOutlet weak var allergyBar: UIView!
    @IBOutlet weak var nuts: UIButton!
    @IBOutlet weak var vegetarian: UIButton!
    @IBOutlet weak var gluten: UIButton!
    @IBOutlet weak var vegan: UIButton!
    @IBOutlet weak var dairy: UIButton!
    var allergyIcons = [UIButton]()
    var allergyList = ["Nuts", "Vegetarian", "Gluten", "Vegan", "Dairy"]
    
    @IBOutlet weak var bottomBar: UIView!
    
    @IBOutlet weak var profileTabItem: UITabBarItem!
    
    let colors = UIExtensions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set firebase references
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        profileObject.userID = Auth.auth().currentUser?.uid as! String
        
        // query Firebase to get the current user's information
        populateProfilePage()
        setupProfilePicture()

        setupUI()
    }
    
    /* Creates an instance of the ProfileModel class and fills in all relevant information
     from Firebase query. Sets the global PartyObject to this filled-in object */
    func populateProfilePage() {
        databaseHandle = databaseRef?.child("users/\(profileObject.userID)").observe(.value, with: { (snapshot) in
            if (snapshot.exists()) {
                let data = snapshot.value as! [String: Any]
                
                if let name = data["name"] {
                    self.profileObject.name = name as! String
                    self.nameLabel.text = name as? String
                }
                if let username = data["username"] {
                    self.profileObject.username = username as! String
                    self.usernameLabel.text = username as? String
                }
                if let drink = data["drinkOfChoice"] {
                    self.profileObject.drink = drink as! String
                    self.drinkLabel.text = drink as? String
                }
                if let trick = data["partyTrick"] {
                    self.profileObject.trick = trick as! String
                    self.trickLabel.text = trick as? String
                }
                
                // color all of the allergy icons
                if let allergies = data["allergiesList"] {
                    let userAllergies = allergies as! [String: Any]
                    
                    for allergy in userAllergies.keys {
                        let indexOfAllergy = self.allergyList.index(of: allergy)
                        self.profileObject.allergiesList[allergy] = 1
                        self.allergyIcons[indexOfAllergy!].tintColor = self.colors.darkMint
                    }
                }
                
            } else {
                print("No user in Firebase yet")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    // get user's profile picture from Firebase Storage
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
    
    // edit profile button 
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
    
    // allows user to log out 
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

    /* ---------------------------------------------------------------------- */
    /* UI CODE */
    func setupUI() {
        topHalf()
        trickAndDrink()
        allergies()
        bottom()
        
        // if on a 5s, make additional changes
        if (mainView.frame.height == 568) {
            smallScreenSizes()
        }
    }
    
    // Profile picture, name, username
    func topHalf() {
        imageBorder.backgroundColor = UIColor.white
        imageBorder.layer.applyShadow(color: UIColor.black, alpha: 0.15, x: 0, y: 3, blur: 6, spread: 0)
        imageBorder.layer.cornerRadius = imageBorder.frame.size.height / 2
        
        profilePicture.layer.cornerRadius = profilePicture.frame.size.height / 2
        profilePicture.clipsToBounds = true
        
        nameLabel.textColor = colors.nameColor
        usernameLabel.textColor = UIColor.white
        
    }
    
    // add center line and drop shadow to guest info bar
    func trickAndDrink() {
        mainView.sendSubview(toBack: allergyBar)
        trickBox.layer.addBorder(edge: .right, color: colors.backgroundLightGrey, thickness: 1)
        infoBar.layer.applyShadow(color: UIColor.black, alpha: 0.1, x: 0, y: 2, blur: 5, spread: 0)
        
        trickTitle.textColor = colors.darkMint
        trickTitle.layer.addBorder(edge: .bottom, color: colors.mainColor, thickness: 1)
        trickLabel.textColor = colors.darkGrey
        drinkTitle.textColor = colors.darkMint
        drinkTitle.layer.addBorder(edge: .bottom, color: colors.mainColor, thickness: 1)
        drinkLabel.textColor = colors.darkGrey
    }
    
    // set background color and allergy button colorings
    func allergies() {
        allergyIcons = [nuts, vegetarian, gluten, vegan, dairy]

        for icon in allergyIcons {
            icon.tintColor = colors.mediumGrey
        }
    }
    
    // add drop shadow to the top of the bottom bar to make allergy bar look recessed
    func bottom() {
        bottomBar.layer.applyShadow(color: UIColor.black, alpha: 0.1, x: 0, y: -2, blur: 5, spread: 0)
        profileTabItem.badgeColor = colors.mainColor
        tabBarItem.setBadgeTextAttributes([NSAttributedStringKey.foregroundColor.rawValue: colors.mainColor], for: .selected)

    }
    
    // if on a 5s, constraints start breaking
    func smallScreenSizes() {
        borderWidth.constant = 100
        borderHeight.constant = 100
        imageBorder.layer.cornerRadius = 50
        
        picWidth.constant = 90
        picHeight.constant = 90
        profilePicture.layer.cornerRadius = 45
        
        bottomDist.constant = 20
    }
}
