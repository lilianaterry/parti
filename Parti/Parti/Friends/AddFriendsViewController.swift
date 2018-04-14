//
//  AddFriendsViewController.swift
//  Parti
//
//  Created by Arjun Gopisetty on 3/21/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class AddFriendsViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate, UITableViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    // Firebase Database connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    var users = [ProfileModel]()
    
    var profileObject = ProfileModel()
    
    let userID = Auth.auth().currentUser!.uid
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! AddFriendTableViewCell
        var profileModel = ProfileModel()
        profileModel.name = users[indexPath.row].name
        profileModel.userID = users[indexPath.row].userID
        cell.nameLabel?.text = users[indexPath.row].name
        cell.profileModel = profileModel

        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        // set firebase reference
        databaseRef = Database.database().reference()
        // TODO: Fetch friends from Firebase
        populateAllUsersList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // get all the users 
    func populateAllUsersList() {
        databaseHandle = databaseRef?.child("users").queryOrdered(byChild: "name").observe(.childAdded) { snapshot in
            var data = snapshot.value as! [String: Any]
            var user = ProfileModel()
            user.name = data["name"] as! String
            user.userID = snapshot.key
            user.imageURL = data["imageURL"] as! String
            user.username = data["username"] as! String
            
            self.users.append(user)
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! AddFriendTableViewCell
        
        let user = cell.profileModel
        print("Adding friend: " + user.userID)
        
        addFriend(friendUid: user.userID)
    }
    
    func addFriend(friendUid: String) {
        let friendDict = [friendUid: 1]
        let userDict = [userID: 1]
        
        self.databaseRef.child("users/\(friendUid)/friendsList").updateChildValues(userDict)
        self.databaseRef.child("users/\(userID)/friendsList").updateChildValues(friendDict)
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
    
}
