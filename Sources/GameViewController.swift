
//
//  GameViewController.swift
//  Dragon War
//
//  Created by Jay Firke on 2018/3/19.
//  Copyright © 2019 Jay Firke. All rights reserved.
//

import UIKit
import ARKit
import SpriteKit
import SceneKit
import AVFoundation

struct PhysicsMask {
    static let playerBullet = 0
    static let enemyBullet = 1
    static let enemy = 2
}

enum LaserType  {
    case player
    case enemy
}

public class GameViewController: UIViewController, GameDelegate, ARSCNViewDelegate, ARSessionDelegate{

    let session = ARSession()
    var sceneView : ARSCNView!
    
    var dragons = [DragonNode]()
    var lasers = [LaserNode]()
    public var game = Game()
    
    // font things
    
    lazy var paragraphStyle : NSParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.left
        return style
    }()
    
    lazy var stringAttributes : [NSAttributedString.Key : Any] = [.strokeColor : UIColor.black, .strokeWidth : -4, .foregroundColor: UIColor.white, .font : UIFont.systemFont(ofSize: 23, weight: .bold), .paragraphStyle : paragraphStyle]
    
    // Nodes for the UI
    var scoreNode : SKLabelNode!
    var livesNode : SKLabelNode!
    var newlivesNode : SKLabelNode!
    var radarNode : SKShapeNode!
    var crosshair: SKSpriteNode!
    
    let sidePadding : CGFloat = 5

    
    //MARK: GameDelegate Functions
    
    func scoreDidChange() {
        scoreNode.attributedText = NSMutableAttributedString(string: " ", attributes: stringAttributes)
        if game.score >= game.totalDragons {
            game.winLoseFlag = true
            showFinish()
        }
    }
    
    func healthDidChange() {
        
        // change the number to emojis
        var i = 0
        var healthEmoji = ""
        while i<game.health {
            i = i+1
            healthEmoji += "❣️"
        }
        livesNode.attributedText = NSAttributedString(string: "My Health: \(healthEmoji)", attributes: stringAttributes)
        if game.health <= 0 {
            game.winLoseFlag = false
            showFinish()
        }
    }
    
    
    //MARK: View Controller Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        game.delegate = self
        setupAR()
        setupGestureRecognizers()
        setupScene()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    //Mark: UI Setup
    
    private func setupAR() {
        // setup the AR stuff
        
        sceneView = ARSCNView(frame: CGRect(x: 0.0, y: 0.0, width: 475.0, height: 740.0))
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        let config = ARWorldTrackingConfiguration()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session = session
        
        sceneView.session.delegate = self
        
        self.view = sceneView
        sceneView.session.run(config)
    }
    
    private func setupScene() {
        // setup the scene... pretty self-explanatory :D
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.overlaySKScene = SKScene(size: sceneView.bounds.size)
        sceneView.overlaySKScene?.scaleMode = .resizeFill
        setupLabels()
        setupRadar()
    }
    
    private func setupGestureRecognizers() {
        // add tap recognizer
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        
        tapRecognizer.numberOfTouchesRequired = 1
        
        sceneView.addGestureRecognizer(tapRecognizer)
    }
    
    private func setupRadar() {
        let size = sceneView.bounds.size
        
        // radar background
        radarNode = SKShapeNode(circleOfRadius: 45)
        radarNode.position = CGPoint(x: 475 - 120 + sidePadding, y: 100 + sidePadding)
        radarNode.strokeColor = .init(red: 8.0, green: 154.0, blue: 9.0, alpha: 1.0)
        radarNode.glowWidth = 4
        radarNode.fillColor = .init(red: 0.0, green: 77.0, blue: 0.0, alpha: 1.0)
        sceneView.overlaySKScene?.addChild(radarNode)
        
        // radar design
        for i in (1...4){
            let ringNode = SKShapeNode(circleOfRadius: CGFloat(i * 10))
            ringNode.strokeColor = .init(red: 8.0, green: 225.0, blue: 9.0, alpha: 1.0)
            ringNode.glowWidth = 0.2
            ringNode.name = "Ring"
            ringNode.position = radarNode.position
            sceneView.overlaySKScene?.addChild(ringNode)
        }
        
        //blips for each dragon
        for _ in (0..<(game.totalDragons)){
            let blip = SKShapeNode(circleOfRadius: 6)
            blip.fillColor = .init(red: 0.0, green: 225.0, blue: 1.0, alpha: 0.5) // Dragin's color
            blip.strokeColor = .clear
            blip.alpha = 1
            radarNode.addChild(blip)
        }
        
    }
    
    private func setupLabels() {
        
        // setup the UI
        let size = sceneView.bounds

        scoreNode = SKLabelNode(attributedText: NSAttributedString(string: " ", attributes: stringAttributes))
        scoreNode.alpha = 1
        
        var i = 0
        var healthEmoji = ""
        while i<game.health {
            i = i+1
            healthEmoji += "❣️"
        }
        livesNode = SKLabelNode(attributedText: NSAttributedString(string: "My Health: \(healthEmoji)", attributes: stringAttributes))
        livesNode.alpha = 1

        
        crosshair = SKSpriteNode(imageNamed: "Crosshair.png")
        crosshair.size = CGSize(width: 30, height: 30)
        crosshair.alpha = 1
        
        livesNode.position = CGPoint(x: sidePadding, y: 590 )
        livesNode.horizontalAlignmentMode = .left
        crosshair.position = CGPoint(x: size.midX - 10 , y: size.midY - 35 )
        
        sceneView.overlaySKScene?.addChild(livesNode)
        sceneView.overlaySKScene?.addChild(crosshair)
    }
    
    private func showFinish() {
        guard let hasWon = game.winLoseFlag else { return }
        
        // present the AR text
        let text = SCNText(string: hasWon ? "You Won The Game!!!,      Winner Winner Chicken Dinner!!! , Made By:- Jay Firke" : "Oh!!!, You Lose The Game, Please Try Again!, Made By:- Jay Firke", extrusionDepth: 0.5)
        let material = SCNMaterial()
        material.diffuse.contents = hasWon ? UIColor.green : UIColor.red
        
        // make the text appear on multiple lines
        text.isWrapped = true
        text.containerFrame = CGRect(origin: .zero, size: CGSize(width: 100.0, height: 400.0))
        text.materials = [material]
        
        let node = SCNNode()
        node.simdPosition = simd_float3((sceneView.pointOfView?.simdPosition.x)!, (sceneView.pointOfView?.simdPosition.y)! - 2.8, (sceneView.pointOfView?.simdPosition.z)!) + sceneView.pointOfView!.simdWorldFront * 0.5
        node.simdRotation = sceneView.pointOfView!.simdRotation
        node.scale = SCNVector3(x: 0.007, y: 0.007, z: 0.007)
        node.geometry = text
        
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    //Mark: UI Gesture Actions

    @objc func handleTap(recognizer: UITapGestureRecognizer){
        // if the player taps the screen, shoot!
        if game.playerCanShoot() {
            fireLaser(fromNode: sceneView.pointOfView!, type: .player)
        }
    }
    
    //MARK: Game Actions
    
    func fireLaser(fromNode node: SCNNode, type: LaserType){
        guard game.winLoseFlag == nil else { return }
        let pov = sceneView.pointOfView!
        var position: SCNVector3
        var convertedPosition: SCNVector3
        var direction : SCNVector3
        switch type {
            
        case .enemy:
            // If enemy, shoot at the player
            position = SCNVector3Make(0, 0, 0.05)
            convertedPosition = node.convertPosition(position, to: nil)
            direction = pov.position - node.position
        default:
            // play the sound effect
            self.playSoundEffect(ofType: .torpedo)
            // if player, shoot straight ahead
            position = SCNVector3Make(0, 0, -0.05)
            convertedPosition = node.convertPosition(position, to: nil)
            direction = convertedPosition - pov.position
        }
        
        let laser = LaserNode(initialPosition: convertedPosition, direction: direction, type: type)
        lasers.append(laser)
        sceneView.scene.rootNode.addChildNode(laser.node)
    }
    
    private func spawnDragon(dragon: Dragon){
        let pov = sceneView.pointOfView!
        let y = (Float(arc4random_uniform(60)) - 29) * 0.01 // Random Y value between -0.3 and 0.3
        
        //Random X and Z values for the dragon
        let xRad = ((Float(arc4random_uniform(361)) - 180)/180) * Float.pi
        let zRad = ((Float(arc4random_uniform(361)) - 180)/180) * Float.pi
        let length = Float(arc4random_uniform(6) + 4) * -0.3
        let x = length * sin(xRad)
        let z = length * cos(zRad)
        let position = SCNVector3Make(x, y, z)
        let worldPosition = pov.convertPosition(position, to: nil)
        let dragonNode = DragonNode(dragon: dragon, position: worldPosition, cameraPosition: pov.position)
        
        dragons.append(dragonNode)
        sceneView.scene.rootNode.addChildNode(dragonNode.node)
    }
    
    // MARK: - Sound Effects
    
    var player: AVAudioPlayer!
    
    func playSoundEffect(ofType effect: SoundEffect) {
        
        // Async to decrease processing power needed
        DispatchQueue.main.async {
            do {
                if let effectURL = Bundle.main.url(forResource: effect.rawValue, withExtension: "mp3") {
                    self.player = try AVAudioPlayer(contentsOf: effectURL)
                    self.player.play()
                }
            }
            catch let error as NSError {
                print(error.description)
            }
        }
    }

}

