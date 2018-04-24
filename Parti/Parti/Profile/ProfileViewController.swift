//
//  ViewController.swift
//  PartyUI
//
//  Created by Liliana Terry on 4/19/18.
//  Copyright © 2018 The Party App. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var imageBorder: UIView!
    @IBOutlet weak var borderWidth: NSLayoutConstraint!
    @IBOutlet weak var borderHeight: NSLayoutConstraint!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var picWidth: NSLayoutConstraint!
    @IBOutlet weak var picHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomDist: NSLayoutConstraint!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var infoBar: UIView!
    @IBOutlet weak var trickBox: UIView!
    @IBOutlet weak var drinkBox: UIView!
    @IBOutlet weak var trickTitle: UILabel!
    @IBOutlet weak var trickLabel: UILabel!
    @IBOutlet weak var drinkTitle: UILabel!
    @IBOutlet weak var drinkLabel: UILabel!
    
    @IBOutlet weak var allergyBar: UIView!
    @IBOutlet weak var nuts: UIButton!
    @IBOutlet weak var vegetarian: UIButton!
    @IBOutlet weak var gluten: UIButton!
    @IBOutlet weak var vegan: UIButton!
    @IBOutlet weak var dairy: UIButton!
    var allergyIcons = [UIButton]()
    
    
    @IBOutlet weak var bottomBar: UIView!
    
    let colors = UIExtensions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topHalf()
        trickAndDrink()
        allergies()
        bottom()
        
        // if on a 5s, make additional changes
        if (mainView.frame.height == 568) {
            smallScreenSizes()
        }
    }
    
    // Profile picture, name, username
    func topHalf() {
        imageBorder.backgroundColor = UIColor.white
        imageBorder.layer.applyShadow(color: UIColor.black, alpha: 0.15, x: 0, y: 3, blur: 6, spread: 0)
        imageBorder.layer.cornerRadius = imageBorder.frame.size.height / 2
        
        profilePicture.layer.cornerRadius = profilePicture.frame.size.height / 2
        profilePicture.clipsToBounds = true
        
        nameLabel.textColor = colors.nameColor
        usernameLabel.textColor = UIColor.white
    }
    
    // add center line and drop shadow to guest info bar
    func trickAndDrink() {
        mainView.sendSubview(toBack: allergyBar)
        trickBox.layer.addBorder(edge: .right, color: colors.backgroundLightGrey, thickness: 1)
        infoBar.layer.applyShadow(color: UIColor.black, alpha: 0.1, x: 0, y: 2, blur: 5, spread: 0)
        
        trickTitle.textColor = colors.darkMint
        trickTitle.layer.addBorder(edge: .bottom, color: colors.mainColor, thickness: 1)
        trickLabel.textColor = colors.darkGrey
        drinkTitle.textColor = colors.darkMint
        drinkTitle.layer.addBorder(edge: .bottom, color: colors.mainColor, thickness: 1)
        drinkLabel.textColor = colors.darkGrey
    }
    
    // set background color and allergy button colorings
    func allergies() {
        allergyIcons = [nuts, vegetarian, gluten, vegan, dairy]

        for icon in allergyIcons {
            icon.tintColor = colors.mediumGrey
        }
        nuts.tintColor = colors.darkMint
        gluten.tintColor = colors.darkMint
    }
    
    // add drop shadow to the top of the bottom bar to make allergy bar look recessed
    func bottom() {
        bottomBar.layer.applyShadow(color: UIColor.black, alpha: 0.1, x: 0, y: -2, blur: 5, spread: 0)
    }
    
    // if on a 5s, constraints start breaking
    func smallScreenSizes() {
        borderWidth.constant = 100
        borderHeight.constant = 100
        imageBorder.layer.cornerRadius = 50
        
        picWidth.constant = 90
        picHeight.constant = 90
        profilePicture.layer.cornerRadius = 45
        
        bottomDist.constant = 20
    }
}
