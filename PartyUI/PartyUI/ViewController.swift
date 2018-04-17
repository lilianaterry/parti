//
//  ViewController.swift
//  PartyUI
//
//  Created by Liliana Terry on 4/16/18.
//  Copyright © 2018 The Party App. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var attendingBarBackground: UIView!
    @IBOutlet weak var partyImage: UIImageView!
    @IBOutlet weak var partyTitleLabel: UILabel!
    @IBOutlet weak var attireLabel: UILabel!
    
    // color pallete definitions
    let mainColor = UIColor.init(hex: 0x55efc4)
    let darkMint = UIColor.init(hex: 0x00b894)
    let darkGrey = UIColor.init(hex: 0x2d3436)
    let mediumGrey = UIColor.init(hex: 0xb2bec3)
    let lightGrey = UIColor.init(hex: 0xdfe6e9)
    
    @IBOutlet weak var goingButton: UIButton!
    @IBAction func goingButton(_ sender: Any) {
        // deselect
        if (goingButton.isSelected) {
            toggleButtonOff(button: goingButton)
            print("going button on")
        // select
        } else {
            toggleButtonOn(button: goingButton, off1: maybeButton, off2: notGoingButton)
        }
    }
    
    @IBOutlet weak var notGoingButton: UIButton!
    @IBAction func notGoingButton(_ sender: Any) {
        // deselect
        if (notGoingButton.isSelected) {
            toggleButtonOff(button: notGoingButton)
        // select
        } else {
            toggleButtonOn(button: notGoingButton, off1: goingButton, off2: maybeButton)
        }
    }
    @IBOutlet weak var maybeButton: UIButton!
    
    @IBAction func maybeButton(_ sender: Any) {
        // deselect
        if (maybeButton.isSelected) {
            toggleButtonOff(button: maybeButton)
        // select
        } else {
            toggleButtonOn(button: maybeButton, off1: goingButton, off2: notGoingButton)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        partyBanner()
        attendingBar()
        headerText()
    }
    
    func partyBanner() {
        partyImage.image = #imageLiteral(resourceName: "placeholder_banner")
    }
    
    func attendingBar() {
        attendingBarBackground.layer.shadowColor = UIColor.black.cgColor
        attendingBarBackground.layer.shadowOffset = CGSize(width: 2, height: 2)
        attendingBarBackground.layer.shadowRadius = 2
        attendingBarBackground.layer.shadowOpacity = 0.2
        
        maybeButton.setTitleColor(UIColor.white, for: .selected)
        maybeButton.setTitleColor(mainColor, for: .normal)
        maybeButton.isSelected = false
        
        goingButton.setTitleColor(UIColor.white, for: .selected)
        goingButton.setTitleColor(mainColor, for: .normal)
        goingButton.isSelected = false
        
        notGoingButton.setTitleColor(UIColor.white, for: .selected)
        notGoingButton.setTitleColor(mainColor, for: .normal)
        goingButton.isSelected = false

    }
    
    func headerText() {
        partyTitleLabel.layer.shadowColor = UIColor.black.cgColor
        partyTitleLabel.layer.shadowRadius = 3.0
        partyTitleLabel.layer.shadowOpacity = 0.33
        partyTitleLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        partyTitleLabel.layer.masksToBounds = false
        
        attireLabel.layer.shadowColor = UIColor.black.cgColor
        attireLabel.layer.shadowRadius = 3.0
        attireLabel.layer.shadowOpacity = 0.33
        attireLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        attireLabel.layer.masksToBounds = false
    }
    
    // toggle any of the attending bar buttons on
    func toggleButtonOn(button: UIButton, off1: UIButton, off2: UIButton) {
        button.backgroundColor = mainColor
        button.isSelected = true
        
        toggleButtonOff(button: off1)
        toggleButtonOff(button: off2)
    }
    
    // toggle any of the attending bar buttons off
    func toggleButtonOff(button: UIButton) {
        button.backgroundColor = UIColor.white
        button.isSelected = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension UIColor {
    
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
    
}

