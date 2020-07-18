
//
//  DragonNode.swift
//  Dragon War
//
//  Created by Jay Firke on 2018/3/19.
//  Copyright © 2019 Jay Firke. All rights reserved.
//

import ARKit
import UIKit

public class DragonNode : SCNNodeContainer{
    
    var node : SCNNode!
    var dragon : Dragon
    var lastAxis = SCNVector3Make(0, 0, 0)
    
    var spawnCount = 0
    
    // setup initial dragon values
    init(dragon: Dragon, position: SCNVector3, cameraPosition: SCNVector3) {

        self.dragon = dragon
        self.node = createNode()
        self.node.position = position
        self.node.rotation = SCNVector4Make(0, 1, 0, 0)
        
        let deltaRotation = getXZRotation(towardsPosition: cameraPosition)
        if deltaRotation > 0 {
            node.rotation.w -= deltaRotation
        }else if deltaRotation < 0 {
            node.rotation.w -= deltaRotation
        }
    }
    
    // returns what angle the dragon has to rotate to face the given position
    func getXZRotation(towardsPosition toPosition: SCNVector3) -> Float {
        
        // creates the normalized vector for the position
        var unitDistance = (toPosition - node.position).negate()
        unitDistance.y = 0
        unitDistance = unitDistance.normalized()
        
        // creates the normalized vector for the dragon
        var unitDirection = self.node.convertPosition(SCNVector3Make(0, 0, -1), to: nil) - self.node.position
        unitDirection.y = 0
        unitDirection = unitDirection.normalized()
        
        // returns the angle it has to rotate
        let axis = unitDistance.cross(vector: unitDirection).normalized() //cross product
        let angle = acos(unitDistance.dot(vector: unitDirection))
        return angle * axis.y
        
    }
    
    private func createNode() -> SCNNode{
        // scale down the dragon texture
        let scaleFactor = dragon.image.size.width/0.2
        let width = dragon.image.size.width/scaleFactor
        let height = dragon.image.size.height/scaleFactor
        
        // creates a plane to represent the dragon
        let geometry = SCNPlane(width: width, height: height)
        let material = SCNMaterial()
        material.diffuse.contents = dragon.image
        geometry.materials = [material]
        
        let node = SCNNode(geometry: geometry)
        
        // static physics body so movement can be controlled manually
        node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        node.physicsBody?.contactTestBitMask = PhysicsMask.enemy
        node.physicsBody?.isAffectedByGravity = false
        return node
    }
    
    func move(towardsPosition toPosition : SCNVector3) -> Bool{
        
        // distance between dragon and the position
        let deltaPos = (toPosition - node.position)
        
        // if dragon is too close to move, it won't
        guard deltaPos.length() > 0.05 else { return false }
        let normDeltaPos = deltaPos.normalized()
        
        // move the Y so its closer to the player
        node.position.y += normDeltaPos.y/50

        // distance on XZ plane
        let length = deltaPos.xzLength()
        
        // if dragon is not in the "goldilocks zone", move towards the player
        // if dragon is really close to the player, it crashes into the player
        if length > 0.5 || length < 0.1 {
            node.position.x += normDeltaPos.x/250
            node.position.z += normDeltaPos.z/250
            dragon.closeQuarters = false
        }else{
            dragon.closeQuarters = true
        }
        
        // angle it must rotate to face player
        let goalRotation = getXZRotation(towardsPosition: toPosition)
        
        // slowly rotate in that direction
        if goalRotation > 0 {
            node.rotation.w -= min(Float.pi/180, goalRotation)
        }else if goalRotation < 0 {
            node.rotation.w -= max(-Float.pi/180, goalRotation)
        }
        
        return true
    }
    
}
