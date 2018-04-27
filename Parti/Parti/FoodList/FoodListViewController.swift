//
//  ViewController.swift
//  FoodList
//
//  Created by Liliana Terry on 2/24/18.
//  Copyright © 2018 Liliana Terry. All rights reserved.
//
import UIKit
import FirebaseDatabase
import FirebaseAuth

class FoodListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var userID = Auth.auth().currentUser?.uid as! String
    
    // Firebase connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    // list of possible food/drink
    //var foodList = [String: Int]()
    var userFoodList = [String: Any]()
    
    var sections = ["Alcohol", "Food", "Mixers"]
    var alcoholList = [String: Int]()
    var foodList = [String: Int]()
    var mixerList = [String: Int]()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var rowCount = 0
        if section == 0 {
            rowCount = alcoholList.count
        } else if section == 1 {
            rowCount = foodList.count
        } else {
            rowCount = mixerList.count
        }
        return rowCount
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath)
        if (indexPath.section == 0) {
            cell.textLabel?.text = Array(alcoholList)[indexPath.row].key
            
            // if the value in the foodList is 1 mark it as checked
            if (Array(alcoholList)[indexPath.row].value == 1) {
                print(Array(alcoholList)[indexPath.row].key)
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            }
        } else if (indexPath.section == 1) {
            cell.textLabel?.text = Array(foodList)[indexPath.row].key
            
            // if the value in the foodList is 1 mark it as checked
            if (Array(foodList)[indexPath.row].value == 1) {
                print(Array(foodList)[indexPath.row].key)
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            }
        } else {
            cell.textLabel?.text = Array(mixerList)[indexPath.row].key
            
            // if the value in the foodList is 1 mark it as checked
            if (Array(mixerList)[indexPath.row].value == 1) {
                print(Array(mixerList)[indexPath.row].key)
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    // Add or remove checkmarks from food items
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        // if there is a checkmark, remove it
        // if there is not a checkmark, add one
        if (cell?.accessoryType == UITableViewCellAccessoryType.checkmark) {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            removeItem(index: indexPath.row, section: indexPath.section)
        } else if (cell?.accessoryType == UITableViewCellAccessoryType.none) {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            addItem(index: indexPath.row, section: indexPath.section)
        } else {
            print("FAILED TO EXECUTE CHECKMARK")
        }
    }
    
    /* update addition of check in firebase */
    func addItem(index: Int, section: Int) {
        var item = ""
        if (section == 0) {
            item = Array(alcoholList)[index].key
            let value = [item: 1]
            databaseRef.child("users/\(userID)/foodList/alcohol").updateChildValues(value)
        } else if (section == 1) {
            // This wont work until food sections are set up
            item = Array(foodList)[index].key
            let value = [item: 1]
            databaseRef.child("users/\(userID)/foodList/food").updateChildValues(value)
        } else {
            item = Array(mixerList)[index].key
            let value = [item: 1]
            databaseRef.child("users/\(userID)/foodList/mixers").updateChildValues(value)
        }
    }
    
    /* remove check in firebase */
    func removeItem(index: Int, section: Int) {
        var item = ""
        if (section == 0) {
            item = Array(alcoholList)[index].key
            let value = [item: nil] as [String: Any?]
            databaseRef.child("users/\(userID)/foodList/alcohol").updateChildValues(value)
        } else if (section == 1) {
            item = Array(foodList)[index].key
            let value = [item: nil] as [String: Any?]
            databaseRef.child("users/\(userID)/foodList/food").updateChildValues(value)
        } else {
            item = Array(mixerList)[index].key
            let value = [item: nil] as [String: Any?]
            databaseRef.child("users/\(userID)/foodList/mixers").updateChildValues(value)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // set firebase reference
        databaseRef = Database.database().reference()
        
        getUsersAlcList()
    }
    
    /* Get the current users's food preferences and use these to mark generic food list */
    func getUsersAlcList() {
        databaseRef.child("users/\(userID)/foodList/alcohol").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                let foodDict = snapshot.value as! [String: Any]
                for (food, value) in foodDict {
                    self.userFoodList[food] = value
                }
                self.getUsersFoodList()
                
            }
        }
    }
    
    func getUsersFoodList() {
        databaseRef.child("users/\(userID)/foodList/food").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                //print(snapshot.value)
                let foodDict = snapshot.value as! [String: Any]
                for (food, value) in foodDict {
                    self.userFoodList[food] = value
                }
                self.getUsersMixersList()
            }
        }
    }
    
    func getUsersMixersList() {
        databaseRef.child("users/\(userID)/foodList/mixers").observeSingleEvent(of: .value)
        { (snapshot) in
            if snapshot.exists() {
                let foodDict = snapshot.value as! [String: Any]
                for (food, value) in foodDict {
                    self.userFoodList[food] = value
                }
                self.populateAlcoholList()
                self.populateFoodList()
                self.populateMixersList()
            }
        }
    }
    
    func populateAlcoholList() {
        databaseRef.child("foodList/Alcohol").observe(.value) { snapshot in
            //self.alcoholList = snapshot.value as! [String: Any] as! [String : Int]
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                
                // if this item is in the user's list, mark it as checked in the table view
                let containsElement = self.userFoodList.keys.contains(key)
                let checked = containsElement ? 1 : 0
                
                self.alcoholList[key] = checked
            }
            print(self.alcoholList)
            self.tableView.reloadData()
        }
    }
    
    func populateFoodList() {
        databaseRef.child("foodList/Food").observe(.value) { snapshot in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                
                // if this item is in the user's list, mark it as checked in the table view
                let containsElement = self.userFoodList.keys.contains(key)
                let checked = containsElement ? 1 : 0
                
                self.foodList[key] = checked
            }
            self.tableView.reloadData()
        }
    }
    
    func populateMixersList() {
        databaseRef.child("foodList/Mixers").observe(.value) { snapshot in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                
                // if this item is in the user's list, mark it as checked in the table view
                let containsElement = self.userFoodList.keys.contains(key)
                let checked = containsElement ? 1 : 0
                
                self.mixerList[key] = checked
            }
            print(self.mixerList)
            self.tableView.reloadData()
        }
    }
        
        // TODO: need to import checkmarks as well
}
