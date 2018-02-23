//
//  ViewController.swift
//  Parti
//
//  Created by Arjun Gopisetty on 1/30/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
    }
    
    @IBAction func googleLogin(_ sender: Any) {
    }
}

