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
    var foodList: Dictionary<String, Any>
    var friendsList: Dictionary<String, Any>
    var allergiesList: Dictionary<String, Any>
    var drink: String
    var trick: String
    
    init(name: String, userID: String, username: String, pictureURL: String, drink: String, trick: String) {
        self.name = name
        self.userID = userID
        self.username = username
        self.imageURL = pictureURL
        
        self.image = UIImage()
        self.foodList = [:]
        self.friendsList = [:]
        self.allergiesList = [:]
        
        self.drink = drink
        self.trick = trick
    }
    
    convenience override init() {
        self.init(name: "", userID: "", username: "", pictureURL: "", drink: "", trick: "")
    }
}

