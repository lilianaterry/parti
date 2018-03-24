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

class CreateFoodListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var nutsButton: UIButton!
    @IBOutlet weak var glutenButton: UIButton!
    @IBOutlet weak var vegetarianButton: UIButton!
    @IBOutlet weak var lactoseButton: UIButton!
    @IBOutlet weak var veganButton: UIButton!
    
    var userID = String()
    
    // Firebase connection
    var ref: DatabaseReference!
    var databaseHandle:DatabaseHandle?
    
    // list of possible food/drink
    var foodList = [String]()
    
    var allergiesList = [Int: Int]()
    
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
        print ("Reached checkmark method ")
        // if there is a checkmark, remove it
        // if there is not a checkmark, add one
        if (cell?.accessoryType == UITableViewCellAccessoryType.checkmark) {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            removeItem()
        } else if (cell?.accessoryType == UITableViewCellAccessoryType.none) {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            addItem()
        } else {
            print("FAILED TO EXECUTE CHECKMARK")
        }
    }
    
    func addItem() {
        
    }
    
    func removeItem() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // set firebase reference
        ref = Database.database().reference()
        
        populateFoodList()
        
        allergiesList = [:]
        
        nutsButton.setImage(#imageLiteral(resourceName: "nuts-orange.png"), for: .selected)
        nutsButton.setImage(#imageLiteral(resourceName: "nut-free"), for: .normal)
        nutsButton.tag = 1
        glutenButton.setImage(#imageLiteral(resourceName: "gluten-yellow"), for: .selected)
        glutenButton.setImage(#imageLiteral(resourceName: "gluten-free"), for: .normal)
        glutenButton.tag = 2
        vegetarianButton.setImage(#imageLiteral(resourceName: "veggie-green"), for: .selected)
        vegetarianButton.setImage(#imageLiteral(resourceName: "vegetarian"), for: .normal)
        vegetarianButton.tag = 3
        lactoseButton.setImage(#imageLiteral(resourceName: "milk-blue"), for: .selected)
        lactoseButton.setImage(#imageLiteral(resourceName: "dairy"), for: .normal)
        lactoseButton.tag = 4
        veganButton.setImage(#imageLiteral(resourceName: "vegan-blue"), for: .selected)
        veganButton.setImage(#imageLiteral(resourceName: "vegan"), for: .normal)
        veganButton.tag = 5
    }
    
    /* Retrieves all foodlist items from Firebase */
    func populateFoodList() {
        let foodRef = ref.child("foodlist");
        
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
    
    @IBAction func toggleImage(_ sender: Any) {
        if let button = sender as? UIButton {
            let tag = button.tag
            if button.isSelected {
                // set deselected
                button.isSelected = false
                allergiesList[tag] = 0
                
            } else {
                // set selected
                button.isSelected = true
                allergiesList[tag] = 1
            }
        }
    }
    
    
}
