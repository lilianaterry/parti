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
    @IBOutlet weak var mainStack: UIStackView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    let application = UIApplication.shared
    
    var movedUp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if mainStack.frame.origin.y >= 0 {
                print("moving up")
                mainStack.frame.origin.y -= keyboardSize.height
                
                movedUp = true
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if (movedUp) {
                print("moving down")
                mainStack.frame.origin.y += keyboardSize.height
            }
        }
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
    
    @IBAction func onPasswordReset(_ sender: Any) {
        // Create the alert controller.
        let alert = UIAlertController(title: "Password Reset", message: "Enter your email", preferredStyle: .alert)
        
        // Add text field
        alert.addTextField { (textField) in
            textField.text = ""
        }
        
        // Grab the value from the text field, and reset the password when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            self.passwordReset(email: (textField?.text)!)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func passwordReset(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error != nil {
                print("ERROR: Password reset failed")
            } else {
                print("Password reset success!")
            }
        }

    }
    
    func passwordSignIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print("ERROR: Failed Auth")
            } else {
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
                }
            }
        })
    }
    
    func firebaseLogin(_ credential: AuthCredential) {
        if let user = Auth.auth().currentUser {
            // [START link_credential]
            user.link(with: credential) { (user, error) in
                // [START_EXCLUDE]
                if let error = error {
                    print("ERROR" + error.localizedDescription)
                    return
                }
                // [END_EXCLUDE]
            }
            // [END link_credential]
        } else {
            // [START signin_credential]
            Auth.auth().signIn(with: credential) { (user, error) in
                // [START_EXCLUDE silent]
                    // [END_EXCLUDE]
                    if let error = error {
                        // [START_EXCLUDE]
                        print(error.localizedDescription)
                        // [END_EXCLUDE]
                        return
                    }
                    // User is signed in
                    // [START_EXCLUDE]
                    // Merge prevUser and currentUser accounts and data
                    // ...
                    // [END_EXCLUDE]
                }
            }
        // [END signin_credential]
    }
    
    @IBAction func googleLogin(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }

}

