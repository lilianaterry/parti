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
    var name: String
    var userID: String
    var username: String
    var imageURL: String
    var image: UIImage
    var foodList: NSDictionary
    var friendsList: NSDictionary
    
    init(name: String, userID: String, username: String, pictureURL: String) {
        self.name = name
        self.userID = userID
        self.username = username
        self.imageURL = pictureURL
        
        self.image = UIImage()
        self.foodList = [:]
        self.friendsList = [:]
    }
    
    convenience override init() {
        self.init(name: "", userID: "", username: "", pictureURL: "")
    }
}

