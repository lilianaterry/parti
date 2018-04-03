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

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var partyName: UILabel!
    @IBOutlet weak var address: UILabel!
    
    var partyObject = PartyModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // create circular mask on image
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.height / 2;
        self.profilePicture.clipsToBounds = true;
        
        getPicture()
    }
    
    func getPicture() {
        if (profilePicture.image == nil) {
            // If the user already has a profile picture, load it up!
            if (partyObject.imageURL != nil) {
                let url = URL(string: partyObject.imageURL)
                URLSession.shared.dataTask(with: url!, completionHandler: { (image, response, error) in
                    if (error != nil) {
                        print(error)
                        return
                    }
                    DispatchQueue.main.async { // Make sure you're on the main thread here
                        if let image = UIImage(data: image!) {
                            self.profilePicture.image = image
                        }
                    }
                }).resume()
                // otherwise use this temporary image
            } else {
                self.profilePicture?.image = #imageLiteral(resourceName: "parti_logo")
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func foodDrinkOnClick(_ sender: Any) {
    }
    
}
