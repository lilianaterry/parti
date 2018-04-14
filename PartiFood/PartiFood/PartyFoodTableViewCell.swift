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
    @IBOutlet weak var addButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addButton.setImage(#imageLiteral(resourceName: "add_button").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
        addButton.setImage(#imageLiteral(resourceName: "remove_button").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .selected)
        addButton.tintColor = UIColor(hex: "55efc4")
    }
    
    func customInit(name: String, count: Int, index: Int) {
        self.foodLabel.text = name 
        self.foodCount.text = String(count)
        self.addButton.tag = index
    }
}
