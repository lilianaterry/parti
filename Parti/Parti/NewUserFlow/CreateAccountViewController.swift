//
//  CreateAccountViewController.swift
//  Parti
//
//  Created by Arjun Gopisetty on 3/27/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit
import FirebaseAuth

class CreateAccountViewController: ViewController {
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var verifyPasswordText: UITextField!
    
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createAccount(_ sender: Any) {
        emailErrorLabel.text = ""
        passwordErrorLabel.text = ""
        if (!emailText.hasText || emailText.text!.range(of: "@") == nil) {
            emailErrorLabel.text = "Please enter a valid email"
        } else if (!passwordText.hasText) {
            passwordErrorLabel.text = "Please enter an password"
        } else if (!verifyPasswordText.hasText || (verifyPasswordText.text! != passwordText.text!)) {
            passwordErrorLabel.text = "Passwords do not match"
        } else {
            let email = emailText.text!
            let password = passwordText.text!
            
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if error != nil {
                    self.passwordErrorLabel.text =  error!.localizedDescription
                } else {
                    self.performSegue(withIdentifier: "createStepOne", sender: self)
                }
            }
        }
    }

}
