//
//  PartiTableViewCell.swift
//  Parti
//
//  Created by Arjun Gopisetty on 3/3/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit
import FirebaseStorage

class AttendingPartyTableViewCell: UITableViewCell {

    @IBOutlet weak var partyPicture: UIImageView!
    @IBOutlet weak var partyName: UILabel!
    @IBOutlet weak var address: UILabel!
    
    var partyObject = PartyModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // create circular mask on image
        self.partyPicture.layer.cornerRadius = self.partyPicture.frame.size.height / 2;
        self.partyPicture.clipsToBounds = true;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func foodDrinkOnClick(_ sender: Any) {
    }
    
}
