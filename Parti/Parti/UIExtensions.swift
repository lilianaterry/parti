//
//  UIExtensions.swift
//  PartyUI
//
//  Created by Liliana Terry on 4/17/18.
//  Copyright © 2018 The Party App. All rights reserved.
//

import UIKit

class UIExtensions {
    // party list colors
    let backgroundLightGrey = UIColor.init(hex: 0xEBEBEB)
    let backgroundDarkGrey = UIColor.init(hex: 0xF2F0F0)
    let buttonText = UIColor.init(hex: 0x909293)
    
    // main color pallete
    let mainColor = UIColor.init(hex: 0x55efc4)
    let darkMint = UIColor.init(hex: 0x00b894)
    let darkGrey = UIColor.init(hex: 0x2d3436)
    let mediumGrey = UIColor.init(hex: 0xb2bec3)
    let lightGrey = UIColor.init(hex: 0xdfe6e9)
    
    // profile colors
    let nameColor = UIColor.init(hex: 0x222222)
}

// create UI color from hex code
extension UIColor {
    
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
    
}

// add shadow to anything
extension CALayer {
    func applyShadow(
        color: UIColor,
        alpha: Float,
        x: CGFloat,
        y: CGFloat,
        blur: CGFloat,
        spread: CGFloat)
    {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}

// add bottom border to text 
extension CALayer {
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
        case .bottom:
            border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
        case .right:
            border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        addSublayer(border)
    }
}
