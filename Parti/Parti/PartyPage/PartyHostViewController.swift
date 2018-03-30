//
//  PartyHostViewController.swift
//  Parti
//
//  Created by Arjun Gopisetty on 3/26/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit
import FirebaseDatabase


class PartyHostViewController: ViewController {
    
    @IBOutlet weak var nutButton: UIButton!
    @IBOutlet weak var glutenButton: UIButton!
    @IBOutlet weak var vegetarianButton: UIButton!
    @IBOutlet weak var milkButton: UIButton!
    @IBOutlet weak var veganButton: UIButton!
    
    @IBOutlet weak var nutsLabel: UILabel!
    @IBOutlet weak var glutenLabel: UILabel!
    @IBOutlet weak var vegetarianLabel: UILabel!
    @IBOutlet weak var milkLabel: UILabel!
    @IBOutlet weak var veganLabel: UILabel!
    
    
    // Firebase Database connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    var allergyList = ["Nuts", "Gluten", "Vegetarian", "Dairy", "Vegan"]
    var allergyCounts = [0, 0, 0, 0, 0]
    var allergyImages = [UIButton]()
    var allergyLabels = [UILabel]()
    let guests = [ProfileModel]()
    
    var partyObject = PartyModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseRef = Database.database().reference()
        allergyImages = [nutButton, glutenButton, vegetarianButton, milkButton, veganButton]
        allergyLabels = [nutsLabel, glutenLabel, vegetarianLabel, milkLabel, veganLabel]

        setupAllergyIcons()
        
        // Do any additional setup after loading the view.
        getGuests()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* Adds color selection functionality to allergy icons */
    func setupAllergyIcons() {
        nutButton.setImage(#imageLiteral(resourceName: "nuts-orange.png"), for: .selected)
        nutButton.setImage(#imageLiteral(resourceName: "nut-free"), for: .normal)
        nutButton.tag = 0
        glutenButton.setImage(#imageLiteral(resourceName: "gluten-yellow"), for: .selected)
        glutenButton.setImage(#imageLiteral(resourceName: "gluten-free"), for: .normal)
        glutenButton.tag = 1
        vegetarianButton.setImage(#imageLiteral(resourceName: "veggie-green"), for: .selected)
        vegetarianButton.setImage(#imageLiteral(resourceName: "vegetarian"), for: .normal)
        vegetarianButton.tag = 2
        milkButton.setImage(#imageLiteral(resourceName: "milk-blue"), for: .selected)
        milkButton.setImage(#imageLiteral(resourceName: "dairy"), for: .normal)
        milkButton.tag = 3
        veganButton.setImage(#imageLiteral(resourceName: "vegan-blue"), for: .selected)
        veganButton.setImage(#imageLiteral(resourceName: "vegan"), for: .normal)
        veganButton.tag = 4
    }
    
    /* iterates over all guests invited to the party to populate profile objects and get allergies */
    func getGuests() {
        databaseRef.child("parties/\(partyObject.partyID)/guests").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    let userID = snap.key
                    
                    self.queryGuestInfo(userID: userID)
                }
            }
        }
    }
    
    /* Get all of the allergy information, name, userID, etc  */
    func queryGuestInfo(userID: String) {
        databaseRef.child("users/\(userID)").observe(.value) { (snapshot) in
            // add all user information to the profile model object
            let newUser = ProfileModel()
            if (snapshot.exists()) {
                let data = snapshot.value as! [String: Any]
                print("got user info")
                print(data)
                
                // If the user already has a profile picture, load it up!
                if let imageURL = data["imageURL"] as? String {
                    let url = URL(string: imageURL)
                    URLSession.shared.dataTask(with: url!, completionHandler: { (image, response, error) in
                        if (error != nil) {
                            print(error)
                            return
                        }
                        print("about to save!!! fingers crossed!")
                        DispatchQueue.main.async { // Make sure you're on the main thread here
                            newUser.image = UIImage(data: image!)!
                        }
                    }).resume()
                }
                
                print("about to get allergies")
                if let allergies = data["allergyList"] {
                    print(allergies)
                    let userAllergies = allergies as! [String: Any]
                    
                    for allergy in userAllergies.keys {
                        let index = self.allergyList.index(of: allergy)
                        self.allergyImages[index!].isSelected = true
                        self.allergyCounts[index!] += 1
                        self.allergyLabels[index!].text = String(self.allergyCounts[index!])
                    }
                }
            } else {
                print("No user in Firebase yet")
            }
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
