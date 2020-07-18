
//
//  Game.swift
//  Dragon War
//
//  Created by Jay Firke on 2018/3/19.
//  Copyright © 2019 Jay Firke. All rights reserved.
//

import Foundation

public class Game {
    
    var delegate : GameDelegate?
    
    let cooldown = 0.9 // so the player can't spam bullets
    let power = 1 // how much damage the bullet does
    var health = 5  { // how much health the player has
        didSet{
            delegate?.healthDidChange()
        }
    }
    
    var lastShot : TimeInterval = 0 // last time the player shot
    
    func playerCanShoot() -> Bool {
        // checks to make sure the cooldown is over before the player shoots again
        let curTime = Date().timeIntervalSince1970
        if(curTime - lastShot > cooldown){
            lastShot = curTime
            return true
        }
        return false
    }
    
    var spawnCount = 0 // counter for dragon spawn
    public var spawnFreq = 90 // how often it will attempt to spawn an dragon
    let spawnProb : UInt32 = 2 // how often the dragon will actually be spawned
    public var shotFreq = 60 // how often it will attempt to shoot
    
    public var totalDragons = 0 // number of dragons that must be killed to win
    let dragonPower = 1 // how much damage the dragon's bullet does
    let dragonHealth = 1 // how much health the dragon has
        
    var winLoseFlag : Bool? // whether the player won, lost, or still playing
    
    // current score
    var score = 0 {
        didSet{
            delegate?.scoreDidChange()
        }
    }
    
    // randomizes dragon spawn
    func spawnDragon(numDragons: Int) -> Dragon?{
        guard numDragons < totalDragons else { return nil }
        spawnCount += 1
        if(spawnCount == spawnFreq){
            spawnCount = 0
            if(arc4random_uniform(spawnProb) == 0){
                return Dragon(health: dragonHealth, power: dragonPower, shotFreq: shotFreq, shotProbHigh: 10, shotProbLow: 2)
            }
        }
        return nil
    }
}

protocol GameDelegate {
    func scoreDidChange()
    func healthDidChange()
}

