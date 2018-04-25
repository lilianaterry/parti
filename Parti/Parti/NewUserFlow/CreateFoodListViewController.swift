////
////  CreateFoodListViewController.swift
////  Parti
////
////  Created by Liliana Terry on 3/21/18.
////  Copyright © 2018 Arjun Gopisetty. All rights reserved.
////
//
import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class CreateFoodListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var nutsButton: UIButton!
    @IBOutlet weak var glutenButton: UIButton!
    @IBOutlet weak var vegetarianButton: UIButton!
    @IBOutlet weak var lactoseButton: UIButton!
    @IBOutlet weak var veganButton: UIButton!
    
    // Firebase connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    // Storage connection
    var storageRef: StorageReference!
    var storageHandle: StorageHandle?
    
    // list of possible food/drink
    var foodList = [String]()
    let allergyList = ["Nuts", "Gluten", "Vegetarian", "Dairy", "Vegan"]
    
    // our user's information
    var profileObject = ProfileModel()
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return foodList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath)
        cell.textLabel?.text = foodList[indexPath.row]
        return cell
    }
    
    // Add or remove checkmarks from food items
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        // if there is a checkmark, remove it
        // if there is not a checkmark, add one
        if (cell?.accessoryType == UITableViewCellAccessoryType.checkmark) {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            removeItem(index: indexPath.row)
        } else if (cell?.accessoryType == UITableViewCellAccessoryType.none) {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            addItem(index: indexPath.row)
        } else {
            print("FAILED TO EXECUTE CHECKMARK")
        }
    }
    
    // add item to user's food list so it can be uploaded to firebase later
    func addItem(index: Int) {
        let item = foodList[index]
        profileObject.foodList[item] = 1
    }
    
    // remove item from user's food list so it won't be uploaded to firebase
    func removeItem(index: Int) {
        let item = foodList[index]
        profileObject.foodList.removeValue(forKey: item)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // set firebase reference
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        // setup visuals for data
        populateFoodList()
        setupAllergyIcons()
    }
    
    /* Adds color selection functionality to allergy icons */
    func setupAllergyIcons() {
        nutsButton.setImage(#imageLiteral(resourceName: "nuts"), for: .selected)
        nutsButton.setImage(#imageLiteral(resourceName: "nuts"), for: .normal)
        nutsButton.tag = 0
        glutenButton.setImage(#imageLiteral(resourceName: "gluten"), for: .selected)
        glutenButton.setImage(#imageLiteral(resourceName: "gluten"), for: .normal)
        glutenButton.tag = 1
        vegetarianButton.setImage(#imageLiteral(resourceName: "vegetarian"), for: .selected)
        vegetarianButton.setImage(#imageLiteral(resourceName: "vegetarian"), for: .normal)
        vegetarianButton.tag = 2
        lactoseButton.setImage(#imageLiteral(resourceName: "dairy"), for: .selected)
        lactoseButton.setImage(#imageLiteral(resourceName: "dairy"), for: .normal)
        lactoseButton.tag = 3
        veganButton.setImage(#imageLiteral(resourceName: "vegan"), for: .selected)
        veganButton.setImage(#imageLiteral(resourceName: "vegan"), for: .normal)
        veganButton.tag = 4
    }
    
    /* Retrieves all foodlist items from Firebase */
    func populateFoodList() {
        let foodRef = databaseRef.child("foodlist");
        
        // get all foodlist items and populate table view
        foodRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let key = snap.key
                self.foodList.append(key)
            }
            
            self.tableView.reloadData()
        })
    }
    
    /* changes color of allergy icons to reflect selection/deselection */
    @IBAction func toggleImage(_ sender: Any) {
        if let button = sender as? UIButton {
            let tag = button.tag
            let allergy = allergyList[tag]
            if button.isSelected {
                // set deselected
                button.isSelected = false
                profileObject.allergiesList.removeValue(forKey: allergy)
            } else {
                // set selected
                button.isSelected = true
                profileObject.allergiesList[allergy] = 1
            }
        }
    }
    
    /* upload user's information to firebase, then add friend connections */
    @IBAction func uploadUser(_ sender: Any) {
        let values = ["name": profileObject.name,
                      "username": profileObject.username,
                      "foodList": profileObject.foodList,
                      "friendsList": profileObject.friendsList,
                      "allergiesList": profileObject.allergiesList] as [String : Any]
        databaseRef.child("users/\(profileObject.userID)").setValue(values)
        
        addUserToFriends()
        uploadProfilePicture()
    }
    
    /* Adds this user's ID to their friends' friend list so they are connected */
    func addUserToFriends() {
        let friends = profileObject.friendsList.keys
        
        // for each friend in the user's friend list, update their friendsLists
        for friendID in friends {
            let userItem = [profileObject.userID: 1]
            databaseRef.child("users/\(friendID)/friendsList").updateChildValues(userItem)
        }
    }
    
    /* Add user's profile picture to Storage and saves URL to Database */
    func uploadProfilePicture() {
        let imageRef = storageRef.child("profilePictures/\(self.profileObject.userID)")
        
        if let uploadData = UIImageJPEGRepresentation(profileObject.image, 0.1) {
            imageRef.putData(uploadData, metadata: nil, completion: {
                (metadata, error) in
                
                if (error != nil) {
                    print(error)
                    return
                }
                
                // update user's profile URL in Firebase Database
                let imageURL = metadata?.downloadURL()?.absoluteString
                self.databaseRef.child("users/\(self.profileObject.userID)/imageURL").setValue(imageURL)
            })
        }
    }
    
    /* if user does not finish their 3 step registration, remove their auth info */
    @IBAction func cancelRegistration(_ sender: Any) {
        let user = Auth.auth().currentUser
        user?.delete()
    }
    
}
