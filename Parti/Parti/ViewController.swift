//
//  ViewController.swift
//  Parti
//
//  Created by Arjun Gopisetty on 1/30/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit

import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import StoreKit
import MediaPlayer

@IBDesignable extension UIButton {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

class ViewController: UIViewController, GIDSignInUIDelegate {
    
    // MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var googleSignInButton: GIDSignInButton!

    var userID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // TODO(developer) Configure the sign-in button look/feel
        // ...
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Actions
    @IBAction func emailLogin(_ sender: Any) {
        if (emailTextField.hasText && passwordTextField.hasText) {
            let email = emailTextField.text!;
            let password = passwordTextField.text!;
        
            passwordSignIn(email: email, password: password)
        } else {
            print("ERROR: email or password is incorrect")
        }
    }
    
    @IBAction func createAccount(_ sender: Any) {
        if (emailTextField.hasText && passwordTextField.hasText) {
            let email = emailTextField.text!
            let password = passwordTextField.text!
            
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if error != nil {
                    print(error?.localizedDescription as! String)
                } else {
                    print("Create account succcess!")
                    print(user!.uid)
                    self.userID = user!.uid
                    
                    self.performSegue(withIdentifier: "createStepOne", sender: self)
                }
            }
        } else {
            print("ERROR: email or password is blank")
        }
    }
    
    func passwordSignIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print("ERROR: Failed Auth")
            } else {
                print("Password Success!")
                print(user!.uid)
                self.userID = user!.uid
                print("User id set: \(self.userID)")
                
                self.performSegue(withIdentifier: "profileSegue", sender: self)
            }
        }
    }
    
    @IBAction func facebookLogin(_ sender: Any) {
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: ["email"], from: self, handler: { (result, error) in
            if let error = error {
                print("ERROR" + error.localizedDescription)
            } else if result!.isCancelled {
                print("ERROR" + "FBLogin cancelled")
            } else {
                // [START headless_facebook_auth]
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                // [END headless_facebook_auth]
                Auth.auth().signIn(with: credential) { (user, error) in
                    // [START_EXCLUDE silent]
                    // [END_EXCLUDE]
                    if let error = error {
                        // [START_EXCLUDE]
                        print("ERROR" + error.localizedDescription)
                        // [END_EXCLUDE]
                        return
                    }
                    // User is signed in
                    print("Facebook login success!");
                    print(user!.uid)
                    self.userID = user!.uid
                }
            }
        })
    }
    
//    func firebaseLogin(_ credential: AuthCredential) {
//        if let user = Auth.auth().currentUser {
//            // [START link_credential]
//            user.link(with: credential) { (user, error) in
//                // [START_EXCLUDE]
//                if let error = error {
//                    print("ERROR" + error.localizedDescription)
//                    return
//                }
//                // [END_EXCLUDE]
//            }
//            // [END link_credential]
//        } else {
//            // [START signin_credential]
//            Auth.auth().signIn(with: credential) { (user, error) in
//                // [START_EXCLUDE silent]
//                    // [END_EXCLUDE]
//                    if let error = error {
//                        // [START_EXCLUDE]
//                        print(error.localizedDescription)
//                        // [END_EXCLUDE]
//                        return
//                    }
//                    // User is signed in
//                    // [START_EXCLUDE]
//                    // Merge prevUser and currentUser accounts and data
//                    // ...
//                    // [END_EXCLUDE]
//                }
//            }
//        // [END signin_credential]
//    }
    
    @IBAction func googleLogin(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    // Pass login information to next page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueID = segue.identifier
        print("REACHED SEGUE")
        
        // Create Profile Step 1
        if (segueID == "createStepOne") {
            if let destinationVC = segue.destination as? ProfileCreationViewController {
                destinationVC.profileObject.userID = userID
            }
        // Party List Page
        } else if (segueID == "loginToPartyList") {
            if let destinationVC = segue.destination as? PartyListViewController {
                destinationVC.userID = userID
            }
            
        // FoodList page
//        } else if (segueID == "foodListSegue") {
//            if let destinationVC = segue.destination as? FoodListViewController {
//                destinationVC.userID = userID
//            }
//        // Party Creation Page
//        } else if (segueID == "createPartySegue") {
//            if let destinationVC = segue.destination as? CreatePartyViewController {
//                destinationVC.partyObject.hostID = userID
//            }
//        // Guest List Page
//        } else if (segueID == "guestListSegue") {
//            if let destinationVC = segue.destination as? GuestListViewController {
//                destinationVC.partyObject.hostID = userID
//            }
        }
    }
}

