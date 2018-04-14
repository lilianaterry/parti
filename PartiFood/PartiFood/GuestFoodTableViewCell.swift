//
//  GuestFoodTableViewCell.swift
//  PartiFood
//
//  Created by Liliana Terry on 4/14/18.
//  Copyright © 2018 The Party App. All rights reserved.
//

import UIKit

class GuestFoodTableViewCell: UITableViewCell {
    
    @IBOutlet weak var guestName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func customInit(name: String) {
        self.guestName.text = name
    }
}
