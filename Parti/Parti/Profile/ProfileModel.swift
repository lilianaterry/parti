//
//  ProfileModel.swift
//  Parti
//
//  Created by Liliana Terry on 3/16/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import Foundation
import Firebase
import UIKit

/* Class pulls all information to populate a party cell or page */
class ProfileModel: NSObject {
    //var profilePicture: UIImage
    var name: String
    var userID: String
    var pictureURL: String
    
    init(name: String, userID: String, pictureURL: String) {
        //self.profilePicture = UIImage()
        self.name = name
        self.userID = userID
        self.pictureURL = pictureURL
    }
    
    convenience override init() {
        self.init(name: "", userID: "", pictureURL: "")
    }
}

