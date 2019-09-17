//
//  GameOverScene.swift
//  DogFighter
//
//  Created by Stanley Louie on 5/2/19.
//  Copyright © 2019 Stanley Louie. All rights reserved.
//

import UIKit
import SpriteKit

class GameOverScene: SKScene {
    
    // MARK: - Ivars -
    var score:Int = 0
    var scoreLabel:SKLabelNode!
    var newGameButtonNode:SKSpriteNode!
    var highscoreLabel:SKLabelNode!
    
    var highScore = UserDefaults().integer(forKey: "HIGHSCORE")
    
    override func didMove(to view: SKView) {
        scoreLabel = self.childNode(withName: "scoreLabel") as? SKLabelNode // intialize labels
        scoreLabel.text = "\(score)"
        highscoreLabel = self.childNode(withName: "highscoreLabel") as? SKLabelNode
        
        
        // if current score is greater than highscore, set that score to hs
        if score > UserDefaults().integer(forKey: "HIGHSCORE") {
            saveHighScore()
        }
        
        highscoreLabel.text = "\(highScore)"
        
        
        
        newGameButtonNode = self.childNode(withName: "newGameButton") as? SKSpriteNode
        newGameButtonNode.texture = SKTexture(imageNamed: "newGameButton")
    }
    
    // MARK: - Touch Screen -
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self){     // get location of where you tap on screen
            let node = self.nodes(at: location)
            
            if node[0].name == "newGameButton"{   // user taps on new game button
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameScene = SKScene(fileNamed: "MenuScene") as! MenuScene
                self.view!.presentScene(gameScene, transition: transition)   // uses the transition and transitions to gamescene
            }
        }
    }
    
    // MARK: - USER DEFAULTS - 
    func saveHighScore() {
        UserDefaults.standard.set(score, forKey: "HIGHSCORE")
    }
}
