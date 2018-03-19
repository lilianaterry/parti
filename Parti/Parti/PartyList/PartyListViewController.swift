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
        let uuid = UUID().uuidString
        print(uuid)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "partyCell", for: indexPath) as! PartyTableViewCell
        
        let currentParty = partyList[indexPath.row] 
        
        // update information contained in cell
        cell.partyName.text = currentParty.name
        cell.address.text = currentParty.address
        
        // update appearance of cell
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }

    /* Runs when page is loaded, sets the delegate and datasource then calls method to query
        Firebase and add parties to partyList */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.partyTableView.dataSource = self
        self.partyTableView.delegate = self
        
        // set the style of the table view cells        
        self.partyTableView.layoutMargins = UIEdgeInsets.zero
        self.partyTableView.separatorInset = UIEdgeInsets.zero
        
        // set firebase reference
        ref = Database.database().reference()
        
        // query Firebase and get a list of all parties for this user
        populatePartyTable()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* Creates an instance of the PartyModel class and fills in all relevant information
        from Firebase query. Adds the PartyModel to partyList and reloads View */
    func populatePartyTable() {
        databaseHandle = ref?.child("parties").observe(.childAdded, with: { (snapshot) in
            let partyID = snapshot.key
            let data = snapshot.value as! [String: Any]
            
            var partyObject = PartyModel()
            partyObject.attire = data["attire"] as! String
            partyObject.date = data["date"] as! String
            partyObject.foodList = data["foodlist"] as! NSDictionary
            partyObject.guestList = data["guests"] as! NSDictionary
            partyObject.hostID = data["host"] as! String
            partyObject.name = data["name"] as! String
            partyObject.address = data["address"] as! String
            partyObject.imageURL = data["imageURL"] as! String
            
            self.partyList.append(partyObject)
            
            self.partyTableView.reloadData()
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }


}
