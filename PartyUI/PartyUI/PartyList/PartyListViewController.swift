//
//  ViewController.swift
//  PartyUI
//
//  Created by Liliana Terry on 4/17/18.
//  Copyright © 2018 The Party App. All rights reserved.
//

import UIKit

struct partyCard {
    var name: String
    var address: String
    var time: Int
    var date: Int
    
    var userStatus: Int
}

class PartyListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var attendingSection: UIButton!
    @IBAction func attendingSection(_ sender: Any) {
        toggleSections(sender: attendingSection, other: hostingSection)
    }
    @IBOutlet weak var hostingSection: UIButton!
    @IBAction func hostingSection(_ sender: Any) {
        toggleSections(sender: hostingSection, other: attendingSection)
    }
    
    @IBOutlet weak var partyTableView: UITableView!
    
    var hosting = [partyCard]()
    var attending = [partyCard]()
    var displaying = [partyCard]()
    
    var colors = UIExtensions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        partyTableView.delegate = self
        partyTableView.dataSource = self
        
        headerAndBackground()
        
        // initially view only attending parties
        displaying = attending
    }
    
    // setup coloring on header and background of view
    func headerAndBackground() {
        mainView.backgroundColor = colors.mainColor
        headerView.backgroundColor = colors.mainColor
        partyTableView.backgroundView?.backgroundColor = colors.backgroundLightGrey
        
        attendingSection.setTitleColor(colors.darkMint, for: .normal)
        attendingSection.setTitleColor(UIColor.white, for: .selected)
        toggleSections(sender: attendingSection, other: hostingSection)
        
        hostingSection.setTitleColor(colors.darkMint, for: .normal)
        hostingSection.setTitleColor(UIColor.white, for: .selected)
    }
    
    // turn buttons on and off
    func toggleSections(sender: UIButton, other: UIButton) {
        // deselect
        if (sender.isSelected) {
            sender.isSelected = false
            removeUnderline(sender: sender)
        } else {
            sender.isSelected = true
            // add underline
            sender.addBottomBorderWithColor(color: UIColor.white, width: 2.0)
            
            other.isSelected = false
            removeUnderline(sender: other)
        }
        
    }
    
    // remove underline from this button
    func removeUnderline(sender: UIButton) {
        if sender.layer.sublayers != nil {
            for layer in sender.layer.sublayers! {
                if (layer.name == "underline") {
                    layer.removeFromSuperlayer()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = partyTableView.dequeueReusableCell(withIdentifier: "partyCardCell", for: indexPath) as! PartyCardCell
        
        return cell
    }
}
