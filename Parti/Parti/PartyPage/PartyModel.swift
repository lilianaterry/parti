//
//  PartyModel.swift
//  Parti
//
//  Created by Liliana Terry on 3/8/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import Foundation
import UIKit

/* Class pulls all information to populate a party cell or page */
class PartyModel: NSObject {
    var address: String
    var attire: String
    var name: String
    var date: String
    var hostID: String
    var guestList: Dictionary<String, Any>
    var foodList: Dictionary<String, Any>
    var partyID: String
    var imageURL: String
    
    var guests: [ProfileModel]
    var image: UIImage
    
    init(hostID: String, imageURL: String, partyID: String, attire: String, name: String, date: String, address: String) {
        self.imageURL = imageURL
        self.partyID = partyID
        self.attire = attire
        self.hostID = hostID
        self.name = name
        self.date = date
        self.foodList = [:]
        self.guestList = [:]
        self.address = address
        self.guests = []
        self.image = UIImage()
    }
    
    
    
    convenience override init() {
        self.init(hostID: "", imageURL: "", partyID: "", attire: "", name: "", date: "", address: "")
    }
}

