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
        print("item \(item)")
        print("checked \(checked)")
        
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
        } else if (cell?.accessoryType == UITableViewCellAccessoryType.none) {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            
        } else {
            print("FAILED TO EXECUTE CHECKMARK")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // set firebase reference
        ref = Database.database().reference()
        
        // read in all food items to table view
        populateTable()
    }
    
    /*  Function that reads in all food/drink items and checks if this user
        has checked any off already */
    func populateTable() {
        databaseHandle = ref?.child("foodlist").observe(.childAdded, with: { (snapshot) in
            // code to execute when a child is added under foodlist
            
            // take the value from readList and convert it to a string
            let item = snapshot.value as? String
            
            // if there is actually a value returned, add it to our list
            if let actualItem = item  {
                // add a checkmark if need be
                self.isChecked(item: actualItem)
            }
        })
        
        // update the list to reflect the new change
        self.tableView.reloadData()
    }
    
    /* Function that checks if single item has been checked and returns
        true for checked, false for unchecked */
    func isChecked(item: String) {
        // check if the user has any checkmarks added already
        ref.child("users/\(self.userID)/foodlist/").observe(.childAdded, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? String
            
            // if the
            if (value == nil) {
                print("no items in list")
            } else if (value == item) {
                print("item in list matches this item")
                print("item: \(item)")
                print("value: \(value)")
                self.list[item] = true
            } else {
                print("item in list does not match this item")
                self.list[item] = false
                print(self.list)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
