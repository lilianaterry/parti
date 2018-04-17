//
//  FriendsTableViewCell.swift
//  Parti
//
//  Created by Arjun Gopisetty on 4/8/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import SwipeCellKit

class FriendsTableViewCell: SwipeTableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    
    var profileModel = ProfileModel()
    
    // Firebase Database connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        databaseRef = Database.database().reference()
        self.backgroundColor = UIColor.clear
        
        // create circular mask on image
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2
        self.profilePicture.clipsToBounds = true
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}
