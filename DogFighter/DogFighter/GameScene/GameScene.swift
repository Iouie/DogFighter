//
//  GameScene.swift
//  DogFighter
//
//  Created by Stanley Louie on 4/15/19.
//  Copyright © 2019 Stanley Louie. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Properties -
    var player:SKSpriteNode!
    var weapon:SKSpriteNode!
    var gameTimer:Timer!
    var possibleAliens = ["alien", "alien2", "alien3"]
    var backgroundImage:SKSpriteNode!
    var scoreLabel:SKLabelNode!
    var score:Int = 0{
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    let bulletCategory:UInt32 = 1 << 0
    let enemyCategory:UInt32 = 1 << 1   // use for collision
    
    var livesArray:[SKSpriteNode]!
    
    override func didMove(to view: SKView) {
        
        addLives()
        
        player = SKSpriteNode(imageNamed: "plane")
        
        
        player.position = CGPoint(x: player.size.width / 2,  y: player.size.height / 2 ) // set plane in middle
        
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)  // no gravity
        
        self.physicsWorld.contactDelegate = self // need this in order for collision methods to work
                // create score label node
        scoreLabel = SKLabelNode(text: "Score: 0")
        
        // set a fixed position
        scoreLabel.position = CGPoint(x: -85, y: 300)
        scoreLabel.zPosition = 1
        scoreLabel.fontName = "Copperplate-Bold"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor =  UIColor.black
        score = 0
        
        self.addChild(scoreLabel)
        
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(addEnemy), userInfo: nil, repeats: true) // allows to summon enemies
        
        createSky()   // creates sky
        
        // changing difficulty drecrease the time interval
        if UserDefaults.standard.bool(forKey: "hard"){
            gameTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(addEnemy), userInfo: nil, repeats: true) // allows to summon enemies
        }
        if UserDefaults.standard.bool(forKey: "hell"){
            gameTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(addEnemy), userInfo: nil, repeats: true) // allows to summon enemies
        }
        
        // play music
     //   self.run(SKAction.playSoundFileNamed("gamescenemusic.mp3", waitForCompletion: true))
    }
    
    
    // MARK: - Helpers -
    
    func shootBullet(){
        let bullet = SKSpriteNode(imageNamed: "torpedo")
        bullet.position = player.position  // bullet position currently in plane
        bullet.position.y += 40  // increment by 40 every time
        
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 5)
        bullet.physicsBody?.isDynamic = true
        
        bullet.physicsBody?.categoryBitMask = bulletCategory  // used to detect collision
        bullet.physicsBody?.contactTestBitMask = enemyCategory
        bullet.physicsBody?.collisionBitMask = enemyCategory
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(bullet)
        
        // action of shooting bullet
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height + 20), duration: 0.8))
        actionArray.append(SKAction.removeFromParent())
        
        bullet.run(SKAction.sequence(actionArray))
    }
    
    @objc func addEnemy(){
        possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [String] // gets random alien array
        
        let enemy = SKSpriteNode(imageNamed: possibleAliens[0]) // initialize the enemy to one of random
        
        let randomEnemyPosition = GKRandomDistribution(lowestValue: -200, highestValue: 380)   // lets enemies spawn in random x position
        let position = CGFloat(randomEnemyPosition.nextInt()) // convert to float
        enemy.position = CGPoint(x: position, y: self.frame.size.height + enemy.size.height) // spawn the enemy
        
        // collision stuff
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.isDynamic = true
        
        enemy.physicsBody?.categoryBitMask = enemyCategory
        enemy.physicsBody?.contactTestBitMask = bulletCategory
        enemy.physicsBody?.collisionBitMask = bulletCategory
        enemy.physicsBody?.collisionBitMask = 0
        
        self.addChild(enemy)
        
        
        // action array that allows enemy to move from top to bottom
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -enemy.size.height * 9), duration: 4))
        
        actionArray.append(SKAction.run{
            
            self.run(SKAction.playSoundFileNamed("damaged.mp3", waitForCompletion: false))
            if self.livesArray.count > 0{  // lose health
                let liveNode = self.livesArray.first
                liveNode!.removeFromParent()
                self.livesArray.removeFirst()
                
                if self.livesArray.count == 0{   // if health is 0
                    let transition = SKTransition.flipHorizontal(withDuration: 0.5) // create transition
                    let gameOver = SKScene(fileNamed: "GameOverScene") as! GameOverScene
                    gameOver.score = self.score   // gets the score and puts it on gameOver scene score
                    self.view?.presentScene(gameOver, transition: transition) // transition to it
                }
            }
        })
        actionArray.append(SKAction.removeFromParent())
        
        enemy.run(SKAction.sequence(actionArray))
    }
    
    // collision method
    func didBegin(_ contact: SKPhysicsContact) {
                var firstBody:SKPhysicsBody
                var secondBody:SKPhysicsBody
        
                if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
                    firstBody = contact.bodyA
                    secondBody = contact.bodyB
                }else{
                    firstBody = contact.bodyB
                    secondBody = contact.bodyA
                }
        
        // collision with bullet and enemy
                if (firstBody.categoryBitMask == bulletCategory) && (secondBody.categoryBitMask == enemyCategory)
                {
                    bulletCollisionEnemy(bulletNode: firstBody.node as! SKSpriteNode, enemyNode: secondBody.node as! SKSpriteNode)
                }
    }
    
    // collision between bullet and enemy plane
    func bulletCollisionEnemy(bulletNode: SKSpriteNode, enemyNode: SKSpriteNode){
        let explosion = SKEmitterNode(fileNamed: "Explosion")!  // initialize explosion image
        explosion.position = enemyNode.position   // explodes position wherever the plane is destroyed
        self.addChild(explosion)
        
        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))  // runs the sound file
        
        // remove from screen to stop lag
        bulletNode.removeFromParent()
        enemyNode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)){
            explosion.removeFromParent()
        }
        score += 100
    }
    
    
    func addLives(){
        livesArray = [SKSpriteNode]()
        
        for life in 1 ... 3{   // get lives 3
            let lifeNode = SKSpriteNode(imageNamed: "plane") // initialize lives
            lifeNode.position = CGPoint(x: (30 + (45 * life)), y: 310)// show lives on top right
            lifeNode.zPosition = 1
            self.addChild(lifeNode)
            livesArray.append(lifeNode)
        }
    }
    
    
    // MARK: - Screen Touch -
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let location = touch.location(in: self)   // get location based on where your finger touched and store in location
            player.position.x = location.x      // location of x and y of plane is wherever you pointed to
            player.position.y = location.y
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        shootBullet()
    }
    
    // MARK: - Background -
    func createSky(){
        let skyPic = SKTexture(imageNamed: "skyBG")
        
        // creates 2 of same images
        for i in 0 ... 1{
            let skyBG = SKSpriteNode(texture: skyPic)
            skyBG.zPosition = -1
            skyBG.scale(to: CGSize(width: 2000, height: 2500 * i))
            skyBG.position = CGPoint(x: 0, y: skyPic.size().height)
            addChild(skyBG)
            
            let moveBottom = SKAction.moveBy(x: 0, y: -skyPic.size().height, duration: 15)
            let moveReset = SKAction.moveBy(x: 0, y: skyPic.size().height, duration: 0)
            let moveLoop = SKAction.sequence([moveBottom, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            
            skyBG.run(moveForever)
        }
    }
}
