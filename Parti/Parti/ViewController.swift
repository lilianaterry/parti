//
//  ViewController.swift
//  Parti
//
//  Created by Arjun Gopisetty on 1/30/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit

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
    @IBAction func facebookLogin(_ sender: Any) {
    }
    
    @IBAction func googleLogin(_ sender: Any) {
    }
    

}

