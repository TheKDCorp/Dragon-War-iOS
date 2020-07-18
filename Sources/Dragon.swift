
//
//  Dragon.swift
//  Dragon War
//
//  Created by Jay Firke on 2018/3/19.
//  Copyright © 2019 Jay Firke. All rights reserved.
//

import UIKit

public class Dragon {
    
    var health : Int
    let power : Int
    var shotCount = 0
    let shotFreq : Int
    var shotProb : Int { 
        return closeQuarters ? shotProbHigh : shotProbLow
    }
    private let shotProbHigh : Int
    private let shotProbLow : Int
    
    var closeQuarters = false // in the "goldilocks zone"
    let image : UIImage
    
    init(health: Int, power: Int, shotFreq: Int, shotProbHigh: Int, shotProbLow: Int){
        self.health = health
        self.power = power
        self.shotFreq = shotFreq
        self.shotProbLow = shotProbLow
        self.shotProbHigh = shotProbHigh
        
        // to randomize the dragon's texture
        if (Double(arc4random()) / 0xFFFFFFFF > 0.5){
            self.image = UIImage(named: "Dragon1")!
        } else if (Double(arc4random()) / 0xFFFFFFFF > 0.5) {
            self.image = UIImage(named: "Dragon2")!
        } else {
            self.image = UIImage(named: "Dragon3")!
        }
    }
    
    func shouldShoot() -> Bool {
        // randomize the shooting
        shotCount += 1
        if(shotCount == shotFreq){
            shotCount = 0
            return arc4random_uniform(UInt32(shotProb)) == 0
        }
        return false
    }
}
