//
//  ViewController.swift
//  FoodList
//
//  Created by Liliana Terry on 2/24/18.
//  Copyright © 2018 Liliana Terry. All rights reserved.
//

import UIKit
import FirebaseDatabase

<<<<<<< HEAD
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    // Firebase connection
    var ref: DatabaseReference!
    var databaseHandle:DatabaseHandle?
    
    // list of possible food/drink
    var list = [String]()
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return list.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = list[indexPath.row]
        print("table populated")
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        print ("Reached checkmark method ")
        // if there is a checkmark, remove it
        // if there is not a checkmark, add one
        if (cell?.accessoryType == UITableViewCellAccessoryType.checkmark) {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
        } else if (cell?.accessoryType == UITableViewCellAccessoryType.none) {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            print("FAILED TO EXECUTE CHECKMARK")
        }
        print ("indexPath: \(indexPath[1])")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        // set firebase reference
        ref = Database.database().reference()
        
        // when a child gets added, I want this to update
        // returns the UInt of the event
        
        databaseHandle = ref?.child("foodlist").observe(.childAdded, with: { (snapshot) in
            // code to execute when a child is added under foodlist
            
            // take the value from readList and convert it to a string
            let item = snapshot.value as? String
            
            // if there is actually a value returned, add it to our list
            if let actualItem = item  {
                self.list.append(actualItem)
                
                // update the list to reflect the new change
                self.tableView.reloadData()
            }
        })
=======
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController, GIDSignInUIDelegate {
    
    // MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // TODO(developer) Configure the sign-in button look/feel
        // ...
>>>>>>> auth
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
<<<<<<< HEAD
    
    
=======

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
            }
        }
    }
    
    func passwordSignIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print("ERROR: Failed Auth")
            } else {
                print("Password Success!")
                print(user!.uid)
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
>>>>>>> auth
}

