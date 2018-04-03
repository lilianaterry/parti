//
//  ViewController.swift
//  Music Upvote
//
//  Created by Ethan Elkins on 3/28/18.
//  Copyright © 2018 Ethan Elkins. All rights reserved.
//

import UIKit

import FirebaseDatabase

class MusicCell: UITableViewCell {
    
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    var partyObject = PartyModel()
    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var value: UILabel!
    @IBAction func Up(_ sender: Any) {
        databaseRef.child("parties/\(partyObject.partyID)/musicList/\(songName.text)").observeSingleEvent(of: .value) { (snapshot) in
            var Value = snapshot.value
            var Integer = Int(value) + 1
        }
            
        databaseRef.child("parties/\(partyObject.partyID)/musicList/\(songName.text)").setValue(Integer)
        
        if (Integer > 0){
            Integer.textColor = UIColor.green
        }
    }
    
    @IBAction func Down(_ sender: Any) {
        databaseRef.child("parties/\(partyObject.partyID)/musicList/\(songName.text)").observeSingleEvent(of: .value) { (snapshot) in
            var Value = snapshot.value
            var Integer = Int(value) - 1
            
            databaseRef.child("parties/\(partyObject.partyID)/musicList/\(songName.text)").setValue(Integer)
            if (Integer < 0){
                Integer.textColor = UIColor.red
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


