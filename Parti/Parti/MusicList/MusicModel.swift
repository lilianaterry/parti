//
//  MusicModel.swift
//  Parti
//
//  Created by Liliana Terry on 4/5/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import Foundation
import Firebase
import UIKit

/* Class pulls all information to populate a party cell or page */
class MusicModel: NSObject {
    var song: String
    var artist: String
    var image: UIImage
    
    init(song: String, artist: String) {
        self.song = song
        self.artist = artist
        
        self.image = UIImage()
    }
    
    convenience override init() {
        self.init(song: "", artist: "")
    }
}

