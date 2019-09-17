//
//  MenuScene.swift
//  DogFighter
//
//  Created by Stanley Louie on 5/1/19.
//  Copyright © 2019 Stanley Louie. All rights reserved.
//

import UIKit
import SpriteKit

class MenuScene: SKScene {
    
    // MARK: - IVARS -
    var newGameButtonNode: SKSpriteNode!
    var difficultyButtonNode: SKSpriteNode!
    var difficultyLabelNode: SKLabelNode!
    var action: SKAction!
    
    override func didMove(to view: SKView) {
        
        createSky()
        
        newGameButtonNode = self.childNode(withName: "newGameButton") as? SKSpriteNode        // initialize stuff
        difficultyButtonNode = self.childNode(withName: "difficultyButton") as? SKSpriteNode
        
        difficultyButtonNode.texture = SKTexture(imageNamed: "difficultyButton")
        
        difficultyLabelNode = (self.childNode(withName: "difficultyLabel") as! SKLabelNode)
        
        let userDefaults = UserDefaults.standard   // gets user defaults
        
        if userDefaults.bool(forKey: "hard"){      // move keys
            difficultyLabelNode.text = "Hard"
        }else if userDefaults.bool(forKey: "easy"){
            difficultyLabelNode.text = "Easy"
        }
        else if userDefaults.bool(forKey: "hell"){
            difficultyLabelNode.text = "Hell"
        }
        
        // music
        action = SKAction.playSoundFileNamed("menumusic.mp3", waitForCompletion: true) // store in variable so i can make it stop
        
            self.run(action, withKey:"menusound") // create a key for this song
    }
    
    // MARK: - Touch Pad -
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self){    // gets tapping location
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "newGameButton"{   // if user taps on new game
                let transition = SKTransition.flipVertical(withDuration: 1)
                let gameScene = SKScene(fileNamed: "GameScene") as! GameScene
                self.view?.presentScene(gameScene, transition: transition)
            } else if nodesArray.first?.name == "difficultyButton"{  // if user taps difficulty, call changedifficulty
                changeDifficulty()
            }
        }
    }
    
    func createSky(){
        let skyPic = SKTexture(imageNamed: "skyBG")
        
        // creates 2 of same images
        for i in 0 ... 1{
            let skyBG = SKSpriteNode(texture: skyPic)
            skyBG.zPosition = -30
            skyBG.anchorPoint = CGPoint(x: 0, y: 0)
            skyBG.scale(to: CGSize(width: 2000, height: 1500 * i))
            skyBG.position = CGPoint(x: -400, y: (skyPic.size().height))
            addChild(skyBG)
            
            let moveBottom = SKAction.moveBy(x: 0, y: -skyPic.size().height, duration: 60)
            let moveReset = SKAction.moveBy(x: 0, y: skyPic.size().height, duration: 0)
            let moveLoop = SKAction.sequence([moveBottom, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            
            skyBG.run(moveForever)
        }
    }
    
    // MARK: - Helpers -
    func changeDifficulty(){
        let userDefaults = UserDefaults.standard
        
        // changes label text
        if difficultyLabelNode.text == "Easy"{
            difficultyLabelNode.text = "Hard"
            userDefaults.set(true, forKey: "hard")
            userDefaults.set(false, forKey: "easy")
            userDefaults.set(false, forKey: "hell")
        }
        else if difficultyLabelNode.text == "Hard"
        {
            difficultyLabelNode.text = "Hell"
            userDefaults.set(false, forKey:"hard")
            userDefaults.set(true, forKey:"hell")
            userDefaults.set(false, forKey:"easy")
        }
        else if difficultyLabelNode.text == "Hell"{
            difficultyLabelNode.text = "Easy"
            userDefaults.set(false, forKey:"hard")
            userDefaults.set(false, forKey:"hell")
            userDefaults.set(true, forKey:"easy")
            
        }
        userDefaults.synchronize() // save userDefaults
    }
}
