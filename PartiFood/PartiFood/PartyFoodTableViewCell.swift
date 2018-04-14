//
//  PartyFoodCell.swift
//  PartiFood
//
//  Created by Liliana Terry on 4/14/18.
//  Copyright © 2018 The Party App. All rights reserved.
//


import UIKit

class PartyFoodTableViewCell: UITableViewCell {
    
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var foodCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func customInit(name: String, count: Int) {
        self.foodLabel.text = name 
        self.foodCount.text = String(count)
    }
}
