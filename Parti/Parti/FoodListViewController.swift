//
//  ViewController.swift
//  FoodList
//
//  Created by Liliana Terry on 2/24/18.
//  Copyright © 2018 Liliana Terry. All rights reserved.
//
import UIKit
import FirebaseDatabase

class FoodListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var userID = String()
    
    // Firebase connection
    var ref: DatabaseReference!
    var databaseHandle:DatabaseHandle?
    
    // list of possible food/drink
    var list = [String: Bool]()
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return list.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = Array(list.keys)[indexPath.row]
        let checked = list[item]
        
        cell.textLabel?.text = Array(list.keys)[indexPath.row]
        
        if (checked)! {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        
        return cell
    }
    
    // Add or remove checkmarks from food items
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        print ("Reached checkmark method")
        // if there is a checkmark, remove it
        // if there is not a checkmark, add one
        if (cell?.accessoryType == UITableViewCellAccessoryType.checkmark) {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            updateCheckmark(checked: 0, item: (cell?.textLabel?.text)!)
        } else if (cell?.accessoryType == UITableViewCellAccessoryType.none) {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            updateCheckmark(checked: 1, item: (cell?.textLabel?.text)!)
        } else {
            print("FAILED TO EXECUTE CHECKMARK")
        }
    }
    
    /* Function that adds/removes items to users' individual foodlists
     in the event that a checkmark is added/removed */
    func updateCheckmark(checked: Int, item: String) {
        ref.child("users/\(self.userID)/foodlist/\(item)").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? String
            
            // Does not exist in user's list
            if (value == nil && checked == 1) {
                // update the value
                self.ref.child("users/\(self.userID)/foodlist/\(item)").setValue(checked)
            // Exists and needs to be removed
            } else if (checked == 0) {
                self.ref.child("users/\(self.userID)/foodlist/\(item)").removeValue { error, _ in
                    print("removed item")
                }
            } else {
                print("ERROR")
            }
        }) { (error) in
            print(error.localizedDescription)
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // set firebase reference
        ref = Database.database().reference()
        
        populateTable()
        
        // check for any updates to the table
        checkForTableUpdates()

    }
    
    /* Function that reads in all items from the generic list in Firebase */
    func populateTable() {
        ref.child("foodlist").observeSingleEvent(of: .value, with: { (snapshot) in
            let genericFoodList = snapshot.value as! [String: Bool]
            self.list = genericFoodList
            
            // now check which items this user has checked off
            self.readUserItems()
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    /* Function that reads in all items a specific user has checked and updates local list */
    func readUserItems() {
        // check if the user has any checkmarks added already
        ref.child("users/\(self.userID)/foodlist").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let userFoodList = snapshot.value as! [String: Bool]
            
            for (_, value) in userFoodList.enumerated() {
                self.list[value.key] = true
            }
            
            // update table view with new information
            self.tableView.reloadData()
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    /*  Function that listens to any updates in the main food list */
    func checkForTableUpdates() {
        // MAIN FOODLIST
        databaseHandle = ref?.child("foodlist").observe(.childAdded, with: { (snapshot) in
            // code to execute when a child is added under foodlist
            print("TRIGGERED main foodlist change")
            // take the value from readList and convert it to a string
            let item = snapshot.key as String
            print("key: \(item)")
            
            // if there is actually a value returned and it is not already in our list, add it
            if !(self.list.keys.contains(item)) {
                self.list[item] = false
                print("updated list")
                // update the list to reflect the new change
                self.tableView.reloadData()
            }
            
        })
    }

}
