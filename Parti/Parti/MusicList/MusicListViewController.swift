//
//  ViewController.swift
//  PartiMusic
//
//  Created by Liliana Terry on 4/9/18.
//  Copyright © 2018 The Party App. All rights reserved.
//

import UIKit
import Alamofire
import FirebaseDatabase
import FirebaseAuth

// object to hold API query items
struct musicModel {
    var songName: String?
    var artistName: String?
    var albumImage: UIImage?
    var count: Int
    var userVote: Int
    
    var imageURL: URL?
}

class MusicListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var musicTableView: UITableView!
    
    var partyID = String()
    var hostView = true
    let currentUser = Auth.auth().currentUser?.uid
    
    // Firebase Database connection
    var databaseRef: DatabaseReference!
    var databaseHandle: DatabaseHandle?
    
    // all songs currently in the shared list
    var tracks = [musicModel]()
    var tracksSet = Set<String>()
    
    // navigation buttons
    @IBAction func addTrack(_ sender: Any) {
        performSegue(withIdentifier: "showPopupSegue", sender: self)
    }
    
    // go back to the main party page
    @IBAction func backButton(_ sender: Any) {
        if (hostView) {
            self.performSegue(withIdentifier: "hostPartyPage", sender: self)
        } else {
            self.performSegue(withIdentifier: "guestPartyPage", sender: self)
        }
    }
    
    // alias this so we can just type JSONStandard each time
    typealias JSONStandard = [String: AnyObject]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.musicTableView.dataSource = self
        self.musicTableView.delegate = self
        
        databaseRef = Database.database().reference()
        
        loadMusicList()
    }
    
    // load in the songs that users have already chosen for this party
    func loadMusicList() {
        databaseRef.child("parties/\(partyID)/musicList").observe(.childAdded) { (snapshot) in
            if (snapshot.exists()) {
                var track = snapshot.value as! [String: Any]
                
                var newTrack = musicModel(songName: "", artistName: "", albumImage: nil, count: 0, userVote: 0, imageURL: nil)

                // get all text information on this track
                newTrack.songName = track["songName"] as? String
                newTrack.artistName = track["artistName"] as? String
                newTrack.count = track["count"] as! Int
                newTrack.imageURL = URL(string: track["imageURL"] as! String)
                
                // get album image for this track
                let imageData = NSData(contentsOf: newTrack.imageURL!)
                let albumImage = UIImage(data: imageData! as Data)
                newTrack.albumImage = albumImage
                
                // if this user has voted, have their votes reflected in the list
                let votes = track["votes"] as! [String: Any]
                if (votes.keys.contains(self.currentUser!)) {
                    newTrack.userVote = votes[self.currentUser!] as! Int
                } else {
                    newTrack.userVote = 0
                }
                
                self.tracks.append(newTrack)
                self.tracksSet.insert("\(newTrack.songName!)\(newTrack.artistName!)")
                self.musicTableView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    // populate cell with track information
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "musicCell") as! MusicTableViewCell
        
        let track = tracks[indexPath.row]
        cell.songName.text = track.songName
        cell.artistName.text = track.artistName
        cell.albumImage.image = track.albumImage
        cell.voteCounts.text = String(track.count)
        
        // color the buttons if necessary
        if (track.userVote == 1) {
            cell.upVoteButton.tintColor = UIColor.green
        } else if (track.userVote == -1) {
            cell.downVoteButton.tintColor = UIColor.red
        }
        
        cell.upVoteButton.tag = indexPath.row
        cell.downVoteButton.tag = indexPath.row
        
        return cell
    }
    
    // either cancel out an existing vote or add a new one
    @IBAction func upVote(_ sender: UIButton) {
        let button = sender as UIButton;
        let userVote = tracks[button.tag].userVote
        
        let indexPath = IndexPath(row: button.tag, section: 0)
        let cell = musicTableView.cellForRow(at: indexPath) as! MusicTableViewCell
        
        // user hasn't voted
        if (userVote == 0) {
            updateCount(button: button, amount: 1)
            cell.upVoteButton.tintColor = UIColor.green
            tracks[button.tag].userVote = 1
        // undo a positive vote
        } else if (userVote == 1) {
            updateCount(button: button, amount: -1)
            cell.upVoteButton.tintColor = UIColor.black
            tracks[button.tag].userVote = 0
        // switch from positive to negative vote
        } else if (userVote == -1) {
            updateCount(button: button, amount: 2)
            cell.upVoteButton.tintColor = UIColor.green
            cell.downVoteButton.tintColor = UIColor.black
            tracks[button.tag].userVote = 1
        }
        
        let trackKey = "\(tracks[button.tag].songName!)\(tracks[button.tag].artistName!))"
        updateFirebaseUserVote(newVote: tracks[button.tag].userVote, trackKey: trackKey)
    }
    
    // either cancel out an existing vote or add a new one
    @IBAction func downVote(_ sender: UIButton) {
        let button = sender as UIButton;
        let userVote = tracks[button.tag].userVote
        
        let indexPath = IndexPath(row: button.tag, section: 0)
        let cell = musicTableView.cellForRow(at: indexPath) as! MusicTableViewCell
        
        // the user has not voted
        if (userVote == 0) {
            updateCount(button: button, amount: -1)
            cell.downVoteButton.tintColor = UIColor.red
            tracks[button.tag].userVote = -1
        // undo a negative vote
        } else if (userVote == -1) {
            updateCount(button: button, amount: 1)
            cell.downVoteButton.tintColor = UIColor.black
            tracks[button.tag].userVote = 0
        // switch from positive to negative vote
        } else if (userVote == 1) {
            updateCount(button: button, amount: -2)
            cell.downVoteButton.tintColor = UIColor.red
            cell.upVoteButton.tintColor = UIColor.black
            tracks[button.tag].userVote = -1
        }
        
        let trackKey = "\(tracks[button.tag].songName!)\(tracks[button.tag].artistName!))"
        updateFirebaseUserVote(newVote: tracks[button.tag].userVote, trackKey: trackKey)
    }
    
    // change the count label by the amount specified (0, 1, -1, 2, -2)
    func updateCount(button: UIButton, amount: Int) {
        let newCount = tracks[button.tag].count + amount
        
        let indexPath = IndexPath(row: button.tag, section: 0)
        let cell = musicTableView.cellForRow(at: indexPath) as! MusicTableViewCell
        
        cell.voteCounts.text = String(newCount)
        tracks[button.tag].count = newCount
        
        // now make this change stick
        let trackKey = "\(tracks[button.tag].songName!)\(tracks[button.tag].artistName!))"
        updateFirebaseTrackCount(newCount: newCount, trackKey: trackKey)
    }
    
    // update this user's vote in Firebase
    func updateFirebaseUserVote(newVote: Int, trackKey: String) {
        let path = "parties/\(partyID)/musicList/\(trackKey)/votes/\(self.currentUser!)"
        // remove user's vote
        if (newVote == 0) {
            databaseRef.child(path).removeValue()
        // update user's vote
        } else {
            databaseRef.child(path).setValue(newVote)
        }
    }
    
    // update this track's total votes in Firebase
    func updateFirebaseTrackCount(newCount: Int, trackKey: String) {
        let path = "parties/\(partyID)/musicList/\(trackKey)/count"
        databaseRef.child(path).setValue(newCount)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueID = segue.identifier
        
        if (segueID == "showPopupSegue") {
            if let destinationVC = segue.destination as? AddSongViewController {
                destinationVC.previousList = tracks
                destinationVC.previousSet = tracksSet
                destinationVC.partyID = partyID
            }
        }
    }
}

