//
//  PartyHostViewController.swift
//  Parti
//
//  Created by Arjun Gopisetty on 3/26/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class PartyHostViewController: ViewController {
    
    @IBOutlet weak var nutButton: UIButton!
    @IBOutlet weak var glutenButton: UIButton!
    @IBOutlet weak var vegetarianButton: UIButton!
    @IBOutlet weak var milkButton: UIButton!
    @IBOutlet weak var veganButton: UIButton!
    
    @IBOutlet weak var nutsLabel: UILabel!
    @IBOutlet weak var glutenLabel: UILabel!
    @IBOutlet weak var vegetarianLabel: UILabel!
    @IBOutlet weak var milkLabel: UILabel!
    @IBOutlet weak var veganLabel: UILabel!
    
    // Guest Image buttons
    @IBOutlet weak var guest1: GuestButton!
    @IBOutlet weak var guest2: GuestButton!
    @IBOutlet weak var guest3: GuestButton!
    @IBOutlet weak var guest4: GuestButton!
    @IBOutlet weak var guest5: GuestButton!
    @IBOutlet weak var guest6: GuestButton!
    @IBOutlet weak var guest7: GuestButton!
    @IBOutlet weak var addMore: GuestButton!
    
    var guestButtons = [GuestButton]()
    
    // Firebase Database connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    var storageRef: StorageReference!
    var storageHandle: StorageHandle?
    
    var allergyList = ["Nuts", "Gluten", "Vegetarian", "Dairy", "Vegan"]
    var allergyCounts = [0, 0, 0, 0, 0]
    var allergyImages = [UIButton]()
    var allergyLabels = [UILabel]()
    let guests = [ProfileModel]()
    
    var partyObject = PartyModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        allergyImages = [nutButton, glutenButton, vegetarianButton, milkButton, veganButton]
        allergyLabels = [nutsLabel, glutenLabel, vegetarianLabel, milkLabel, veganLabel]
        
        guestButtons = [guest1, guest2, guest3, guest4, guest5, guest6]

        setupAllergyIcons()
        setupGuestButtons()
        
        // Do any additional setup after loading the view.
        getGuests()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* Adds color selection functionality to allergy icons */
    func setupAllergyIcons() {
        nutButton.setImage(#imageLiteral(resourceName: "nuts-orange.png"), for: .selected)
        nutButton.setImage(#imageLiteral(resourceName: "nut-free"), for: .normal)
        nutButton.tag = 0
        glutenButton.setImage(#imageLiteral(resourceName: "gluten-yellow"), for: .selected)
        glutenButton.setImage(#imageLiteral(resourceName: "gluten-free"), for: .normal)
        glutenButton.tag = 1
        vegetarianButton.setImage(#imageLiteral(resourceName: "veggie-green"), for: .selected)
        vegetarianButton.setImage(#imageLiteral(resourceName: "vegetarian"), for: .normal)
        vegetarianButton.tag = 2
        milkButton.setImage(#imageLiteral(resourceName: "milk-blue"), for: .selected)
        milkButton.setImage(#imageLiteral(resourceName: "dairy"), for: .normal)
        milkButton.tag = 3
        veganButton.setImage(#imageLiteral(resourceName: "vegan-blue"), for: .selected)
        veganButton.setImage(#imageLiteral(resourceName: "vegan"), for: .normal)
        veganButton.tag = 4
    }
    
    func setupGuestButtons() {
        var index = 0
        for button in guestButtons {
            guestButtons[index] = GuestButton(userID: "")
            guestButtons[index].isHidden = true
            index += 1
        }
        
        addMore = GuestButton(userID: partyObject.partyID)
    }
    
    /* iterates over all guests invited to the party to populate profile objects and get allergies */
    func getGuests() {
        databaseRef.child("parties/\(partyObject.partyID)/guests").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    let userID = snap.key
                    
                    self.queryGuestInfo(userID: userID)
                }
            }
        }
    }
    
    /* Get all of the allergy information, name, userID, etc  */
    func queryGuestInfo(userID: String) {
        databaseRef.child("users/\(userID)").observe(.value) { (snapshot) in
            // add all user information to the profile model object
            let newUser = ProfileModel()
            if (snapshot.exists()) {
                let data = snapshot.value as! [String: Any]
                print("got user info")
                print(data)
                
                // If the user already has a profile picture, load it up!
                if let imageURL = data["imageURL"] as? String {
                    let url = URL(string: imageURL)
                    URLSession.shared.dataTask(with: url!, completionHandler: { (image, response, error) in
                        if (error != nil) {
                            print(error)
                            return
                        }
                        DispatchQueue.main.async { // Make sure you're on the main thread here
                            newUser.image = UIImage(data: image!)!
                            // if we still have guest buttons to populate, do so
                            if (self.guestButtons.count > 0) {
                                self.guestButtons[0].userID = userID
                                self.guestButtons[0].setImage(UIImage(data: image!), for: .normal)
                                self.guestButtons[0].isHidden = false
                                self.guestButtons.remove(at: 0)
                            }
                        }
                    }).resume()
                }
                
                if let allergies = data["allergyList"] {
                    print(allergies)
                    let userAllergies = allergies as! [String: Any]
                    
                    for allergy in userAllergies.keys {
                        let index = self.allergyList.index(of: allergy)
                        self.allergyImages[index!].isSelected = true
                        self.allergyCounts[index!] += 1
                        self.allergyLabels[index!].text = String(self.allergyCounts[index!])
                    }
                }
            } else {
                print("No user in Firebase yet")
            }
        }
    }
    
    /* When user button is selected, go to profile or go to add guests page */
    @IBAction func selectGuest(_ sender: Any) {
        if let button = sender as? UIButton {
            let userID = button.tag
            if (userID == nil) {
                // add guest
                performSegue(withIdentifier: "guestListSegue", sender: self)
            } else {
                // go to that user's profile
                performSegue(withIdentifier: "guestProfileSegue", sender: self)
            }
        }
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Pass user information to profile page or pass party id to guest list
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueID = segue.identifier
        
        // Create Profile Step 1
        if (segueID == "guestProfileSegue") {
            if let destinationVC = segue.destination as? OtherUserProfile {
                destinationVC.profileObject.userID = self.userID
            }
            // Party List Page
        } else if (segueID == "guestListSegue") {
            if let destinationVC = segue.destination as? GuestListViewController {
                 destinationVC.partyObject.partyID = self.partyObject.partyID
            }
            
        }
    }

}
