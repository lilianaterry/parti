//
//  AddGuestsViewController.swift
//  Parti
//
//  Created by Arjun Gopisetty on 3/30/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AddGuestsToPartyViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var guestTableView: UITableView!
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    // Firebase Database connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    var users = [ProfileModel]()
    var filteredUsers = [ProfileModel]()
    
    var partyObject = PartyModel()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! AddGuestsTableViewCell
        var profileModel = ProfileModel()
        profileModel.name = users[indexPath.row].name
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
            var data = snapshot.value as! [String: Any]
            var user = ProfileModel()
            user.name = data["name"] as! String
            user.userID = snapshot.key
            if let imageURL = data["imageURL"] {
                user.imageURL = imageURL as! String
            }
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
    
    /* Adds this friend to the guest list ooooh so exclusive */
    @IBAction func newUserAddButton(_ sender: UIButton) {
        let button = sender as UIButton;
        let indexPath = IndexPath(row: button.tag, section: 0)
        let cell = guestTableView.cellForRow(at: indexPath)
        if (cell?.backgroundColor == UIColor.clear) {
            let guestID = users[button.tag].userID
            cell?.backgroundColor = UIColor.lightGray
            button.setTitle("-", for: .selected)
            addToParty(userID: guestID)
        } else {
            let guestID = users[button.tag].userID
            cell?.backgroundColor = UIColor.clear
            button.setTitle("+", for: .normal)
            removeFromParty(userID: guestID)
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
