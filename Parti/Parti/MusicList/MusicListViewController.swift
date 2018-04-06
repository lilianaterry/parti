////
////  MusicListViewController.swift
////  Parti
////
////  Created by Liliana Terry on 4/4/18.
////  Copyright © 2018 Arjun Gopisetty. All rights reserved.
////
//
//import UIKit
//import FirebaseDatabase
//
//class MusicListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//
//    // Firebase connection
//    var databaseRef: DatabaseReference!
//    var databaseHandle:DatabaseHandle?
//
//    var musicList = [String: Int]()
//
//    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
//    {
//        return musicList.count
//    }
//
//    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
//    {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "musicCell", for: indexPath)
//        cell.textLabel?.text = Array(foodList)[indexPath.row].key
//
//        // if the value in the foodList is 1 mark it as checked
//        if (Array(foodList)[indexPath.row].value == 1) {
//            cell.accessoryType = UITableViewCellAccessoryType.checkmark
//        }
//
//        return cell
//    }
//
//    // Add or remove checkmarks from food items
//    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath)
//        // if there is a checkmark, remove it
//        // if there is not a checkmark, add one
//        if (cell?.accessoryType == UITableViewCellAccessoryType.checkmark) {
//            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
//            removeItem(index: indexPath.row)
//        } else if (cell?.accessoryType == UITableViewCellAccessoryType.none) {
//            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
//            addItem(index: indexPath.row)
//        } else {
//            print("FAILED TO EXECUTE CHECKMARK")
//        }
//    }
//
//    /* update addition of check in firebase */
//    func addItem(index: Int) {
//        let item = Array(foodList)[index].key
//        let value = [item: 1]
//        databaseRef.child("users/\(userID)/foodList").updateChildValues(value)
//    }
//
//    /* remove check in firebase */
//    func removeItem(index: Int) {
//        let item = Array(foodList)[index].key
//        let value = [item: nil] as [String: Any?]
//        databaseRef.child("users/\(userID)/foodList").updateChildValues(value)
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.tableView.dataSource = self
//        self.tableView.delegate = self
//
//        // set firebase reference
//        databaseRef = Database.database().reference()
//
//        getUsersFoodList()
//    }
//
//    /* Get the current users's food preferences and use these to mark generic food list */
//    func getUsersFoodList() {
//        databaseRef.child("users/\(userID)/foodList").observeSingleEvent(of: .value) { (snapshot) in
//            if snapshot.exists() {
//                self.userFoodList = snapshot.value as! [String: Any]
//            }
//            self.populateFoodList()
//        }
//
//    }
//
//    /* Retrieves all foodlist items from Firebase */
//    func populateFoodList() {
//        // get all foodlist items and populate table view
//        let foodRef = databaseRef.child("foodlist");
//
//        // order the list so it's not a mess
//        foodRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
//            self.foodList = snapshot.value as! [String: Any] as! [String : Int]
//            for child in snapshot.children {
//                let snap = child as! DataSnapshot
//                let key = snap.key
//
//                // if this item is in the user's list, mark it as checked in the table view
//                let containsElement = self.userFoodList.keys.contains(key)
//                let checked = containsElement ? 1 : 0
//
//                self.foodList[key] = checked
//            }
//
//            self.tableView.reloadData()
//        })
//    }
//
//}
//
