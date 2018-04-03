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
    
    @IBOutlet weak var partyImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var attireLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
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
    @IBOutlet weak var guest1: UIButton!
    @IBOutlet weak var guest2: UIButton!
    @IBOutlet weak var guest3: UIButton!
    @IBOutlet weak var guest4: UIButton!
    @IBOutlet weak var guest5: UIButton!
    @IBOutlet weak var guest6: UIButton!
    @IBOutlet weak var guest7: UIButton!
    @IBAction func addGuests(_ sender: Any) {
        performSegue(withIdentifier: "guestListSegue", sender: self)
    }
    @IBAction func editPartyButton(_ sender: Any) {
        performSegue(withIdentifier: "editPartySegue", sender: self)
    }
    
    var guestButtons = [UIButton]()
    var displayedGuests = [ProfileModel]()

    // Firebase Database connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    var storageRef: StorageReference!
    var storageHandle: StorageHandle?
    
    var allergyList = ["Nuts", "Gluten", "Vegetarian", "Dairy", "Vegan"]
    var allergyCounts = [0, 0, 0, 0, 0]
    var allergyImages = [UIButton]()
    var allergyLabels = [UILabel]()
    
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
        
        partyImage.image = partyObject.image
        nameLabel.text = partyObject.name
        addressLabel.text = partyObject.address
        attireLabel.text = partyObject.attire
        dateLabel.text = partyObject.date
    }
    
    override func viewDidAppear(_ animated: Bool) {
        partyImage.image = partyObject.image
        nameLabel.text = partyObject.name
        addressLabel.text = partyObject.address
        attireLabel.text = partyObject.attire
        dateLabel.text = partyObject.date
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
    
    /* makes buttons iterable and now we can tell which profile to go to */
    func setupGuestButtons() {
        guest1.tag = 0
        guest2.tag = 1
        guest3.tag = 2
        guest4.tag = 3
        guest4.tag = 4
        guest5.tag = 5
        guest6.tag = 6
        guest7.tag = 7
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
            newUser.userID = userID
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
                            if (self.displayedGuests.count < 6) {
                                let fillIndex = self.displayedGuests.count
                                self.displayedGuests.append(newUser)
                                self.guestButtons[fillIndex].setImage(UIImage(data: image!), for: .normal)
                            }
                        }
                    }).resume()
                } else {
                    if (self.displayedGuests.count < 6) {
                        let fillIndex = self.displayedGuests.count
                        self.displayedGuests.append(newUser)
                        self.guestButtons[fillIndex].setImage(#imageLiteral(resourceName: "parti_logo"), for: .normal)
                    }
                }
                
                if let allergies = data["allergyList"] {
                    let userAllergies = allergies as! [String: Any]
                    newUser.allergiesList = userAllergies
                    
                    for allergy in userAllergies.keys {
                        let index = self.allergyList.index(of: allergy)
                        self.allergyImages[index!].isSelected = true
                        self.allergyCounts[index!] += 1
                        self.allergyLabels[index!].text = String(self.allergyCounts[index!])
                    }
                }
                
                self.partyObject.guests.append(newUser)
                
            } else {
                print("No user in Firebase yet")
            }
        }
    }
    
    /* When user button is selected, go to profile or go to add guests page */
    @IBAction func selectGuest(_ sender: Any) {
        if let button = sender as? UIButton {
            let userIndex = button.tag
            if (userIndex > displayedGuests.count - 1) {
                performSegue(withIdentifier: "guestListSegue", sender: self)
            } else {
                // go to that user's profile
                performSegue(withIdentifier: "guestProfileSegue", sender: button)
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
                let button = sender as! UIButton
                let userID = displayedGuests[button.tag].userID
                print(userID)
                destinationVC.profileObject.userID = userID
            }
            // Party List Page
        } else if (segueID == "guestListSegue") {
            if let destinationVC = segue.destination as? AddGuestsToPartyViewController {
                 destinationVC.partyObject = self.partyObject
            }
        } else if (segueID == "editPartySegue") {
            if let destinationVC = segue.destination as? EditPartyViewController {
                destinationVC.partyObject = self.partyObject
            }
        }
    }

}
