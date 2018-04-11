//
//  MusicTableViewCell.swift
//  PartiMusic
//
//  Created by Liliana Terry on 4/10/18.
//  Copyright © 2018 The Party App. All rights reserved.
//

import UIKit

class MusicTableViewCell: UITableViewCell {
    
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var voteCounts: UILabel!
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        self.backgroundColor = UIColor.clear
    }
    
}
