//
//  AddFriendsViewController.swift
//  Parti
//
//  Created by Arjun Gopisetty on 3/21/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AddFriendsViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate {
    
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
            var data = snapshot.value as! [String: Any]
            var user = ProfileModel()
            user.name = data["name"] as! String
            user.userID = snapshot.key
            print(user.userID)
            //user.pictureURL = data["pictureURL"] as! String
            //user.userID = data["username"] as! String
            
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

    
    @IBAction func newUserAddButton(_ sender: UIButton) {
        let button = sender as UIButton;
        
    }
    
}
