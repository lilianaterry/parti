//
//  GuestTableViewCell.swift
//  Parti
//
//  Created by Liliana Terry on 3/18/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit

class GuestTableViewCell: UITableViewCell {
    
    @IBOutlet weak var guestImage: UIImageView!
    @IBOutlet weak var guestName: UILabel!
    
    var userID: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // create circular mask on image
        self.guestImage.layer.cornerRadius = self.guestImage.frame.size.width / 2;
        self.guestImage.clipsToBounds = true;
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
