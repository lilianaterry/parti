//
//  ViewController.swift
//  PartiMusic
//
//  Created by Liliana Terry on 4/9/18.
//  Copyright © 2018 The Party App. All rights reserved.
//

import UIKit
import Alamofire

class MusicListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var musicTableView: UITableView!
    
    var searchURL = "https://ws.audioscrobbler.com/2.0/?method=track.search&track=Believe&api_key=46aaa1b1848327d7f093d37cbf8cb21f&format=json"
    var tracks = [MusicModel]()
    
    // alias this so we can just type JSONStandard each time
    typealias JSONStandard = [String: AnyObject]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.musicTableView.dataSource = self
        self.musicTableView.delegate = self
        
        callAlamo(url: searchURL)
    }
    
    // grabs data from provided URL
    func callAlamo(url: String) {
        Alamofire.request(url).responseJSON { (response) in
            self.parseData(JSONData: response.data!)
        }
    }
    
    // parses json
    func parseData(JSONData: Data) {
        // serialize json data that comes in
        // mutable means it can be molded
        do {
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            if let tracks = readableJSON["results"] as? JSONStandard {
                if let trackMatches = tracks["trackmatches"] as? JSONStandard {
                    if let tracks = trackMatches["track"] as? [JSONStandard] {
                        for i in (0..<tracks.count) {
                            let item = tracks[i]
                            
                            let track = MusicModel()
                            track.songName = item["name"] as? String
                            track.artistName = item["artist"] as? String
                            
                            if let image = item["image"] as? NSArray {
                                // get small sized image (1st block)
                                let imageBlock = image[2] as! JSONStandard
                                let imageURL = URL(string: imageBlock["#text"]! as! String)
                                let imageData = NSData(contentsOf: imageURL!)
                                
                                let albumImage = UIImage(data: imageData! as Data)
                                track.albumImage = albumImage
                            }
                            
                            // TODO: sort by greatest # of listeners first
                            // let listeners = item["listeners"]
                            
                            self.tracks.append(track)
                            self.musicTableView.reloadData()
                        }
                    }
                }
            }
        } catch {
            print(error)
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
        
        return cell
    }
}

