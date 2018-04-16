//
//  AddGuestsViewController.swift
//  Parti
//
//  Created by Arjun Gopisetty on 3/30/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AddGuestsToPartyViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate, UITableViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var guestTableView: UITableView!
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    // Firebase Database connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    var users = [ProfileModel]()
    var invitedUsers = [String : Int]()
    
    var partyObject = PartyModel()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! AddGuestsTableViewCell
        var profileModel = ProfileModel()
        profileModel.name = users[indexPath.row].name
        profileModel.userID = users[indexPath.row].userID
        
        // Check if user has already been invitied
        //print("Checking if user is attending")
        if (invitedUsers[profileModel.userID] == 1) {
            print("User is attending")
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        
        cell.nameLabel?.text = users[indexPath.row].name
        cell.profileModel = profileModel
        return cell
    }
    
    // When a user is clicked
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! AddGuestsTableViewCell
        
        let user = cell.profileModel
        
        // if there is a checkmark, remove it
        // if there is not a checkmark, add one
        if (cell.accessoryType == UITableViewCellAccessoryType.checkmark) {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            let guestID = user?.userID
            removeFromParty(userID: guestID!)
        } else if (cell.accessoryType == UITableViewCellAccessoryType.none) {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            let guestID = user?.userID
            addToParty(userID: guestID!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        guestTableView.dataSource = self
        guestTableView.delegate = self
        searchBar.delegate = self
        
        // set firebase reference
        databaseRef = Database.database().reference()
        
        populateAllFriendsList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // get all users (for now)
    func populateAllFriendsList() {
        databaseHandle = databaseRef?.child("users").queryOrdered(byChild: "name").observe(.childAdded) { snapshot in
            var data = snapshot.value as! [String: Any]
            // show all people that aren't the host
            if (snapshot.key != self.partyObject.hostID) {
                var user = ProfileModel()
                user.name = data["name"] as! String
                user.userID = snapshot.key
                if let imageURL = data["imageURL"] {
                    self.getPicture(userID: user.userID, user: user)
                }
                self.populateGuestAttending(profileModel: user)
            }
        }
    }
    
    // Populates dictionary with guests attending
    func populateGuestAttending(profileModel: ProfileModel) {
        databaseRef.child("parties/\(partyObject.partyID)/guests").observeSingleEvent(of: .value) { (snapshot) in
            if (snapshot.hasChild(profileModel.userID)) {
                //print("Attending")
                print(profileModel.userID)
                self.invitedUsers[profileModel.userID] = 1
            }
//            else {
//                print("Not attending")
//                print(profileModel.userID)
//                self.invitedUsers[profileModel.userID] = 0
//            }
            self.guestTableView.reloadData()
        }
    }
    
    // get the user's profile picture
    func getPicture(userID: String, user: ProfileModel) {
        // get the profile picture for this user
        databaseHandle = databaseRef?.child("users/\(userID)/imageURL").observe(.value, with: { (snapshot) in
            if (snapshot.exists()) {
                
                // If the user already has a profile picture, load it up!
                if let imageURL = snapshot.value as? String {
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
                                self.guestTableView.reloadData()
                            }
                        }
                    }).resume()
                    // otherwise use this temporary image
                } else {
                    user.image = #imageLiteral(resourceName: "parti_logo")
                    
                    self.users.append(user)
                    self.guestTableView.reloadData()
                }
            }
        })
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        databaseHandle = databaseRef?.child("users").queryOrdered(byChild: "name").queryEqual(toValue: searchText).observe(.childAdded)
        { snapshot in
            
            var data = snapshot.value as! [String: Any]
            // show all people that aren't the host
            if (snapshot.key != self.partyObject.hostID) {
                var user = ProfileModel()
                user.name = data["name"] as! String
                user.userID = snapshot.key
                
                self.users.removeAll()
                self.users.append(user)
                self.guestTableView.reloadData()
            }
        }
    }
    
    // update firebase, add user to guest list of this party
    func addToParty(userID: String) {
        let newGuest = [userID: 1]
        let newParty = [partyObject.partyID: 1]
        
        // add user to party
        databaseRef.child("parties/\(partyObject.partyID)/guests").updateChildValues(newGuest)
        
        // add party to user
        databaseRef.child("users/\(userID)/attending").updateChildValues(newParty)
    }
    
    // update firebase, remove user from guest list of this party
    func removeFromParty(userID: String) {
        // remove user from party
        databaseRef.child("parties/\(partyObject.partyID)/guests/\(userID)").removeValue()

        // remove party from user
        databaseRef.child("users/\(userID)/attending/\(partyObject.partyID)").removeValue()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueID = segue.identifier

        if (segueID == "backToParty") {
            if let destinationVC = segue.destination as? PartyHostViewController {
                destinationVC.partyObject.partyID = partyObject.partyID
            }
        }
    }
 
}
