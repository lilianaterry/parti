//
//  PartyListViewController.swift
//  Parti
//
//  Created by Arjun Gopisetty on 3/3/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
import FirebaseStorage

class PartyListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var partyTableView: UITableView!
    
    // current userID
    var userID = Auth.auth().currentUser?.uid as! String
    
    // Firebase connection
    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    // Firebase Storage connection
    var storageRef: StorageReference!
    var storageHandle: StorageHandle?
    
    // list of parties being attended
    var attendingPartyList = [PartyModel]()
    // list of parties being hosted
    var hostingPartyList = [PartyModel]()
    
    let sections = ["Hosting", "Attending"]
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    /* Returns the number of cells to populate the table with */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        if section == 0 {
            rowCount = hostingPartyList.count
        }
        if section == 1 {
            rowCount = attendingPartyList.count
        }
        return rowCount
    }
    
    /* Dequeues cells from partyList and returns a filled-in table cell */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var currentParty: PartyModel = PartyModel()

        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "hostingPartyCell", for: indexPath) as! HostingPartyTableViewCell
            
            currentParty = hostingPartyList[indexPath.row]
            
            cell.partyName.text = currentParty.name
            cell.address.text = currentParty.address
            cell.partyObject = currentParty
            cell.partyPicture.image = currentParty.image
            
            return cell
        } else if (indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "partyCell", for: indexPath) as! AttendingPartyTableViewCell
            print("indexPath: \(indexPath.row)")
            print("section: \(indexPath.section)")
            currentParty = attendingPartyList[indexPath.row] as PartyModel
            
            cell.partyName.text = currentParty.name
            cell.address.text = currentParty.address
            cell.partyObject = currentParty
            cell.partyPicture.image = currentParty.image
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }

    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "hostingPartyCell", for: indexPath) as! HostingPartyTableViewCell
            // Segue to the party hosting view controller
            self.performSegue(withIdentifier: "hostingPartySegue", sender: cell)
        } else if (indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "partyCell", for: indexPath) as! AttendingPartyTableViewCell
            // Segue to the party attending view controller
            self.performSegue(withIdentifier: "attendingPartySegue", sender: cell)
        }
    }


    /* Runs when page is loaded, sets the delegate and datasource then calls method to query
        Firebase and add parties to partyList */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.partyTableView.dataSource = self
        self.partyTableView.delegate = self
        
        // set firebase reference
        ref = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        // query Firebase and get a list of all parties being attended for this user
        populateAttendingPartyList()
        // query Firebase and get a list of all parties being hosted for this user
        populateHostingPartyList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                print(snapshot.key)
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
            print("adding party to section: \(section)")
            let data = snapshot.value as! [String: Any]
            
            let partyObject = PartyModel()
            
            partyObject.attire = data["attire"] as! String
            partyObject.date = data["date"] as! String
            partyObject.hostID = data["hostID"] as! String
            partyObject.name = data["name"] as! String
            partyObject.address = data["address"] as! String

            partyObject.partyID = partyID
            
            if let foodList = data["foodList"] {
                partyObject.foodList = foodList as! [String: Any]
            }
            if let guestList = data["guestList"] {
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
                                self.hostingPartyList.append(partyObject)
                            } else if (section == 1) {
                                self.attendingPartyList.append(partyObject)
                            }
                            
                            self.partyTableView.reloadData()
                        }
                    }
                }).resume()
                // otherwise use this temporary image
            } else {
                partyObject.image = #imageLiteral(resourceName: "parti_logo")
                
                if (section == 0) {
                    self.hostingPartyList.append(partyObject)
                } else if (section == 1) {
                    self.attendingPartyList.append(partyObject)
                }
                
                self.partyTableView.reloadData()
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
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

}