enum SoundEffect: String {
    case explosion = "explosion"
    case collision = "collision"
    case torpedo = "torpedo"
}

//MARK: Scene Physics Contact Delegate

extension GameViewController : SCNPhysicsContactDelegate {
    
    public func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let maskA = contact.nodeA.physicsBody!.contactTestBitMask
        let maskB = contact.nodeB.physicsBody!.contactTestBitMask

        switch(maskA, maskB){
        case (PhysicsMask.enemy, PhysicsMask.playerBullet):
            self.playSoundEffect(ofType: .collision)
            hitEnemy(bullet: contact.nodeB, enemy: contact.nodeA)
            self.playSoundEffect(ofType: .collision)
        case (PhysicsMask.playerBullet, PhysicsMask.enemy):
            self.playSoundEffect(ofType: .collision)
            hitEnemy(bullet: contact.nodeA, enemy: contact.nodeB)
        default:
            break
        }
    }
    
    func hitEnemy(bullet: SCNNode, enemy: SCNNode){
        
        self.playSoundEffect(ofType: .explosion)
        
        let particleSystem = SCNParticleSystem(named: "explosion", inDirectory: nil)
        let systemNode = SCNNode()
        systemNode.addParticleSystem(particleSystem!)
        systemNode.scale = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
        systemNode.position = bullet.position
        sceneView.scene.rootNode.addChildNode(systemNode)
        
        bullet.removeFromParentNode()
        enemy.removeFromParentNode()
        game.score += 1
    }
}

