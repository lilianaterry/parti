//
//  GuestListViewController.swift
//  Parti
//
//  Created by Liliana Terry on 3/18/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit
import FirebaseDatabase

class GuestListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var guestTableView: UITableView!

    // Firebase connection
    var ref: DatabaseReference!
    var databaseHandle: DatabaseHandle?

    // list of guests
    var guestList = [ProfileModel]()
    var partyObject = PartyModel()
    
    /* Returns the number of cells to populate the table with */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return guestList.count
    }

    /* Dequeues cells from partyList and returns a filled-in table cell */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "guestCell", for: indexPath) as! GuestTableViewCell

        let currentGuest = guestList[indexPath.row]

        // update information contained in cell
        cell.guestName.text = currentGuest.name
        
        // now get guest's profile picture
        let url = URL(string: currentGuest.pictureURL)
        URLSession.shared.dataTask(with: url!, completionHandler: { (image, response, error) in
            if (error != nil) {
                print(error)
                return
            }
            print("about to save!!! fingers crossed!")
            DispatchQueue.main.async { // Make sure you're on the main thread here
                cell.guestImage?.image = UIImage(data: image!)
            }
        }).resume()

        // update appearance of cell
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero

        return cell
    }
    

    /* Runs when page is loaded, sets the delegate and datasource then calls method to query
     Firebase and add parties to partyList */
    override func viewDidLoad() {
        super.viewDidLoad()
        print("did load")

        self.guestTableView.dataSource = self
        self.guestTableView.delegate = self

        // set firebase reference
        ref = Database.database().reference()
        
        // query Firebase and get a list of all parties for this user
        populateGuestTable()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /* Creates an instance of the PartyModel class and fills in all relevant information
     from Firebase query. Adds the PartyModel to partyList and reloads View */
    func populateGuestTable() {
        print("in populate guest table")
        databaseHandle = ref?.child("parties/\(self.partyObject.partyID)/guests").observe(.childAdded, with: { (snapshot) in
            
            let userID = snapshot.key
            let attending = snapshot.value as! Bool
            
            self.getGuestInfo(userID: userID)

        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getGuestInfo(userID: String) {
        databaseHandle = ref?.child("users/\(userID)").observe(.value, with: { (snapshot) in
            print("POPULATE PROFILE PAGE")
            let data = snapshot.value as! [String: Any]
            
            var guest = ProfileModel()
            
            // If the user already has a profile picture, load it up!
            if let pictureURL = data["pictureURL"] as? String {
                guest.pictureURL = pictureURL
            }
            guest.name = data["name"] as! String
            
            self.guestList.append(guest)
            self.guestTableView.reloadData()
            
        }) { (error) in
            print(error.localizedDescription)
        }

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    
}


