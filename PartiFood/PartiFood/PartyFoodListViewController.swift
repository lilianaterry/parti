//
//  PartyFoodListViewController.swift
//  PartiMusic
//
//  Created by Liliana Terry on 4/12/18.
//  Copyright © 2018 The Party App. All rights reserved.
//

import MaterialComponents

class PartyFoodListViewController: UIViewController {
    @IBAction func tabBar(_ sender: UISegmentedControl) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // adds food, alcohol, and mixer tab bar to top of view
    func setupTabBar() {
        let tabBar = MDCTabBar(frame: view.bounds)
        
        tabBar.items = [
            UITabBarItem(title: "Alcohol", image: nil, tag: 0),
            UITabBarItem(title: "Food", image: nil, tag: 0),
            UITabBarItem(title: "Mixers", image: nil, tag: 0),
        ]
        
        tabBar.itemAppearance = .titledImages
        tabBar.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        tabBar.sizeToFit()
        tabBar.alignment = .center
        tabBar.backgroundColor = UIColor(hex: "55efc4")
        tabBar.tintColor = UIColor.white
        view.addSubview(tabBar)
    }
    

}

// allows you to get a color object from a hex number
extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}
