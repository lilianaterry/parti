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
    var foodList = [String]()
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return foodList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath)
        cell.textLabel?.text = foodList[indexPath.row]
        return cell
    }
    
    // Add or remove checkmarks from food items
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        print ("Reached checkmark method ")
        // if there is a checkmark, remove it
        // if there is not a checkmark, add one
        if (cell?.accessoryType == UITableViewCellAccessoryType.checkmark) {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            removeItem()
        } else if (cell?.accessoryType == UITableViewCellAccessoryType.none) {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            addItem()
        } else {
            print("FAILED TO EXECUTE CHECKMARK")
        }
    }
    
    func addItem() {
        
    }
    
    func removeItem() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // set firebase reference
        ref = Database.database().reference()
        
        populateFoodList()
    }
    
    /* Retrieves all foodlist items from Firebase */
    func populateFoodList() {
        let foodRef = ref.child("foodlist");
        
        // get all foodlist items and populate table view
        foodRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                self.foodList.append(key)
            }
            
            self.tableView.reloadData()
        })
    }
    
}
