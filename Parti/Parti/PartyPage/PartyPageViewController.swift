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
import FirebaseAuth

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
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var goingButton: UIButton!
    @IBAction func goingButton(_ sender: Any) {
        goingButton.isSelected = true
        notGoingButton.isSelected = false
        maybeButton.isSelected = false
        
        // Set firebase value equal to 1
        let userID = Auth.auth().currentUser!.uid
        databaseRef.child("users/\(userID)/attending/\(partyObject.partyID)").setValue(1)
    }
    @IBOutlet weak var notGoingButton: UIButton!
    @IBAction func notGoingButton(_ sender: Any) {
        goingButton.isSelected = false
        notGoingButton.isSelected = true
        maybeButton.isSelected = false
        
        // Set firebase value equal to -1
        let userID = Auth.auth().currentUser!.uid
        databaseRef.child("users/\(userID)/attending/\(partyObject.partyID)").setValue(-1)
    }
    @IBOutlet weak var maybeButton: UIButton!
    @IBAction func maybeButton(_ sender: Any) {
        goingButton.isSelected = false
        notGoingButton.isSelected = false
        maybeButton.isSelected = true
        
        // Set firebase value equal to 0
        let userID = Auth.auth().currentUser!.uid
        databaseRef.child("users/\(userID)/attending/\(partyObject.partyID)").setValue(0)
    }
    
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
        //dateLabel.text = partyObject.date
        attireLabel.text = partyObject.attire
        
        
        guestButtons = [guest5, guest6, guest7]
        
        setupGuestButtons()
        setupUX()
        
        // Do any additional setup after loading the view.
        getGuests()

    }
    
    // sets up borders and colors for buttons and other items
    func setupUX() {
        // overlay on banner picture
        let overlay: UIView = UIView(frame: CGRect(x: 0, y: 0, width: partyImage.frame.size.width, height: partyImage.frame.size.height))
        overlay.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.1)
        partyImage.addSubview(overlay)
        
        // buttons user clicks if they are attending
        let color = UIColor(hex: "55efc4")
        goingButton.setBackgroundColor(color, for: .selected)
        goingButton.adjustsImageWhenHighlighted = false
        notGoingButton.setBackgroundColor(color, for: .selected)
        notGoingButton.adjustsImageWhenHighlighted = false
        maybeButton.setBackgroundColor(color, for: .selected)
        maybeButton.adjustsImageWhenHighlighted = false
        
        // add drop shadow to text on banner image
        nameLabel.textDropShadow()
        attireLabel.textDropShadow()

    }
    
    /* makes buttons iterable and now we can tell which profile to go to */
    func setupGuestButtons() {
        guest5.tag = 0
        
        guest5.imageView?.layer.cornerRadius = (guest5.imageView?.frame.size.width)! / 2
        guest5.imageView?.clipsToBounds = true
        
        guest6.tag = 1
        guest6.imageView?.layer.cornerRadius = (guest6.imageView?.frame.size.width)! / 2
        guest6.imageView?.clipsToBounds = true
        
        guest7.tag = 2
        guest7.imageView?.layer.cornerRadius = (guest7.imageView?.frame.size.width)! / 2
        guest7.imageView?.clipsToBounds = true
    }
    
    /* iterates over all guests invited to the party to populate profile objects and get allergies */
    func getGuests() {
        databaseRef.child("parties/\(partyObject.partyID)/guests").observe(.childAdded) { (snapshot) in
            if snapshot.exists() {
                //let snap = snapshot as! DataSnapshot
                let userID = snapshot.key
                
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

// allows you to change background color of button
extension UIButton {
    private func imageWithColor(color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func setBackgroundColor(_ color: UIColor, for state: UIControlState) {
        self.setBackgroundImage(imageWithColor(color: color), for: state)
    }
}

// allows you to get a color object from a hex number
extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

extension UILabel {
    func textDropShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 1, height: 2)
    }
    
    static func createCustomLabel() -> UILabel {
        let label = UILabel()
        label.textDropShadow()
        return label
    }
}
