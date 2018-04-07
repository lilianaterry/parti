//
//  Hairline.swift
//  Parti
//
//  Created by Liliana Terry on 4/7/18.
//  Copyright © 2018 Arjun Gopisetty. All rights reserved.
//

import UIKit

class HairlineViewHorizontal: UIView {
    override func awakeFromNib() {
        guard let backgroundColor = self.backgroundColor?.cgColor else { return }
        self.layer.borderColor = backgroundColor
        self.layer.borderWidth = (1.0 / UIScreen.main.scale) / 2;
        self.backgroundColor = UIColor.clear
    }
}
