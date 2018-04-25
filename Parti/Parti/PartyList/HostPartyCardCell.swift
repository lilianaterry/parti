//
//  PartyCardCell.swift
//  PartyUI
//
//  Created by Liliana Terry on 4/17/18.
//  Copyright © 2018 The Party App. All rights reserved.
//

import UIKit

class HostPartyCardCell: UITableViewCell {
    
    @IBOutlet weak var cardBackground: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var colors = UIExtensions()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCard()
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    func setupCard() {
        // main card view
        cardBackground.clipsToBounds = false
        cardBackground.layer.cornerRadius = 10
        cardBackground.layer.applyShadow(color: UIColor.black, alpha: 0.15, x: 3, y: 3, blur: 6, spread: 0)
        
        // labels
        nameLabel.textColor = colors.darkMint
        addressLabel.textColor = colors.darkGrey
        dateLabel.textColor = colors.darkGrey
        timeLabel.textColor = colors.darkGrey
    }
}


