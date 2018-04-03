//
//  AddGuestsTableViewCell.swift
//  Parti
//
//  Created by Arjun Gopisetty on 3/30/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class AddGuestsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var newUserButton: UIButton!
    
    var profileModel: ProfileModel!
    // Firebase Database connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        databaseRef = Database.database().reference()
        self.backgroundColor = UIColor.clear
        
        newUserButton.setTitle("-", for: .highlighted)
        newUserButton.setTitle("+", for: .highlighted)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    /* update friendship in Firebase */
    @IBAction func addFriend(_ sender: Any) {
        let friendUid = profileModel.userID
        let userID = Auth.auth().currentUser!.uid
        let friendDict = [friendUid: 1]
        let userDict = [userID: 1]
        
        self.databaseRef.child("users/\(friendUid)/friendsList").updateChildValues(userDict)
        self.databaseRef.child("users/\(userID)/friendsList").updateChildValues(friendDict)
    }
    
    @IBAction func upvote(_ sender: Any) {
        
    }
}
