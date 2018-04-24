//
//  PartyFoodListViewController.swift
//  PartiMusic
//
//  Created by Liliana Terry on 4/12/18.
//  Copyright © 2018 The Party App. All rights reserved.
//

import MaterialComponents

class PartyFoodListViewController: UIViewController {
    
    let buttonBar = MDCButtonBar()
    
    let alcohol = UIBarButtonItem(
        title: "Alcohol",
        style: .done, // ignored
        target: self,
        action: #selector(alcoholPressed)
    )
    
    let food = UIBarButtonItem(
        title: "Food",
        style: .done, // ignored
        target: self,
        action: #selector(foodPressed)
    )
    
    let mixers = UIBarButtonItem(
        title: "Mixers",
        style: .done, // ignored
        target: self,
        action: #selector(mixersPressed)
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonBar.items = [alcohol, food, mixers]
        
        let size = buttonBar.sizeThatFits(self.view.bounds.size)
        buttonBar.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        self.view.addSubview(buttonBar)
    }

    
    @objc func alcoholPressed () {
        print("alcohol")
    }
    
    @objc func foodPressed () {
        print("food")
    }
    
    @objc func mixersPressed () {
        print("mixers")
    }
}
