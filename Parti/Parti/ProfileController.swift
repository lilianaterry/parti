//
//  ProfileController.swift
//  Parti
//
//  Created by Arjun Gopisetty on 2/14/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit

class ProfileController {
    
    let kSectionToken = 3
    let kSectionProviders = 2
    let kSectionUser = 1
    let kSectionSignIn = 0
    
    enum AuthProvider {
        case authEmail
        case authAnonymous
        case authFacebook
        case authGoogle
        case authTwitter
        case authPhone
        case authCustom
    }

}
