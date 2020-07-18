//#-hidden-code

//
//  Dragon War
//  Created by Jay Firke on 2018/3/19.
//  Copyright © 2019 Jay Firke. All rights reserved.
//

//#-end-hidden-code

//: ## Dragon War
/*:
 ##
 ![](Dragon-War-logo.png "Sample IMAGE")
 
 Hi! I'm **Jay Firke**, a student of Macro Vision Academy(Apple Distinguished School), Burhanpur, M.P, India. I've devoted to iOS development since 2017 and this year, and I developed Android apps also for Macro Vision Academy. I made some digging into the latest `ARKit`, which is awesome and easy to use! So I created a Dragon War game for WWDC 2019 scholarship submission. Hope you like it! 😊
 
 ### Welcome
 
 In order to let you get familiar with the game quickly, I gave you some information about this game. After tapping the `Run My Code` button, move your iPad around to initialize the `ARKit`. Once done, one crosshair will show up in the center of the screen. Then, please use the front sight (also in the center of screen) to aim the Dragons, and tap the screen to kill them!
 
 #### Notice
 
 * When the game starts, keep your iPad at the same height as your head to find the target.
 * It is better to run the game in a **landscape** mode.
 * For better game experience play game in **landscape full screen** mode.
 * Your bullets are shoote from **center of the screen**.
 
 */

// Total number of dragons you have to fight
var totalDragons = 10

// Increase this number if you want dragons to spawn less often
var spawnFreq = 120

// Increase this number if you want dragons to shoot less often
var shotFreq = 90

//#-hidden-code

import PlaygroundSupport
import UIKit

let viewController = GameViewController()
viewController.game.spawnFreq = spawnFreq
viewController.game.totalDragons = totalDragons
viewController.game.shotFreq = shotFreq

// Present the ViewController
PlaygroundPage.current.liveView = viewController

// Tells the Playground needsIndefiniteExecution
PlaygroundPage.current.needsIndefiniteExecution = true

//#-end-hidden-code

