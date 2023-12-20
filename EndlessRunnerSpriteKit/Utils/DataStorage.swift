//
//  DataStorage.swift
//  EndlessRunnerSpriteKit
//
//  Created by Davide Galdiero on 18/12/23.
//

import Foundation

class DataStorage {
    
    static let sharedIstance = DataStorage()
    
    private init() {}
    
    static let keyHighScore = "keyHighScore"
    static let keyIsPlaying = "keyIsPlaying"
    static let keyEffectEnabled = "keyEffectEnabled"
    
    func setHighScore(_ highScore: Int){
        UserDefaults.standard.set(highScore, forKey: DataStorage.keyHighScore)
    }
    
    func getHighScore() -> Int{
        return UserDefaults.standard.integer(forKey: DataStorage.keyHighScore)
    }
    
    func setKeyIsPlaying(_ isPlaying: Bool){
        UserDefaults.standard.set(isPlaying, forKey: DataStorage.keyIsPlaying)
    }
    
    func getIsPlaying() -> Bool{
        return UserDefaults.standard.bool(forKey: DataStorage.keyIsPlaying)
    }
    
    func setKeyEffectEnabled(_ effectEnabled: Bool){
        UserDefaults.standard.set(effectEnabled, forKey: DataStorage.keyEffectEnabled)
    }
    
    func getEffectEnabled() -> Bool{
        return UserDefaults.standard.bool(forKey: DataStorage.keyEffectEnabled)
    }
    
}
