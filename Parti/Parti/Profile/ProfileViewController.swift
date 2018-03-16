//
//  ProfileViewController.swift
//  Parti
//
//  Created by Liliana Terry on 3/16/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//


import UIKit
import FirebaseDatabase
import FirebaseStorage

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    var userID = "abMlbWBVzHVdD1vL1SVIQfLcVmT2"

    // Firebase connection
    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    var profileObject = ProfileModel()
 
    /* Runs when page is loaded, sets the delegate and datasource then calls method to query
     Firebase and fetch this user's information */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set firebase reference
        ref = Database.database().reference()
        
        // create circular mask on image
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.height / 2;
        self.profilePicture.clipsToBounds = true;
        
        // query Firebase to get the current user's information
        populateProfilePage()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* Creates an instance of the ProfileModel class and fills in all relevant information
     from Firebase query. Sets the global PartyObject to this filled-in object */
    func populateProfilePage() {
        databaseHandle = ref?.child("users/\(userID)").observe(.value, with: { (snapshot) in
            let profileID = snapshot.key
            let data = snapshot.value as! [String: Any]
            
            var profileObject = ProfileModel()
            //profileObject.profilePicture = data["profilePicture"] as! UIImage
            profileObject.name = data["name"] as! String
            print(profileObject.name)
            
            self.profileObject = profileObject
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
}
