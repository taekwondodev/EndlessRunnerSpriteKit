//
//  PhysicsCategory.swift
//  EndlessRunnerSpriteKit
//
//  Created by Davide Galdiero on 13/12/23.
//

import Foundation

struct PhysicsCategory {
    
    //This bit are equal to 2^0, 2^1 ...
    static let player: UInt32 = 0b1
    static let obstacle: UInt32 = 0b10
    static let ground: UInt32 = 0b100
    static let paperCoin: UInt32 = 0b1000
    
}
