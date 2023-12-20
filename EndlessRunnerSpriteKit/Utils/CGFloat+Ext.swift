//
//  CGFloat+Ext.swift
//  EndlessRunnerSpriteKit
//
//  Created by Davide Galdiero on 13/12/23.
//

import CoreGraphics
import UIKit

extension CGFloat{
    //returna un numero tra 0 e 1
    static func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / Float(0xFFFFFFFF))
    }
    
    //returna o min o max
    static func random(min: CGFloat, max: CGFloat) -> CGFloat{
        assert(min<max)
        return CGFloat.random() * (max-min) + min
    }
}

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
