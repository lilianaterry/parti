//
//  GuestListTableViewCell.swift
//  Parti
//
//  Created by Liliana Terry on 3/18/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit

class GuestListViewController: UITableViewCell {
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // create circular mask on image
        //self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
        //self.profilePicture.clipsToBounds = true;
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}

