//
//  CreateFriendListViewController.swift
//  Parti
//
//  Created by Liliana Terry on 3/24/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class CreateFriendListViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // Firebase Database connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    var users = [ProfileModel]()
    var filteredUsers = [ProfileModel]()
    
    var profileObject = ProfileModel()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! AddFriendTableViewCell
        var profileModel = ProfileModel()
        profileModel.name = users[indexPath.row].name
        print(profileModel.name)
        profileModel.userID = users[indexPath.row].userID
        cell.nameLabel?.text = users[indexPath.row].name
        cell.profileModel = profileModel
        cell.newUserButton.tag = indexPath.row;
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        searchBar.delegate = self
        // set firebase reference
        databaseRef = Database.database().reference()
        // TODO: Fetch friends from Firebase
        populateAllFriendsList()
        
        filteredUsers = users
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func populateAllFriendsList() {
        databaseHandle = databaseRef?.child("users").queryOrdered(byChild: "name").observe(.childAdded) { snapshot in
            print(snapshot)
            var data = snapshot.value as! [String: Any]
            var user = ProfileModel()
            user.name = data["name"] as! String
            user.userID = snapshot.key
            
            self.users.append(user)
            self.tableView.reloadData()
        }
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        databaseHandle = databaseRef?.child("users").queryOrdered(byChild: "name").queryEqual(toValue: searchText).observe(.childAdded)
        { snapshot in
            
            var data = snapshot.value as! [String: Any]
            var user = ProfileModel()
            user.name = data["name"] as! String
            user.userID = snapshot.key
            
            self.users.removeAll()
            self.users.append(user)
            self.tableView.reloadData()
        }
    }
    
    /* If user does not finish registering, remove their Auth info */
    @IBAction func newUserCancelRegistration(_ sender: Any) {
        // TODO change this to reauthenticate user if necessary
        let user = Auth.auth().currentUser
        user?.delete()
    }
    
    /* If new user is in the create account flow, the next button saves their added friends
     instead of immediately updating Firebase */
    @IBAction func newUserAddButton(_ sender: UIButton) {
        let button = sender as UIButton;
        let indexPath = IndexPath(row: button.tag, section: 0)
        let cell = tableView.cellForRow(at: indexPath)
        if (cell?.backgroundColor == UIColor.clear) {
            let friendID = users[button.tag].userID
            profileObject.friendsList[friendID] = 1
            cell?.backgroundColor = UIColor.lightGray
            button.setTitle("-", for: .selected)
        } else {
            let friendID = users[button.tag].userID
            profileObject.friendsList.removeValue(forKey: friendID)
            cell?.backgroundColor = UIColor.clear
            button.setTitle("+", for: .normal)
        }
    }
    
    @IBAction func nextButton(_ sender: Any) {
        self.performSegue(withIdentifier: "createStepThree", sender: self)
    }
    /* Move to Add Friend step of registration */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueID = segue.identifier
        
        // Add Food List Page
        if (segueID == "createStepThree") {
            if let destinationVC = segue.destination as? CreateFoodListViewController {
                destinationVC.profileObject = profileObject
            }
        }
    }
    
}
