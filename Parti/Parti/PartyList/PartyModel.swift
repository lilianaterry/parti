//
//  PartyModel.swift
//  Parti
//
//  Created by Liliana Terry on 3/8/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import Foundation
import Firebase
import UIKit

/* Class pulls all information to populate a party cell or page */
class PartyModel: NSObject {
    var attire: String
    var foodList: NSDictionary
    var guests: NSDictionary
    var host: String
    var partyName: String
    var dateTime: String
    var address: String
    
    init(attire: String, host: String, partyName: String, dateTime: String, address: String) {
        self.attire = attire
        self.host = host
        self.partyName = partyName
        self.dateTime = dateTime
        self.foodList = [:]
        self.guests = [:]
        self.address = address
    }
    
    init?(snapshot: DataSnapshot) {
        guard var dictionary = snapshot.value as? [String: Any] else {return nil}
        guard let attire = dictionary["attire"] as? String else {return nil}
        guard let foodList = dictionary["foodlist"] as? NSDictionary else {return nil}
        guard let guests = dictionary["guests"] as? NSDictionary else {return nil}
        guard let host = dictionary["host"] as? String else {return nil}
        guard let partyName = dictionary["partyname"] as? String else {return nil}
        guard let dateTime = dictionary["datetime"] as? String else {return nil}
        guard let address = dictionary["address"] as? String else {return nil}
        
        self.attire = attire
        self.foodList = foodList
        self.guests = guests
        self.host = host
        self.partyName = partyName
        self.dateTime = dateTime
        self.address = address
    }
    
    convenience override init() {
        self.init(attire: "", host: "", partyName: "", dateTime: "", address: "")
    }
}

