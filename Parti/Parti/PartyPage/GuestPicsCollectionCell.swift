//
//  ImageCollectionViewCell.swift
//  PartyUI
//
//  Created by Liliana Terry on 4/17/18.
//  Copyright © 2018 The Party App. All rights reserved.
//

import UIKit

class GuestPicsCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var guestButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        guestButton.layer.cornerRadius = guestButton.frame.size.width/2
        guestButton.clipsToBounds = true
    }

}
