//
//  ImageCollectionViewCell.swift
//  PartyUI
//
//  Created by Liliana Terry on 4/17/18.
//  Copyright © 2018 The Party App. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var guestButton: UIButton!
    @IBAction func goToProfile(_ sender: Any) {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        guestButton.layer.cornerRadius = guestButton.frame.size.width/2
        guestButton.clipsToBounds = true
    }

}
