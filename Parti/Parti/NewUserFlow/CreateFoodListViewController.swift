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
    var alcohol = [String: Any]()
    var food = [String: [String: Any]]()
    var mixers = [String: Any]()
    var displaying: Any!
    var numSections = 5
    var sectionNum = 1
    
    let allergyList = ["Nuts", "Gluten", "Vegetarian", "Dairy", "Vegan"]
    
    // our user's information
    var profileObject = ProfileModel()
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (numSections == 1) {
            let list = displaying as! [String: Any]
            return list.keys.count
        } else {
            var count = 0
            for category in food {
                let list = category.value
                count += list.keys.count
            }
            
            return count
        }
    }
    
    // number of food items in this tab
    func numberOfSections(in tableView: UITableView) -> Int {
        if (sectionNum == 0 || sectionNum == 2) {
            return 1
        } else {
            return food.keys.count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodCell", for: indexPath)
        
        if (indexPath.row == 0) {
            return UITableViewCell()
        } else {
            print(food)
            let sections = food.keys.count
            print(sections)
            print(indexPath.row)
            let currentSection = indexPath.row / sections
            print(currentSection)
            let indexInSection = indexPath.row % sections
            let sectionHeader = Array(food.keys)[currentSection]
            print(sectionHeader)
            print(indexInSection)
            cell.textLabel?.text = Array(food[sectionHeader]!.keys)[indexInSection]
        }
        
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
//        let item = foodList[index]
//        profileObject.foodList[item] = 1
    }
    
    // remove item from user's food list so it won't be uploaded to firebase
    func removeItem(index: Int) {
//        let item = foodList[index]
//        profileObject.foodList.removeValue(forKey: item)
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
        nutsButton.setImage(#imageLiteral(resourceName: "nuts-orange.png"), for: .selected)
        nutsButton.setImage(#imageLiteral(resourceName: "nut-free"), for: .normal)
        nutsButton.tag = 0
        glutenButton.setImage(#imageLiteral(resourceName: "gluten-yellow"), for: .selected)
        glutenButton.setImage(#imageLiteral(resourceName: "gluten-free"), for: .normal)
        glutenButton.tag = 1
        vegetarianButton.setImage(#imageLiteral(resourceName: "veggie-green"), for: .selected)
        vegetarianButton.setImage(#imageLiteral(resourceName: "vegetarian"), for: .normal)
        vegetarianButton.tag = 2
        lactoseButton.setImage(#imageLiteral(resourceName: "milk-blue"), for: .selected)
        lactoseButton.setImage(#imageLiteral(resourceName: "dairy"), for: .normal)
        lactoseButton.tag = 3
        veganButton.setImage(#imageLiteral(resourceName: "vegan-blue"), for: .selected)
        veganButton.setImage(#imageLiteral(resourceName: "vegan"), for: .normal)
        veganButton.tag = 4
    }
    
    /* Retrieves all foodlist items from Firebase */
    func populateFoodList() {
        let foodRef = databaseRef.child("foodList");
        
        // get all foodlist items and populate table view
        foodRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.value as! [String: Any]
            
            print(data)
            
            self.alcohol = data["Alcohol"] as! [String: Any]
            self.mixers = data["Mixers"] as! [String: Any]
            self.food = data["Food"] as! [String: [String: Any]]
            
            self.displaying = self.food
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
