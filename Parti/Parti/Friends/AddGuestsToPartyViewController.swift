//
//  AddGuestsViewController.swift
//  Parti
//
//  Created by Arjun Gopisetty on 3/30/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class AddGuestsToPartyViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var guestTableView: UITableView!
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! AddGuestsTableViewCell
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
        guestTableView.dataSource = self
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
            print(user.userID)
            user.imageURL = data["imageURL"] as! String
            user.userID = data["username"] as! String
            
            self.users.append(user)
            self.guestTableView.reloadData()
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
            self.guestTableView.reloadData()
        }
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
