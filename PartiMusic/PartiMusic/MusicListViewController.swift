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
    
    var imageURL: URL?
}

class MusicListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var musicTableView: UITableView!
    
    // all songs currently in the shared list
    var tracks = [musicModel]()
    
    @IBAction func addTrack(_ sender: Any) {
        performSegue(withIdentifier: "showPopupSegue", sender: self)
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
        
        // color the count if necessary
        if (track.count > 0) {
            cell.voteCounts.textColor = UIColor.green
        } else if (track.count < 0) {
            cell.voteCounts.textColor = UIColor.red
        }
        
        cell.upVoteButton.tag = indexPath.row
        cell.downVoteButton.tag = indexPath.row
        
        return cell
    }
    
    // add 1 to this track's rating
    @IBAction func upVote(_ sender: UIButton) {
        let button = sender as UIButton;
        let newCount = tracks[button.tag].count + 1
        
        let indexPath = IndexPath(row: button.tag, section: 0)
        let cell = musicTableView.cellForRow(at: indexPath) as! MusicTableViewCell
        
        cell.voteCounts.text = String(newCount)
        tracks[button.tag].count = newCount
        
        // change the color if we've gone above 0
        if (newCount > 0) {
            cell.voteCounts.textColor = UIColor.green
        } else if (newCount == 0) {
            cell.voteCounts.textColor = UIColor.black
        }
    }
    
    // subtract 1 from this track's rating
    @IBAction func downVote(_ sender: UIButton) {
        let button = sender as UIButton;
        let newCount = tracks[button.tag].count - 1
        
        let indexPath = IndexPath(row: button.tag, section: 0)
        let cell = musicTableView.cellForRow(at: indexPath) as! MusicTableViewCell
        
        cell.voteCounts.text = String(newCount)
        tracks[button.tag].count = newCount
        
        // change the color if we've gone above 0
        if (newCount < 0) {
            cell.voteCounts.textColor = UIColor.red
        } else if (newCount == 0) {
            cell.voteCounts.textColor = UIColor.black
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueID = segue.identifier
        
        if (segueID == "showPopupSegue") {
            if let destinationVC = segue.destination as? AddSongViewController {
                destinationVC.previousList = tracks
            }
        }
    }
}

