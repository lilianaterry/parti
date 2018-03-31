//
//  GuestListViewController.swift
//  Parti
//
//  Created by Liliana Terry on 3/18/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

// TODO, if the hostID matches the current userID, show a plus button to add guests

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
        let url = URL(string: currentGuest.imageURL)
        URLSession.shared.dataTask(with: url!, completionHandler: { (image, response, error) in
            if (error != nil) {
                print(error)
                return
            }
            DispatchQueue.main.async { // Make sure you're on the main thread here
                cell.guestImage?.image = UIImage(data: image!)
            }
        }).resume()

        // update appearance of cell
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.userID = currentGuest.userID

        return cell
    }
    
    // method to run when table view cell is tapped to go to guest's profile
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let cell = tableView.dequeueReusableCell(withIdentifier: "guestCell", for: indexPath) as! GuestTableViewCell
        
        // Segue to the guest's profile page
        self.performSegue(withIdentifier: "guestProfileSegue3", sender: cell)

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
            if let pictureURL = data["imageURL"] as? String {
                guest.imageURL = pictureURL
            }
            guest.name = data["name"] as! String
            guest.userID = userID
            
            self.guestList.append(guest)
            self.guestTableView.reloadData()
            
        }) { (error) in
            print(error.localizedDescription)
        }

    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }

    // If you click on a guest cell, go to their profile
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueID = segue.identifier
        // Create Profile Step 1
        if (segueID == "guestProfileSegue3") {
            let cell = sender as! GuestTableViewCell
            if let destinationVC = segue.destination as? OtherUserProfile {
                destinationVC.profileObject.userID = cell.userID
            }
            // Party List Page
        }
    }
    
}


