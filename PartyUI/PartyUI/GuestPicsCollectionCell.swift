//
//  ImageCollectionViewCell.swift
//  PartyUI
//
//  Created by Liliana Terry on 4/17/18.
//  Copyright © 2018 The Party App. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var guestPicture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        guestPicture.layer.cornerRadius = guestPicture.frame.size.width/2
        guestPicture.clipsToBounds = true
    }

}
