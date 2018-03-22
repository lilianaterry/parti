//
//  AddFriendTableViewCell.swift
//  Parti
//
//  Created by Arjun Gopisetty on 3/21/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class AddFriendTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    
    var profileModel: ProfileModel!
    // Firebase Database connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        databaseRef = Database.database().reference()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func addFriend(_ sender: Any) {
        let friendUid = profileModel.userID
        let userID = Auth.auth().currentUser!.uid
        let friendDict = [friendUid: 1]
        let userDict = [userID: 1]
        
        self.databaseRef.child("users/\(friendUid)/friends").updateChildValues(userDict)
        self.databaseRef.child("users/\(userID)/friends").updateChildValues(friendDict)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
