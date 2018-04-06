//
//  HostFoodViewController.swift
//  Parti
//
//  Created by Arjun Gopisetty on 4/6/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit
import FirebaseDatabase

class HostFoodViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var foodTableView: UITableView!
    @IBOutlet weak var tableViewCell: UITableViewCell!
    
    var foodList = [String: Int]()
    var guestList = [String]()
    
    var partyObject: PartyModel = PartyModel()
    
    // Firebase connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return foodList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "partyFoodCell", for: indexPath) as! HostFoodTableViewCell
        
        cell.countLabel.text = ""
        cell.foodLabel.text = ""
        
        
        return cell
        // Query for all users in party
        // function for uid, query for that uid foodList
    }
    
    //
    func queryForUsers() {
        databaseRef?.child("parties/\(partyObject.partyID)/guests").observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                var guestID = snap.key
                
                self.guestList.append(guestID)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        foodTableView.delegate = self
        foodTableView.dataSource = self
        // Do any additional setup after loading the view.
        
        databaseRef = Database.database().reference()
        
        queryForUsers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