//MARK: AR SceneView Delegate
extension GameViewController{
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard game.winLoseFlag == nil else { return }

        // Let Game spawn an dragon
        if let dragon = game.spawnDragon(numDragons: dragons.count){
            spawnDragon(dragon: dragon)
        }
        
        for (i, dragon) in dragons.enumerated().reversed() {
            
            // If the dragon no longer exists, remove it from the list
            guard dragon.node.parent != nil else {
                dragons.remove(at: i)
                continue
            }
            
            // move the dragon towards to player
            if dragon.move(towardsPosition: sceneView.pointOfView!.position) == false {
                // if the dragon can't move closer, it crashes into the player
                dragon.node.removeFromParentNode()
                dragons.remove(at: i)
                game.health -= dragon.dragon.health
            }else {
            
                if dragon.dragon.shouldShoot() {
                    fireLaser(fromNode: dragon.node, type: .enemy)
                }
            }
        }
        
        // Draw dragons on the radar as an XZ Plane
        for (i, blip) in radarNode.children.enumerated() {
            if i < dragons.count {
                let dragon = dragons[i]
                blip.alpha = 1
                let relativePosition = sceneView.pointOfView!.convertPosition(dragon.node.position, from: nil)
                var x = relativePosition.x * 10
                var y = relativePosition.z * -10
                if x >= 0 { x = min(x, 35) } else { x = max(x, -35)}
                if y >= 0 { y = min(y, 35) } else { y = max(y, -35)}
                blip.position = CGPoint(x: CGFloat(x), y: CGFloat(y))
            }else{
                // If the dragon hasn't spawned yet, hide the blip
                blip.alpha = 0
            }
            
        }
        
        for (i, laser) in lasers.enumerated().reversed() {
            if laser.node.parent == nil {
                // If the bullet no longer exists, remove it from the list
                lasers.remove(at: i)
            }
            // move the laser
            if laser.move() == false {
                laser.node.removeFromParentNode()
                lasers.remove(at: i)
            } else {
                // Check if the bullet hit the player
                if laser.node.physicsBody?.contactTestBitMask == PhysicsMask.enemyBullet
                    && laser.node.position.distance(vector: sceneView.pointOfView!.position) < 0.03{
                    laser.node.removeFromParentNode()
                    lasers.remove(at: i)
                    game.health -= 1
                }
            }
        }
    }

}

