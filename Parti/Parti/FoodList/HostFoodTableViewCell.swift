//
//  HostFoodTableViewCell.swift
//  Parti
//
//  Created by Arjun Gopisetty on 4/6/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit

class HostFoodTableViewCell: UITableViewCell {

    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var foodLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
