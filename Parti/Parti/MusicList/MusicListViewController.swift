//
//  ViewController.swift
//  PartiMusic
//
//  Created by Liliana Terry on 4/9/18.
//  Copyright © 2018 The Party App. All rights reserved.
//

import UIKit
import Alamofire

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
    
    // all songs currently in the shared list
    var tracks = [musicModel]()
    var tracksSet = Set<String>()
    
    @IBAction func addTrack(_ sender: Any) {
        performSegue(withIdentifier: "showPopupSegue", sender: self)
    }
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    // alias this so we can just type JSONStandard each time
    typealias JSONStandard = [String: AnyObject]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.musicTableView.dataSource = self
        self.musicTableView.delegate = self
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
    }
    
    // change the count label by the amount specified (0, 1, -1, 2, -2)
    func updateCount(button: UIButton, amount: Int) {
        let newCount = tracks[button.tag].count + amount
        
        let indexPath = IndexPath(row: button.tag, section: 0)
        let cell = musicTableView.cellForRow(at: indexPath) as! MusicTableViewCell
        
        cell.voteCounts.text = String(newCount)
        tracks[button.tag].count = newCount
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueID = segue.identifier
        
        if (segueID == "showPopupSegue") {
            if let destinationVC = segue.destination as? AddSongViewController {
                destinationVC.previousList = tracks
                destinationVC.previousSet = tracksSet
            }
        }
    }
}

