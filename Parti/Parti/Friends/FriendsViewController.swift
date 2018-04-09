//
//  FriendsViewController.swift
//  Parti
//
//  Created by Arjun Gopisetty on 4/8/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class FriendsViewController: ViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    // Firebase Database connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    var friendUids = [String]()
    var users = [ProfileModel]()
    
    var profileObject = ProfileModel()
    
    let userID = Auth.auth().currentUser!.uid
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendsTableViewCell
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
        
        // set firebase reference
        databaseRef = Database.database().reference()
        // TODO: Fetch friends from Firebase
        populateFriendUids()
        populateFriendsList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // get the friends of the current user
    func populateFriendUids() {
        print(userID)
        databaseRef.child("users/\(userID)/friendsList").observe(.value) { snapshot in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                self.friendUids.append(snap.key)
            }
        }
        print("Friend UIDs: ")
        print(friendUids)
    }
    
    func populateFriendsList() {
        for uid in friendUids {
            databaseRef.child("users/\(uid)").observe(.childAdded)
            { snapshot in
                var data = snapshot.value as! [String: Any]
                var user = ProfileModel()
                user.name = data["name"] as! String
                user.userID = snapshot.key
                user.imageURL = data["imageURL"] as! String
                user.userID = data["username"] as! String
                
                self.users.append(user)
                self.tableView.reloadData()
            }
        }
    }

}
