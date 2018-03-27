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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createAccount(_ sender: Any) {
        if (!emailText.hasText) { emailErrorLabel.text = "Please enter an email"}
        else if (!passwordText.hasText) { passwordErrorLabel.text = "Please enter an password" }
        else if (!verifyPasswordText.hasText || (verifyPasswordText.text! != passwordText.text!)) {
            passwordErrorLabel.text = "Passwords do not match"
        } else {
            let email = emailText.text!
            let password = passwordText.text!
            
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if error != nil {
                    self.passwordErrorLabel.text =  error!.localizedDescription
                } else {
                    print("Create account succcess!")
                    print(user!.uid)
                    self.userID = user!.uid
                    
                    self.performSegue(withIdentifier: "createStepOne", sender: self)
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
