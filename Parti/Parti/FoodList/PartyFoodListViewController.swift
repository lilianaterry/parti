//
//  PartyFoodListViewController.swift
//  PartiMusic
//
//  Created by Liliana Terry on 4/12/18.
//  Copyright © 2018 The Party App. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

struct cellData {
    var opened = Bool()
    var count = Int()
    var userData = [String]()
    var added = Bool()
}

class PartyFoodListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // switch to a different table view
    @IBAction func tabBar(_ sender: UISegmentedControl) {
        currentTab = sender.selectedSegmentIndex
        foodTableView.reloadData()
    }
    
    // go back to the main party page
    @IBAction func backButton(_ sender: Any) {
        if (hostView) {
            self.performSegue(withIdentifier: "hostPartyPage", sender: self)
        } else {
            self.performSegue(withIdentifier: "guestPartyPage", sender: self)
        }
        dismiss(animated: false, completion: nil)
    }
    
    @IBOutlet weak var foodTableView: UITableView!
    
    // Firebase Database connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    var data = [[String: cellData]]()
    var sections = ["alcohol", "food", "mixers"]
    var currentTab: Int!
    var currentUser: String!
    var currentUserName: String!
    
    var partyObject = partyCard.init(name: "", address: "", time: 0, date: 0, attire: "", partyID: "", hostID: "", guestList: [:], guests: [], image: UIImage(), imageURL: "", userStatus: 0)
    var hostView = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseRef = Database.database().reference()
        
        data = [[:], [:], [:]]
        
        currentTab = 0
        currentUser = Auth.auth().currentUser?.uid
        databaseRef.child("users/\(currentUser!)/name").observeSingleEvent(of: .value) { (snapshot) in
            self.currentUserName = snapshot.value as! String
        }
        
        loadFoodList()
    }
    
    // number of food items in this tab
    func numberOfSections(in tableView: UITableView) -> Int {
        return data[currentTab].count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // the number of rows is none if the section is not opened
        // the number of rows increases if the section is opened
        if (Array(data[currentTab].values)[section].opened) {
            return Array(data[currentTab].values)[section].userData.count + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // get the item info and populate the cell with it
        let item = Array(data[currentTab].values)[indexPath.section] as cellData
        
        // food item cell
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "partyFoodCell") as! PartyFoodTableViewCell
            
            let name = Array(data[currentTab].keys)[indexPath.section]
            let count = item.count
            
            cell.customInit(name: name, count: count, index: indexPath.section)
            
            return cell
            // name of guest bringing food item
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "guestFoodCell") as! GuestFoodTableViewCell
            
            let name = item.userData[indexPath.row - 1]
            
            cell.customInit(name: name)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = Array(data[currentTab].keys)[indexPath.section]
        // if it is already opened, close it
        if (data[currentTab][key]?.opened)! {
            data[currentTab][key]?.opened = false
            let section = IndexSet.init(integer: indexPath.section)
            tableView.reloadSections(section, with: .none)
        // otherwise open it
        } else {
            data[currentTab][key]?.opened = true
            let section = IndexSet.init(integer: indexPath.section)
            tableView.reloadSections(section, with: .none)
        }
    }
    
    // if the user clicks the add button, they append their name to this item
    @IBAction func addUserToFood(_ sender: UIButton) {
        let button = sender as UIButton
        let item = Array(data[currentTab].values)[button.tag]
        let key = Array(data[currentTab].keys)[button.tag]
        
        // if the user has added themselves already, remove them
        if (item.added) {
            let indexToRemove = item.userData.index(of: currentUser)
            data[currentTab][key]?.userData.remove(at: indexToRemove!)
            data[currentTab][key]?.added = false
            data[currentTab][key]?.opened = true
            
            sender.isSelected = true
            
            removeFromFirebase(section: button.tag, itemName: key)
            
            // otherwise add them to this food item
        } else {
            data[currentTab][key]?.userData.append(currentUser)
            data[currentTab][key]?.added = true
            data[currentTab][key]?.opened = true
            
            sender.isSelected = false
            
            addToFirebase(section: button.tag, itemName: key)
        }
        
        // reload tableView to reflect the change
        let section = IndexSet.init(integer: button.tag)
        foodTableView.reloadSections(section, with: .none)
    }
    
    // let user add themselves to an item and update firebase
    func addToFirebase(section: Int, itemName: String) {
        let sectionName = sections[section]
        databaseRef.child("parties/\(partyObject.partyID)/foodList/\(sectionName)/\(itemName)/guests/\(currentUser!)").setValue(currentUserName)
    }
    
    // let user remove themselves from an item and update firebase
    func removeFromFirebase(section: Int, itemName: String) {
        let sectionName = sections[section]
        databaseRef.child("parties/\(partyObject.partyID)/foodList/\(sectionName)/\(itemName)/guests/\(currentUser!)").removeValue()
    }

    // go through all of the food data that has already been saved
    // then iterate through all guests to get the ordered list of all favorites
    func loadFoodList() {
        // load the food people have already put their names down on
        databaseRef.child("parties/\(partyObject.partyID)/foodList").observeSingleEvent(of: .value) { (snapshot) in
            if (snapshot.exists()) {
                let storedFood = snapshot.value as! [String: Any]
                
                // get alcohol
                if let alcoholList = storedFood["alcohol"] as? [String: Any] {
                    for item in alcoholList.keys {
                        print("item: \(item)")
                        let itemData = alcoholList[item] as! [String: Any]
                        let name = item
                        var guests = [String]()
                        var added = false
                        if let tempGuestList = itemData["guests"] as? [String: Any] {
                            if (tempGuestList.keys.contains(self.currentUser)) {
                                added = true
                            }
                            // add just the names, not the UID
                            for (_, guestName) in tempGuestList {
                                guests.append(guestName as! String)
                            }
                        }
                        
                        let newCell = cellData.init(opened: false, count: 0, userData: guests, added: added)
                        
                        // add this new cell to the data
                        self.data[0][name] = newCell
                    }
                }
                
                // get food
                if let foodList = storedFood["food"] as? [String: Any] {
                    for item in foodList.keys {
                        let itemData = foodList[item] as! [String: Any]
                        let name = item
                        var guests = [String]()
                        var added = false
                        if let tempGuestList = itemData["guests"] as? [String: Any] {
                            if (tempGuestList.keys.contains(self.currentUser)) {
                                added = true
                            }
                            // add just the names, not the UID
                            for (_, guestName) in tempGuestList {
                                guests.append(guestName as! String)
                            }
                        }
                        
                        let newCell = cellData.init(opened: false, count: 0, userData: guests, added: added)
                        
                        // add this new cell to the data
                        self.data[1][name] = newCell
                    }
                }
                
                // get mixers
                if let mixersList = storedFood["mixers"] as? [String: Any] {
                    for item in mixersList.keys {
                        let itemData = mixersList[item] as! [String: Any]
                        let name = item
                        var guests = [String]()
                        var added = false
                        if let tempGuestList = itemData["guests"] as? [String: Any] {
                            if (tempGuestList.keys.contains(self.currentUser)) {
                                added = true
                            }
                            // add just the names, not the UID
                            for (_, guestName) in tempGuestList {
                                guests.append(guestName as! String)
                            }
                        }
                        
                        // don't add the count in case new people have selected items
                        let newCell = cellData.init(opened: false, count: 0, userData: guests, added: added)
                        
                        // add this new cell to the data
                        self.data[2][name] = newCell
                    }
                }
                
                // now get all of the other items that people have not yet put their names down on
                self.getAllUserPreferences()
            } else {
                self.getAllUserPreferences()
            }
        }
    }
    
    // iterate over the foodlist of all users
    func getAllUserPreferences() {
        for guestID in partyObject.guests {
            databaseRef.child("users/\(guestID.userID)/foodList").observeSingleEvent(of: .value, with: { (snapshot) in
                if (snapshot.exists()) {
                    let userInfo = snapshot.value as! [String: Any]
                    
                    // get alcohol
                    if let alcohol = userInfo["alcohol"] as? [String: Any] {
                        for (item, _) in alcohol {
                            // if the item is already in the list, just increment count
                            if (self.data[0].keys.contains(item)) {
                                self.data[0][item]?.count += 1
                            } else {
                                let newCell = cellData.init(opened: false, count: 1, userData: [], added: false)
                                self.data[0][item] = newCell
                            }
                        }
                    }
                    
                    // get food
                    if let food = userInfo["food"] as? [String: Any] {
                        for (item, _) in food {
                            // if the item is already in the list, just increment count
                            if (self.data[1].keys.contains(item)) {
                                self.data[1][item]?.count += 1
                            } else {
                                let newCell = cellData.init(opened: false, count: 1, userData: [], added: false)
                                self.data[1][item] = newCell
                            }
                        }
                    }
                    
                    // get mixers
                    if let mixers = userInfo["mixers"] as? [String: Any] {
                        for (item, _) in mixers {
                            // if the item is already in the list, just increment count
                            if (self.data[2].keys.contains(item)) {
                                self.data[2][item]?.count += 1
                            } else {
                                let newCell = cellData.init(opened: false, count: 1, userData: [], added: false)
                                self.data[2][item] = newCell
                            }
                        }
                    }
                    
                    // now actually update our foodList in the tableview
                    self.foodTableView.reloadData()
                }
            })
        }

    }
    
}


