//
//  AddFriendsViewController.swift
//  Parti
//
//  Created by Arjun Gopisetty on 3/21/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AddFriendsViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // Firebase Database connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    var users: [ProfileModel]!
    var filteredUsers: [ProfileModel]!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        searchBar.delegate = self
        // set firebase reference
        databaseRef = Database.database().reference()
        // TODO: Fetch friends from Firebase
        populateAllFriendsList()
        
        filteredUsers = users
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func populateAllFriendsList() {
        databaseHandle = databaseRef?.child("users").observe(.value) { snapshot in
            let enumerator = snapshot.children
            while let child = enumerator.nextObject() as? DataSnapshot {
                var data = child.value as! [String: Any]
                var user = ProfileModel()
                user.name = data["name"] as! String
                user.pictureURL = data["pictureURL"] as! String
                user.userID = data["userID"] as! String
                
                self.users.append(user)
            }
            //self.tableView.reloadData()
        }
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        tableView.reloadData()
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
