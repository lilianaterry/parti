//
//  PartyFoodListViewController.swift
//  PartiMusic
//
//  Created by Liliana Terry on 4/12/18.
//  Copyright © 2018 The Party App. All rights reserved.
//

import MaterialComponents

struct cellData {
    var opened = Bool()
    var name = String()
    var count = Int()
    var userData = [String]()
}

class PartyFoodListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // switch to a different table view
    @IBAction func tabBar(_ sender: UISegmentedControl) {
        currentTab = sender.selectedSegmentIndex
        foodTableView.reloadData()
    }
    
    @IBOutlet weak var foodTableView: UITableView!
    
    var data = [[cellData]]()
    var currentTab: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        data = [
            [cellData.init(opened: false, name: "icecream", count: 2, userData: ["Liliana"]),
                 cellData.init(opened: false, name: "tacos", count: 4, userData: ["Carter", "Liliana"])],
            [cellData.init(opened: false, name: "vodka", count: 2, userData: ["Liliana"]),
             cellData.init(opened: false, name: "amaretto", count: 16, userData: ["Carter", "Liliana"])],
            [cellData.init(opened: false, name: "sprite", count: 1, userData: ["Liliana"]),
             cellData.init(opened: false, name: "cocacola", count: 7, userData: ["Carter", "Liliana"])]
        ]
        
        currentTab = 0
    }
    
    // number of food items in this tab
    func numberOfSections(in tableView: UITableView) -> Int {
        return data[currentTab].count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // the number of rows is none if the section is not opened
        // the number of rows increases if the section is opened
        if (data[currentTab][section].opened) {
            return data[currentTab][section].userData.count + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // get the item info and populate the cell with it
        let item = data[currentTab][indexPath.section] as cellData
        
        // food item cell
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "partyFoodCell") as! PartyFoodTableViewCell
        
            let name = item.name
            let count = item.count
            
            cell.customInit(name: name, count: count)
            
            return cell
        // name of guest bringing food item
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "guestFoodCell") as! GuestFoodTableViewCell
            
            print("current item: \(item.name)")
            print("trying to access indexPath: \(indexPath.row)")
            let name = item.userData[indexPath.row - 1]
            
            cell.customInit(name: name)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // if it is already opened, close it
        if (data[currentTab][indexPath.section].opened) {
            data[currentTab][indexPath.section].opened = false
            let sections = IndexSet.init(integer: indexPath.section)
            tableView.reloadSections(sections, with: .none)
        // otherwise open it
        } else {
            data[currentTab][indexPath.section].opened = true
            let sections = IndexSet.init(integer: indexPath.section)
            tableView.reloadSections(sections, with: .none)
        }
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
