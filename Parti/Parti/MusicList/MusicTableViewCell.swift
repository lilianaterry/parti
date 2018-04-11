//
//  MusicTableViewCell.swift
//  Parti
//
//  Created by Liliana Terry on 4/4/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit

class MusicTableViewCell: UITableViewCell {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var count: UILabel!
    
    @IBAction func upVote(_ sender: Any) {
        
    }
    
    @IBAction func downVote(_ sender: Any) {
        
    }
    
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

