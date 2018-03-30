//
//  GuestButton.swift
//  Parti
//
//  Created by Liliana Terry on 3/29/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit

class GuestButton: UIButton {
    
    var userID: String
    
    required init(userID: String) {
        // set myValue before super.init is called
        self.userID = userID
        
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
