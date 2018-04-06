//
//  PartyPageViewController.swift
//  Parti
//
//  Created by Liliana Terry on 3/20/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class PartyPageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Firebase Database connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    // Firebase Storage connection
    var storageRef: StorageReference!
    var storageHandle: StorageHandle?
    
    var partyObject = PartyModel()
    
    @IBOutlet weak var partyImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var attireLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var guest1: UIButton!
    @IBOutlet weak var guest2: UIButton!
    @IBOutlet weak var guest3: UIButton!
    @IBOutlet weak var guest4: UIButton!
    @IBOutlet weak var guest5: UIButton!
    @IBOutlet weak var guest6: UIButton!
    @IBOutlet weak var guest7: UIButton!
    // see more guests invited
    @IBAction func moreGuests(_ sender: Any) {
        performSegue(withIdentifier: "guestListSegue", sender: self)
    }
    @IBAction func foodList(_ sender: Any) {
        performSegue(withIdentifier: "foodListSegue", sender: self)
    }
    
    var guestButtons = [UIButton]()
    var displayedGuests = [ProfileModel]()
    
    /* Runs when page is loaded, sets the delegate and datasource then calls method to query
     Firebase and fetch this user's information */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set firebase references
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        partyImage.image = partyObject.image
        nameLabel.text = partyObject.name
        addressLabel.text = partyObject.address
        dateLabel.text = partyObject.date
        attireLabel.text = partyObject.attire
        
        guestButtons = [guest1, guest2, guest3, guest4, guest5, guest6]
        
        setupGuestButtons()
        
        // Do any additional setup after loading the view.
        getGuests()

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
            if (userIndex < displayedGuests.count) {
                performSegue(withIdentifier: "guestProfileSegue", sender: button)
            }
        }
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    // Pass user information to profile page or pass party id to guest list
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueID = segue.identifier
        
        // Create Profile Step 1
        if (segueID == "guestProfileSegue") {
            if let destinationVC = segue.destination as? OtherUserProfile {
                let button = sender as! UIButton
                let userID = displayedGuests[button.tag].userID
                destinationVC.profileObject.userID = userID
            }
            // Party List Page
        } else if (segueID == "guestListSegue") {
            if let destinationVC = segue.destination as? GuestListViewController {
                destinationVC.partyObject.partyID = self.partyObject.partyID
            }
            
        } else if (segueID == "foodListSegue") {
            if let destinationVC = segue.destination as? PartyFoodListViewController {
                destinationVC.partyObject = partyObject
            }
        }
    }

}
