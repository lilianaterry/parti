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
import FirebaseStorage

class CreateFriendListViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate, UITableViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // Firebase Database connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    // Firebase Storage connection
    var storageRef: StorageReference!
    var storageHandle: StorageHandle?
    
    var users = [ProfileModel]()
    var filteredUsers = [ProfileModel]()
    
    var profileObject = ProfileModel()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    // Add or remove checkmarks from friends
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! AddFriendTableViewCell

        let user = cell.profileModel

        // if there is a checkmark, remove it
        // if there is not a checkmark, add one
        if (cell.accessoryType == UITableViewCellAccessoryType.checkmark) {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            let friendID = user.userID
            profileObject.friendsList.removeValue(forKey: friendID)
        } else if (cell.accessoryType == UITableViewCellAccessoryType.none) {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            let friendID = user.userID
            profileObject.friendsList[friendID] = 1
        } else {
            print("FAILED TO EXECUTE CHECKMARK")
        }
    }
    
    // fill in all of the cells with name and picture
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var profileModel: ProfileModel = ProfileModel()

        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! AddFriendTableViewCell
        
        profileModel = users[indexPath.row]
        
        cell.profilePicture.image = profileModel.image
        cell.nameLabel?.text = users[indexPath.row].name
        cell.profileModel = profileModel
        cell.profileModel.userID = profileModel.userID
        cell.testing = true
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.dataSource = self
        self.tableView.delegate = self
        searchBar.delegate = self
        // set firebase reference
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        // TODO: Fetch friends from Firebase
        populateAllFriendsList()
        
        filteredUsers = users
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // get all users
    func populateAllFriendsList() {
        databaseHandle = databaseRef?.child("users").queryOrdered(byChild: "name").observe(.childAdded) { snapshot in
            var data = snapshot.value as! [String: Any]
            var user = ProfileModel()
            user.name = data["name"] as! String
            user.userID = snapshot.key
            
            self.getPicture(userID: user.userID, user: user)
        }
    }
    
    // get the user's profile picture
    func getPicture(userID: String, user: ProfileModel) {
        // get the profile picture for this user
        databaseHandle = databaseRef?.child("users/\(userID)/imageURL").observe(.value, with: { (snapshot) in
            if (snapshot.exists()) {
                
                // If the user already has a profile picture, load it up!
                if let imageURL = snapshot.value as? String {
                    self.profileObject.imageURL = imageURL
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
        })
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
        performSegue(withIdentifier: "cancel", sender: self)
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
