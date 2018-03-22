//
//  PartyListViewController.swift
//  Parti
//
//  Created by Arjun Gopisetty on 3/3/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit
import FirebaseDatabase

class PartyListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var partyTableView: UITableView!
    var userID = String()
    
    // Firebase connection
    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    // list of parties
    var partyList = [PartyModel]()
    
    /* Returns the number of cells to populate the table with */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return partyList.count
    }
    
    /* Dequeues cells from partyList and returns a filled-in table cell */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "partyCell", for: indexPath) as! PartyTableViewCell
        
        let currentParty = partyList[indexPath.row] 
        
        // update information contained in cell
        cell.partyName.text = currentParty.name
        cell.address.text = currentParty.address
        cell.partyObject = currentParty
        
        // update appearance of cell
//        cell.separatorInset = UIEdgeInsets.zero
//        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "partyCell", for: indexPath) as! PartyTableViewCell
        
        // Segue to the second view controller
        self.performSegue(withIdentifier: "partyCell", sender: cell)
    }

    /* Runs when page is loaded, sets the delegate and datasource then calls method to query
        Firebase and add parties to partyList */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.partyTableView.dataSource = self
        self.partyTableView.delegate = self
        
        // set the style of the table view cells
//        self.partyTableView.layoutMargins = UIEdgeInsets.zero
//        self.partyTableView.separatorInset = UIEdgeInsets.zero
        
        // set firebase reference
        ref = Database.database().reference()
        
        // query Firebase and get a list of all parties for this user
        populatePartyTable()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* Goes through each party a user is attending and adds the party object to the list */
    func populatePartyTable() {
        databaseHandle = ref?.child("users/\(userID)/attending").observe(.childAdded, with: { (snapshot) in
            let partyID = snapshot.key
            self.addParty(partyID: partyID)
        }) { (error) in
            print(error.localizedDescription)
        }
        
        databaseHandle = ref?.child("users/\(userID)/hosting").observe(.childAdded, with: { (snapshot) in
            let partyID = snapshot.key
            self.addParty(partyID: partyID)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    /* Creates an instance of the PartyModel class and fills in all relevant information
        from Firebase query. Adds the PartyModel to partyList and reloads View */
    func addParty(partyID: String) {
        databaseHandle = ref?.child("parties/\(partyID)").observe(.value, with: { (snapshot) in
            let data = snapshot.value as! [String: Any]
            
            let partyObject = PartyModel()
            
            partyObject.attire = data["attire"] as! String
            partyObject.date = data["date"] as! String
            partyObject.hostID = data["hostID"] as! String
            partyObject.name = data["name"] as! String
            partyObject.address = data["address"] as! String

            partyObject.partyID = partyID
            
            if let foodList = data["foodList"] {
                partyObject.foodList = foodList as! NSDictionary
            }
            if let guestList = data["guestList"] {
                partyObject.guestList = guestList as! NSDictionary
            }
            if let image = data["imageURL"] {
                partyObject.imageURL = data["imageURL"] as! String
            }
            
            self.partyList.append(partyObject)
            
            self.partyTableView.reloadData()
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    @IBAction func profileButton(_ sender: Any) {
        self.performSegue(withIdentifier: "partyListToProfile", sender: self)
    }
    
    @IBAction func createEventButton(_ sender: Any) {
        self.performSegue(withIdentifier: "addEvent", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueID = segue.identifier
        
        // Profile Page
        if (segueID == "partyListToProfile") {
            if let destinationVC = segue.destination as? ProfileViewController {
                destinationVC.profileObject.userID = userID
            }
        // Party List Page
        } else if (segueID == "addEvent") {
            if let destinationVC = segue.destination as? CreatePartyViewController {
                destinationVC.partyObject.hostID = userID
            }
        } else if (segueID == "partyCell") {
            if let destinationVC = segue.destination as? PartyPageViewController {
                destinationVC.partyObject.hostID = userID
                
                if let cell = sender as? PartyTableViewCell {
                    destinationVC.partyObject = cell.partyObject
                }
            }
        }
    }

}
