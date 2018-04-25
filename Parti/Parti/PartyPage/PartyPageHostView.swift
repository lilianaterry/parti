//
//  ViewController.swift
//  PartyUI
//
//  Created by Liliana Terry on 4/16/18.
//  Copyright © 2018 The Party App. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class PartyPageHostView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var attendingBarBackground: UIView!
    @IBOutlet weak var partyImage: UIImageView!
    @IBOutlet weak var partyTitleLabel: UILabel!
    @IBOutlet weak var attireLabel: UILabel!
    @IBAction func descriptionButton(_ sender: Any) {
    }
    
    @IBOutlet weak var infoSectionBackground: UIView!
    @IBOutlet weak var placeTitle: UILabel!
    @IBOutlet weak var addressLine1: UILabel!
    @IBOutlet weak var addressLine2: UILabel!
    @IBOutlet weak var timeTitle: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
//    @IBOutlet weak var scrollView: UICollectionView!
    
    @IBOutlet weak var bottomView: UIView!
    
    // color pallete definitions
    let mainColor = UIColor.init(hex: 0x55efc4)
    let darkMint = UIColor.init(hex: 0x00b894)
    let darkGrey = UIColor.init(hex: 0x2d3436)
    let mediumGrey = UIColor.init(hex: 0xb2bec3)
    let lightGrey = UIColor.init(hex: 0xdfe6e9)
    
    @IBOutlet weak var goingButton: UIButton!
    @IBAction func goingButton(_ sender: Any) {
        // deselect
        if (goingButton.isSelected) {
            toggleButtonOff(button: goingButton)
            databaseRef.child("users/\(userID)/attending/\(partyObject.partyID)").setValue(-2)
            // select
        } else {
            toggleButtonOn(button: goingButton, off1: maybeButton, off2: notGoingButton)
            databaseRef.child("users/\(userID)/attending/\(partyObject.partyID)").setValue(1)
        }
    }
    
    @IBOutlet weak var notGoingButton: UIButton!
    @IBAction func notGoingButton(_ sender: Any) {
        // deselect
        if (notGoingButton.isSelected) {
            toggleButtonOff(button: notGoingButton)
            databaseRef.child("users/\(userID)/attending/\(partyObject.partyID)").setValue(-2)
            // select
        } else {
            toggleButtonOn(button: notGoingButton, off1: goingButton, off2: maybeButton)
            databaseRef.child("users/\(userID)/attending/\(partyObject.partyID)").setValue(-1)
        }
    }
    @IBOutlet weak var maybeButton: UIButton!
    
    @IBAction func maybeButton(_ sender: Any) {
        // deselect
        if (maybeButton.isSelected) {
            toggleButtonOff(button: maybeButton)
            databaseRef.child("users/\(userID)/attending/\(partyObject.partyID)").setValue(-2)
            // select
        } else {
            toggleButtonOn(button: maybeButton, off1: goingButton, off2: notGoingButton)
            databaseRef.child("users/\(userID)/attending/\(partyObject.partyID)").setValue(0)
        }
    }
    
    // Firebase Database connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    // Firebase Storage connection
    var storageRef: StorageReference!
    var storageHandle: StorageHandle?
    
    var partyObject = partyCard.init(name: "", address: "", time: 0, date: 0, attire: "", partyID: "", hostID: "", guestList: [:], guests: [], image: UIImage(), imageURL: "", userStatus: 0)
    
    let userID = Auth.auth().currentUser!.uid
    
    // see more guests invited
    //    @IBAction func moreGuests(_ sender: Any) {
    //        performSegue(withIdentifier: "guestListSegue", sender: self)
    //    }
    @IBAction func foodList(_ sender: Any) {
        performSegue(withIdentifier: "foodListSegue", sender: self)
    }
    @IBAction func musicListButton(_ sender: Any) {
        performSegue(withIdentifier: "musicListSegue", sender: self)
    }
    
    @IBAction func unwindToGuestViewController(segue: UIStoryboardSegue) { }
    
    var guestButtons = [UIButton]()
    var displayedGuests = [ProfileModel]()
    
    var allergyList = ["Nuts", "Vegetarian", "Gluten",  "Vegan", "Dairy"]
    var allergyCounts = [0, 0, 0, 0, 0]
    var allergyImages = [UIButton]()
    var allergyLabels = [UILabel]()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // set firebase references
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        partyImage.image = partyObject.image
        partyTitleLabel.text = partyObject.name
        addressLine1.text = partyObject.address
        dateLabel.text = String(partyObject.date)
        attireLabel.text = partyObject.attire
        
        allergyImages = [nutButton, vegetarianButton, glutenButton, veganButton,  milkButton]
        allergyLabels = [nutsLabel, vegetarianLabel, glutenLabel, veganLabel, milkLabel,]
        
        
        setupAllergyIcons()
        // Do any additional setup after loading the view.
        getGuests()
    }
    
    /* Adds color selection functionality to allergy icons */
    func setupAllergyIcons() {

        nutButton.tag = 0

        glutenButton.tag = 1

        vegetarianButton.tag = 2

        milkButton.tag = 3

        veganButton.tag = 4
    }
    
    func setupUI() {
        attendingBar()
        headerText()
        partyInfo()
        bottomBar()
        
        mainView.bringSubview(toFront: infoSectionBackground)
        mainView.bringSubview(toFront: attendingBarBackground)
        
        mainView.bringSubview(toFront: bottomView)
        
        let value = partyObject.userStatus
        if (value == 1) {
            toggleButtonOn(button: goingButton, off1: maybeButton, off2: notGoingButton)
        } else if (value == 0) {
            toggleButtonOn(button: maybeButton, off1: goingButton, off2: notGoingButton)
        } else if (value == -1) {
            toggleButtonOn(button: notGoingButton, off1: maybeButton, off2: goingButton)
        }
    }
    
    
    /* iterates over all guests invited to the party to populate profile objects and get allergies */
    func getGuests() {
        print("getting guests")
        databaseRef.child("parties/\(partyObject.partyID)/guests").observe(.childAdded) { (snapshot) in
            if snapshot.exists() {
                let userID = snapshot.key
                print(userID)
                self.queryGuestInfo(userID: userID)
            }
        }
    }
    
    /* Get all of the allergy information, name, userID, etc  */
    func queryGuestInfo(userID: String) {
        databaseRef.child("users/\(userID)").observeSingleEvent(of: .value) { (snapshot) in
            // add all user information to the profile model object
            let newUser = ProfileModel()
            newUser.userID = userID
            if (snapshot.exists()) {
                let data = snapshot.value as! [String: Any]
                
                if let allergies = data["allergiesList"] {
                    let userAllergies = allergies as! [String: Any]
                    newUser.allergiesList = userAllergies
                    
                    for allergy in userAllergies.keys {
                        let index = self.allergyList.index(of: allergy)
                        self.allergyImages[index!].isSelected = true
                        self.allergyCounts[index!] += 1
                        self.allergyLabels[index!].text = String(self.allergyCounts[index!])
                    }
                }
                
//                // If the user already has a profile picture, load it up!
//                if let imageURL = data["imageURL"] as? String {
//                    let url = URL(string: imageURL)
//                    URLSession.shared.dataTask(with: url!, completionHandler: { (image, response, error) in
//                        if (error != nil) {
//                            print(error)
//                            return
//                        }
//                        
//                        DispatchQueue.main.async { // Make sure you're on the main thread here
//                            newUser.image = UIImage(data: image!)!
//                            // if we still have guest buttons to populate, do so
//                            let fillIndex = self.displayedGuests.count
//                            self.displayedGuests.append(newUser)
//                            let newButton = UIButton()
//                            newButton.setImage(UIImage(data: image!), for: .normal)
//                            newButton.imageView?.image = UIImage(data: image!)
//                            newButton.tag = fillIndex
//                            self.guestButtons.append(newButton)
//                            
//                        }
//                    }).resume()
//                }
                
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
            performSegue(withIdentifier: "guestProfileSegue", sender: button)
            
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
                destinationVC.hostView = false
            }
        } else if (segueID == "musicListSegue") {
            if let destinationVC = segue.destination as? MusicListViewController {
                destinationVC.partyID = partyObject.partyID
                destinationVC.hostView = false
            }
        }
    }
    
    // add a shadow to the text on the image
    func headerText() {
        partyTitleLabel.layer.shadowColor = UIColor.black.cgColor
        partyTitleLabel.layer.shadowRadius = 3.0
        partyTitleLabel.layer.shadowOpacity = 0.33
        partyTitleLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        partyTitleLabel.layer.masksToBounds = false
        
        attireLabel.layer.shadowColor = UIColor.black.cgColor
        attireLabel.layer.shadowRadius = 3.0
        attireLabel.layer.shadowOpacity = 0.33
        attireLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        attireLabel.layer.masksToBounds = false
    }
    
    // add drop shadow to this bar and setup button ui
    func attendingBar() {
        mainView.bringSubview(toFront: attendingBarBackground)
        attendingBarBackground.layer.applyShadow(color: mediumGrey, alpha: 0.2, x: 0, y: 1, blur: 2, spread: 0)
        
        maybeButton.setTitleColor(UIColor.white, for: .selected)
        maybeButton.setTitleColor(darkGrey, for: .normal)
        maybeButton.isSelected = false
        
        goingButton.setTitleColor(UIColor.white, for: .selected)
        goingButton.setTitleColor(darkGrey, for: .normal)
        goingButton.isSelected = false
        
        notGoingButton.setTitleColor(UIColor.white, for: .selected)
        notGoingButton.setTitleColor(darkGrey, for: .normal)
        goingButton.isSelected = false
        
    }
    
    // toggle any of the attending bar buttons on
    func toggleButtonOn(button: UIButton, off1: UIButton, off2: UIButton) {
        button.backgroundColor = mainColor
        button.isSelected = true
        
        toggleButtonOff(button: off1)
        toggleButtonOff(button: off2)
    }
    
    // toggle any of the attending bar buttons off
    func toggleButtonOff(button: UIButton) {
        button.backgroundColor = UIColor.white
        button.isSelected = false
    }
    
    // add drop shadow to this section and setup text colors
    func partyInfo() {
        infoSectionBackground.layer.applyShadow(color: UIColor.black, alpha: 0.1, x: 0, y: 2, blur: 5, spread: 0)
        
        placeTitle.textColor = darkMint
        timeTitle.textColor = darkMint
        
        addressLine1.textColor = darkGrey
        addressLine2.textColor = mediumGrey
        dateLabel.textColor = darkGrey
        timeLabel.textColor = mediumGrey
    }
    
    // handles the sliding collection view feature
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayedGuests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "guestPicture", for: indexPath) as! GuestPicsCollectionCell
        
        cell.guestButton = guestButtons[indexPath.row]
        
        return cell
    }
    
    func bottomBar() {
        bottomView.layer.applyShadow(color: UIColor.black, alpha: 0.1, x: 0, y: -2, blur: 5, spread: 0)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}



