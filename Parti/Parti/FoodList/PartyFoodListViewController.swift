//
//  PartyFoodListViewController.swift
//  Parti
//
//  Created by Liliana Terry on 4/6/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class PartyFoodListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    // Firebase connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    var partyObject = PartyModel()
    
    // list of possible food/drink
    var foodList = [String: Int]()
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return foodList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "partyFoodCell", for: indexPath) as! PartyFoodCell
        
        cell.foodLabel.text = Array(foodList)[indexPath.row].key
        let count = foodList[cell.foodLabel.text!] as! Int
        cell.countLabel.text = String(count)
        
        return cell
    }
    
    // Add or remove checkmarks from food items
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // set firebase reference
        databaseRef = Database.database().reference()
        
        getGuests()
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
    
    /* Get all of the food information for these guests */
    func queryGuestInfo(userID: String) {
        databaseRef.child("users/\(userID)").observe(.value) { (snapshot) in
            // add all user information to the profile model object
            if (snapshot.exists()) {
                let data = snapshot.value as! [String: Any]

                // iterate over all of the users' food
                if let food = data["foodList"] {
                    let userList = food as! [String: Any]
                    
                    for item in userList.keys {
                        if (self.foodList.keys.contains(item)) {
                            var count = self.foodList[item]
                            count = count! + 1
                            self.foodList[item] = count
                        } else {
                            self.foodList[item] = 1
                        }
                    }
                }
                
                self.tableView.reloadData()
                
            } else {
                print("No user in Firebase yet")
            }
        }
    }
}

