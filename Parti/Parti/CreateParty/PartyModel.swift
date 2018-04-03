//
//  PartyModel.swift
//  Parti
//
//  Created by Liliana Terry on 3/18/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import Firebase
import UIKit

/* Class pulls all information to populate a party cell or page */
class CreatePartyModel: NSObject {
    //var profilePicture: UIImage
    var name: String
    var partyID: String
    var imageURL: String
    var attire: String
    var address: String
    var dateTime: String
    var guestList: NSDictionary
    var foodList: NSDictionary
    var hostID = String
    
    init(name: String, partyID: String, imageURL: String, attire: String, address: String, dateTime: String, hostID: String) {
        //self.profilePicture = UIImage()
        self.name = name
        self.partyID = partyID
        self.imageURL = imageURL
        self.attire = attire
        self.address = address
        self.dateTime = dateTime
        self.hostID = hostID
        
        self.guestList = [:]
        self.foodList = [:]
    }
    
    convenience override init() {
        self.init(name: "", partyID: "", imageURL: "", attire: "", address: "", dateTime: "", hostID: "")
    }
}
