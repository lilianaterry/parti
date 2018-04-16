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
    }
    
    @IBOutlet weak var foodTableView: UITableView!
    
    // Firebase Database connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    var data = [[String: cellData]]()
    var currentTab: Int!
    var currentUser: String!
    
    var partyObject = PartyModel()
    var hostView = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseRef = Database.database().reference()
        
        data = [[:], [:], [:]]
        
        currentTab = 0
        currentUser = Auth.auth().currentUser?.uid
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
            
            // otherwise add them to this food item
        } else {
            data[currentTab][key]?.userData.append(currentUser)
            data[currentTab][key]?.added = true
            data[currentTab][key]?.opened = true
            
            sender.isSelected = false
        }
        
        // reload tableView to reflect the change
        let section = IndexSet.init(integer: button.tag)
        foodTableView.reloadSections(section, with: .none)
    }

    
    
}


