//
//  ViewController.swift
//  PartyUI
//
//  Created by Liliana Terry on 4/17/18.
//  Copyright © 2018 The Party App. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
import FirebaseStorage

struct partyCard {
    var name: String
    var address: String
    var time: Double
    var date: Double
    var attire: String
    var partyID: String
    var hostID: String
    var guestList: [String: Any]
    
    var image: UIImage
    var imageURL: String
    
    var userStatus: Int
}

class PartyListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var attendingSection: UIButton!
    @IBAction func attendingSection(_ sender: Any) {
        toggleSections(sender: attendingSection, other: hostingSection)
        displaying = attending
        partyTableView.reloadData()
    }
    @IBOutlet weak var hostingSection: UIButton!
    @IBAction func hostingSection(_ sender: Any) {
        toggleSections(sender: hostingSection, other: attendingSection)
        displaying = hosting
        partyTableView.reloadData()
    }
    
    @IBOutlet weak var partyTableView: UITableView!
    
    var hosting = [partyCard]()
    var attending = [partyCard]()
    var displaying = [partyCard]()
    var displayBool = Bool()
    
    var colors = UIExtensions()
    
    // current userID
    var userID = Auth.auth().currentUser?.uid as! String
    
    // Firebase connection
    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    // Firebase Storage connection
    var storageRef: StorageReference!
    var storageHandle: StorageHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        partyTableView.delegate = self
        partyTableView.dataSource = self
        
        headerAndBackground()
        
        // initially view only attending parties
        displaying = attending
        displayBool = true
        
        // set firebase reference
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        // query Firebase and get a list of all parties being attended for this user
        populateAttendingPartyList()
        // query Firebase and get a list of all parties being hosted for this user
        populateHostingPartyList()
    }
    
    /* Dequeues cells from partyList and returns a filled-in table cell */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var currentParty: partyCard = displaying[indexPath.row]
        
        // attending
        if (displayBool) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "partyCardCell", for: indexPath) as! PartyCardCell
            
            currentParty = displaying[indexPath.row]
            
            cell.nameLabel.text = currentParty.name
            cell.addressLabel.text = currentParty.address
            cell.dateLabel.text = "null"
            cell.timeLabel.text = "null"
            
            ref.child("users/\(userID)/attending/\(currentParty.partyID)").observe(.value, with: { (snapshot) in
                if (snapshot.exists()) {
                    
                    let value = snapshot.value as! Int
                    
                    if (value == 1) {
                        cell.goingButton.isSelected = true
                    } else if (value == 0) {
                        cell.maybeButton.isSelected = true
                    } else {
                        cell.notGoingButton.isSelected = true
                    }
                }
            })
            
            return cell
            
        // hosting
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "partyCardCell", for: indexPath) as! PartyCardCell
            
            cell.nameLabel.text = currentParty.name
            cell.addressLabel.text = currentParty.address
            cell.dateLabel.text = "null"
            cell.timeLabel.text = "null"
            
            return cell
        }
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "partyCardCell", for: indexPath) as! PartyCardCell
            // Segue to the party hosting view controller
            self.performSegue(withIdentifier: "hostingPartySegue", sender: cell)
        } else if (indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "partyCardCell", for: indexPath) as! PartyCardCell
            // Segue to the party attending view controller
            self.performSegue(withIdentifier: "attendingPartySegue", sender: cell)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displaying.count
    }
    
    /* Goes through each party a user is hosting and adds the party object to the list */
    func populateHostingPartyList() {
        ref?.child("users/\(userID)/hosting").observe(.childAdded, with: { (snapshot) in
            if (snapshot.exists()) {
                let partyID = snapshot.key
                self.addParty(partyID: partyID, section: 0)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    /* Goes through each party a user is attending and adds the party object to the list */
    func populateAttendingPartyList() {
        ref?.child("users/\(userID)/attending").observe(.childAdded, with: { (snapshot) in
            if (snapshot.exists()) {
                let partyID = snapshot.key
                self.addParty(partyID: partyID, section: 1)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    /* Creates an instance of the PartyModel class and fills in all relevant information
     from Firebase query. Adds the PartyModel to partyList and reloads View */
    func addParty(partyID: String, section: Int) {
        ref?.child("parties/\(partyID)").observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.value as! [String: Any]
            
            var partyObject = partyCard.init(name: "", address: "", time: 0, date: 0, attire: "", partyID: "", hostID: "", guestList: [:], image: UIImage(), imageURL: "", userStatus: 0)
            
            partyObject.attire = data["attire"] as! String
            //partyObject.date = Double(data["date"] as! String)
            partyObject.hostID = data["hostID"] as! String
            partyObject.name = data["name"] as! String
            partyObject.address = data["address"] as! String
            
            partyObject.partyID = partyID
            
            if let guestList = data["guests"] {
                partyObject.guestList = guestList as! [String: Any]
            }
            if let image = data["imageURL"] {
                partyObject.imageURL = image as! String
            }
            
            // If the user already has a profile picture, load it up!
            if (partyObject.imageURL != "") {
                let url = URL(string: partyObject.imageURL)
                URLSession.shared.dataTask(with: url!, completionHandler: { (image, response, error) in
                    if (error != nil) {
                        print(error)
                        return
                    }
                    DispatchQueue.main.async { // Make sure you're on the main thread here
                        if let image = UIImage(data: image!) {
                            partyObject.image = image
                            
                            if (section == 0) {
                                self.hosting.append(partyObject)
                            } else if (section == 1) {
                                self.attending.append(partyObject)
                            }
                            
                            self.displaying = self.attending
                            
                            self.partyTableView.reloadData()
                        }
                    }
                }).resume()
                // otherwise use this temporary image
            } else {
                partyObject.image = #imageLiteral(resourceName: "parti_logo")
                
                if (section == 0) {
                    self.hosting.append(partyObject)
                } else if (section == 1) {
                    self.attending.append(partyObject)
                }
                
                self.displaying = self.attending
                
                self.partyTableView.reloadData()
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    @IBOutlet weak var createEventButton: UIButton!
    @IBAction func createEventButton(_ sender: Any) {
        self.performSegue(withIdentifier: "addEvent", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueID = segue.identifier
        if (segueID == "hostingPartySegue") {
            let cell = sender as! HostingPartyTableViewCell
            if let destinationVC = segue.destination as? PartyHostViewController {
                destinationVC.partyObject = cell.partyObject
            }
        } else if (segueID == "attendingPartySegue") {
            let cell = sender as! AttendingPartyTableViewCell
            if let destinationVC = segue.destination as? PartyPageViewController {
                destinationVC.partyObject = cell.partyObject
            }
        }
    }
    
    
    // ************************ UI *********************************
    
    // setup coloring on header and background of view
    func headerAndBackground() {
        mainView.backgroundColor = colors.mainColor
        headerView.backgroundColor = colors.mainColor
        partyTableView.backgroundView?.backgroundColor = colors.backgroundLightGrey
        
        attendingSection.setTitleColor(colors.darkMint, for: .normal)
        attendingSection.setTitleColor(UIColor.white, for: .selected)
        toggleSections(sender: attendingSection, other: hostingSection)
        
        hostingSection.setTitleColor(colors.darkMint, for: .normal)
        hostingSection.setTitleColor(UIColor.white, for: .selected)
        
        createEventButton.tintColor = UIColor.white
    }
    
    // turn buttons on and off
    func toggleSections(sender: UIButton, other: UIButton) {
        // deselect
        if (sender.isSelected) {
            sender.isSelected = false
            removeUnderline(sender: sender)
        } else {
            sender.isSelected = true
            // add underline
            sender.layer.addBorder(edge: .bottom, color: UIColor.white, thickness: 2.0)
            
            other.isSelected = false
            removeUnderline(sender: other)
        }
        
    }
    
    // remove underline from this button
    func removeUnderline(sender: UIButton) {
        if sender.layer.sublayers != nil {
            for layer in sender.layer.sublayers! {
                if (layer.name == "underline") {
                    layer.removeFromSuperlayer()
                }
            }
        }
    }

    
}
