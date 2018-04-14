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

class FriendsViewController: ViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendsTableViewCell
        
        var profileModel = ProfileModel()
        
        profileModel.name = users[indexPath.row].name
        profileModel.userID = users[indexPath.row].userID
        cell.nameLabel?.text = users[indexPath.row].name
        cell.profilePicture.image = users[indexPath.row].image
        
        cell.profileModel = profileModel
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        // set firebase reference
        databaseRef = Database.database().reference()
        
        // TODO: Fetch friends from Firebase
        getFriends()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // get the friends of the current user
    func getFriends() {
        users.removeAll()
        databaseRef.child("users/\(userID)/friendsList").observe(.value) { snapshot in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                self.getFriendData(friendID: snap.key)
            }
        }
    }
    
    // get information on a single friend
    func getFriendData(friendID: String) {
        databaseRef.child("users/\(friendID)").observeSingleEvent(of: .value) { (snapshot) in
            var data = snapshot.value as! [String: Any]
            var user = ProfileModel()
            user.name = data["name"] as! String
            user.userID = snapshot.key
            user.username = data["username"] as! String
            
            
            // If the user already has a profile picture, load it up!
            if let imageURL = data["imageURL"] as? String {
                user.imageURL = imageURL
                let url = URL(string: imageURL)
                URLSession.shared.dataTask(with: url!, completionHandler: { (image, response, error) in
                    if (error != nil) {
                        print(error)
                        return
                    }
                    DispatchQueue.main.async { // Make sure you're on the main thread here
                        if let image = UIImage(data: image!) {
                            user.image = image
                            self.users.append(user)
                            self.tableView.reloadData()
                        }
                    }
                }).resume()
                // otherwise use this temporary image
            } else {
                user.image = #imageLiteral(resourceName: "parti_logo")
                self.users.append(user)
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FriendsTableViewCell
        
        let user = cell.profileModel
        
        promptForRemoveFriend(friendUid: user.userID)
    }
    
    func promptForRemoveFriend(friendUid: String) {
        let alert = UIAlertController(title: "Remove friend?", message: "Are you sure you want to remove this friend?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            print("Removing friend")
            self.databaseRef.child("users/\(self.userID)/friendsList/").observeSingleEvent(of: .value, with: { (snapshot) in
                if (snapshot.hasChild(friendUid)) {
                    self.removeFriend(friendUid: friendUid)
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func removeFriend(friendUid: String) {
        self.databaseRef.child("users/\(friendUid)/friendsList/\(userID)").removeValue()
        self.databaseRef.child("users/\(userID)/friendsList/\(friendUid)").removeValue()
        users.removeAll()
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)?)
    {
        super.dismiss(animated: flag, completion: completion)
        print("Coming back from add friends")
        users.removeAll()
    }
}
