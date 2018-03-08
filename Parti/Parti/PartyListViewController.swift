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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("in list count")
        return partyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("in tableview populate")
        let uuid = UUID().uuidString
        print(uuid)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "partyCell", for: indexPath) as! PartyTableViewCell
        
        let currentParty = partyList[indexPath.row] as! PartyModel
        
        //cell.imageView?.image =
        //cell.profilePicture.image =
        cell.partyName.text = currentParty.partyName
        cell.address.text = currentParty.address
        
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.partyTableView.dataSource = self
        self.partyTableView.delegate = self
        
        // set firebase reference
        ref = Database.database().reference()
        
        print("In the party page")

        populatePartyTable()
        
        //self.partyTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func populatePartyTable() {
        databaseHandle = ref?.child("parties").observe(.childAdded, with: { (snapshot) in
            let partyID = snapshot.key
            let data = snapshot.value as! [String: Any]
            
            var partyObject = PartyModel()
            partyObject.attire = data["attire"] as! String
            partyObject.dateTime = data["datetime"] as! String
            partyObject.foodList = data["foodlist"] as! NSDictionary
            partyObject.guests = data["guests"] as! NSDictionary
            partyObject.host = data["host"] as! String
            partyObject.partyName = data["partyname"] as! String
            partyObject.address = data["address"] as! String
            
            self.partyList.append(partyObject)
            
            self.partyTableView.reloadData()
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func checkForUpdates() {
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
