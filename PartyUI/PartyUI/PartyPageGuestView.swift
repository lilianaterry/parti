//
//  ViewController.swift
//  PartyUI
//
//  Created by Liliana Terry on 4/16/18.
//  Copyright © 2018 The Party App. All rights reserved.
//

import UIKit

class PartyPageGuestView: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var attendingBarBackground: UIView!
    @IBOutlet weak var partyImage: UIImageView!
    @IBOutlet weak var partyTitleLabel: UILabel!
    @IBOutlet weak var attireLabel: UILabel!
    
    
    @IBOutlet weak var infoSectionBackground: UIView!
    @IBOutlet weak var placeTitle: UILabel!
    @IBOutlet weak var addressLine1: UILabel!
    @IBOutlet weak var addressLine2: UILabel!
    @IBOutlet weak var timeTitle: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var scrollView: UICollectionView!
    let portraits = [#imageLiteral(resourceName: "portrait1"), #imageLiteral(resourceName: "portrait2"), #imageLiteral(resourceName: "portrait3"), #imageLiteral(resourceName: "portrait4"), #imageLiteral(resourceName: "portrait5"), #imageLiteral(resourceName: "portrait6"), #imageLiteral(resourceName: "portrait6"), #imageLiteral(resourceName: "portrait6")]
    
    @IBOutlet weak var bottomView: UIView!
    
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
    
    /* MAIN METHOD */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        partyBanner()
        attendingBar()
        headerText()
        partyInfo()
        bottomBar()
        
        mainView.bringSubview(toFront: infoSectionBackground)
        mainView.bringSubview(toFront: attendingBarBackground)

        mainView.bringSubview(toFront: bottomView)
    }
    
    func partyBanner() {
        partyImage.image = #imageLiteral(resourceName: "placeholder_banner")
    }
    
    // add a shadow to the text on the image
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
    
    // add drop shadow to this bar and setup button ui
    func attendingBar() {
        mainView.bringSubview(toFront: attendingBarBackground)
        attendingBarBackground.layer.applyShadow(color: mediumGrey, alpha: 0.2, x: 0, y: 1, blur: 2, spread: 0)
        
        maybeButton.setTitleColor(UIColor.white, for: .selected)
        maybeButton.setTitleColor(darkGrey, for: .normal)
        maybeButton.isSelected = false
        
        goingButton.setTitleColor(UIColor.white, for: .selected)
        goingButton.setTitleColor(darkGrey, for: .normal)
        goingButton.isSelected = false
        
        notGoingButton.setTitleColor(UIColor.white, for: .selected)
        notGoingButton.setTitleColor(darkGrey, for: .normal)
        goingButton.isSelected = false

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
    
    // add drop shadow to this section and setup text colors
    func partyInfo() {
        infoSectionBackground.layer.applyShadow(color: UIColor.black, alpha: 0.1, x: 0, y: 2, blur: 5, spread: 0)
        
        placeTitle.textColor = darkMint
        timeTitle.textColor = darkMint
        
        addressLine1.textColor = darkGrey
        addressLine2.textColor = mediumGrey
        dateLabel.textColor = darkGrey
        timeLabel.textColor = mediumGrey
    }

    // handles the sliding collection view feature
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return portraits.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "guestPicture", for: indexPath) as! ImageCollectionViewCell
        
        cell.guestPicture.image = portraits[indexPath.row]
        
        return cell
    }
    
    func bottomBar() {
        bottomView.layer.applyShadow(color: UIColor.black, alpha: 0.1, x: 0, y: -2, blur: 5, spread: 0)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


