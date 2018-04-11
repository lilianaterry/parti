//
//  AddSongViewController.swift
//  PartiMusic
//
//  Created by Liliana Terry on 4/10/18.
//  Copyright © 2018 The Party App. All rights reserved.
//

import UIKit
import Alamofire

class AddSongViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    // alias this so we can just type JSONStandard each time
    typealias JSONStandard = [String: AnyObject]
    
    @IBOutlet weak var musicTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchResults = [musicModel]()
    
    var selectedSong = musicModel(songName: "", artistName: "", albumImage: nil, count: 0, imageURL: nil)
    
    var previousList = [musicModel]()
    
    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchResults = []
        
        self.musicTableView.dataSource = self
        self.musicTableView.delegate = self
        
        self.searchBar.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    // populate music table with search results
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as! SearchTableViewCell
        
        if (indexPath.row < searchResults.count) {
            let track = searchResults[indexPath.row]
            
            cell.songName.text = track.songName
            cell.artistName.text = track.artistName
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    // if cell is selected, add to table view below popup and close popup
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSong = searchResults[indexPath.row]
        let imageData = NSData(contentsOf: selectedSong.imageURL!)

        let albumImage = UIImage(data: imageData! as Data)
        selectedSong.albumImage = albumImage
        
        performSegue(withIdentifier: "addSongSegue", sender: self)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchResults = []
        if (searchText != "") {
            // split word on space delimiter
            var splitString = searchText.lowercased().components(separatedBy: " ")
            var queryText = ""
            for word in splitString {
                queryText += "\(word)+"
            }
            
            callAlamo(songName: queryText)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueID = segue.identifier
        
        if (segueID == "addSongSegue") {
            if let destinationVC = segue.destination as? MusicListViewController {
                previousList.append(selectedSong)
                destinationVC.tracks = previousList
            }
        }
    }
    
    // grabs data from provided URL
    func callAlamo(songName: String) {
        let url = "https://ws.audioscrobbler.com/2.0/?method=track.search&track=\(songName)&api_key=46aaa1b1848327d7f093d37cbf8cb21f&format=json"
        
        Alamofire.request(url).responseJSON { (response) in
            self.parseData(JSONData: response.data!)
        }
    }
    
    // parses json
    // TODO: order by listeners to return most popular
    func parseData(JSONData: Data) {
        // serialize json data that comes in
        // mutable means it can be molded
        do {
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
            if let tracks = readableJSON["results"] as? JSONStandard {
                if let trackMatches = tracks["trackmatches"] as? JSONStandard {
                    
                    // get all tracks returned
                    if let tracks = trackMatches["track"] as? [JSONStandard] {
                        for i in (0..<tracks.count) {
                            let item = tracks[i]
                            
                            var track = musicModel(songName: "", artistName: "", albumImage: nil, count: 0, imageURL: nil)
                            track.songName = item["name"] as? String
                            track.artistName = item["artist"] as? String
                            
                            // get album cover art
                            if let image = item["image"] as? NSArray {
                                // get small sized image (1st block)
                                let imageBlock = image[2] as! JSONStandard
                                let imageURL = URL(string: imageBlock["#text"]! as! String)

                                track.imageURL = imageURL

                                self.searchResults.append(track)
                                self.musicTableView.reloadData()
                            } else {
                                self.searchResults.append(track)
                                self.musicTableView.reloadData()
                            }
                        }
                    }
                }
            }
        } catch {
            print(error)
        }
    }
}
