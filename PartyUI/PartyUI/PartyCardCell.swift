//
//  PartyCardCell.swift
//  PartyUI
//
//  Created by Liliana Terry on 4/17/18.
//  Copyright © 2018 The Party App. All rights reserved.
//

import UIKit

class PartyCardCell: UITableViewCell {
    
    @IBOutlet weak var cardBackground: UIView!
    @IBOutlet weak var attendingBackground: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var goingButton: UIButton!
    @IBOutlet weak var notGoingButton: UIButton!
    @IBOutlet weak var maybeButton: UIButton!
    
    var colors = UIExtensions()
    
    @IBAction func goingButton(_ sender: Any) {
        // deselect
        if (goingButton.isSelected) {
            toggleButtonOff(button: goingButton)
            // select
        } else {
            toggleButtonOn(button: goingButton, off1: maybeButton, off2: notGoingButton)
        }
    }
    @IBAction func notGoingButton(_ sender: Any) {
        // deselect
        if (notGoingButton.isSelected) {
            toggleButtonOff(button: notGoingButton)
            // select
        } else {
            toggleButtonOn(button: notGoingButton, off1: maybeButton, off2: goingButton)
        }
    }
    @IBAction func maybeButton(_ sender: Any) {
        // deselect
        if (maybeButton.isSelected) {
            toggleButtonOff(button: maybeButton)
            // select
        } else {
            toggleButtonOn(button: maybeButton, off1: notGoingButton, off2: goingButton)
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupCard()
    }
    
    func setupCard() {
        // main background
        cardBackground.layer.cornerRadius = 10
        cardBackground.clipsToBounds = true
        cardBackground.layer.applyShadow(color: UIColor.black, alpha: 0.5, x: 3, y: 3, blur: 3, spread: 10)
        
        // attending status bar
        attendingBackground.layer.backgroundColor = colors.backgroundDarkGrey.cgColor
        goingButton.setTitleColor(colors.buttonText, for: .normal)
        goingButton.setTitleColor(UIColor.white, for: .selected)
        
        maybeButton.setTitleColor(colors.buttonText, for: .normal)
        maybeButton.setTitleColor(UIColor.white, for: .selected)
        
        notGoingButton.setTitleColor(colors.buttonText, for: .normal)
        notGoingButton.setTitleColor(UIColor.white, for: .selected)
        
        // labels
        nameLabel.textColor = colors.darkMint
        addressLabel.textColor = colors.darkGrey
        dateLabel.textColor = colors.darkGrey
        timeLabel.textColor = colors.darkGrey
    }
    
    // toggle any of the attending bar buttons on
    func toggleButtonOn(button: UIButton, off1: UIButton, off2: UIButton) {
        button.backgroundColor = colors.mainColor
        button.isSelected = true
        
        toggleButtonOff(button: off1)
        toggleButtonOff(button: off2)
    }
    
    // toggle any of the attending bar buttons off
    func toggleButtonOff(button: UIButton) {
        button.backgroundColor = UIColor.clear
        button.isSelected = false
    }
}

