//
//  HostingPartyTableViewCell.swift
//  Parti
//
//  Created by Arjun Gopisetty on 3/26/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit

class HostingPartyTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var partyName: UILabel!
    @IBOutlet weak var address: UILabel!
    
    var partyObject = PartyModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // create circular mask on image
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.height / 2;
        self.profilePicture.clipsToBounds = true;
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
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
