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

class ViewController: UIViewController, GIDSignInUIDelegate {
    
    // MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var googleSignInButton: GIDSignInButton!

    var userID = String()
    
    // Firebase connection
    var ref: DatabaseReference!
    var databaseHandle:DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // set firebase reference
        ref = Database.database().reference()

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
            print("ERROR: email or password is blank")
        }
    }
    
    func createAccount(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print("ERROR: Failed to create account")
            } else {
                print("Create account succcess!")
                print(user!.uid)
                self.userID = user!.uid
            }
        }
    }
    
    // Tests to see if /users/<userId> has any data.
    func checkIfUserExists(userID: String) {
        ref.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            // if the user does not exist in the database, add them!
            if (value == nil) {
                print("User does not exist")
                self.ref.child("users").child(userID).setValue(["uid": userID])
            }

        }) { (error) in
            print(error.localizedDescription)
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
                
                // Now push this user's object to the database unless it's already there
                self.checkIfUserExists(userID: self.userID)
                
                self.performSegue(withIdentifier: "foodListSegue", sender: self)
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
        let secondController = segue.destination as! FoodListViewController
        secondController.userID = userID
        print("User id sent: \(self.userID)")

    }
}

