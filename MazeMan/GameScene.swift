//
//  GameScene.swift
//  MazeMan
//
//  Created by Wes Bosman on 4/2/17.
//  Copyright © 2017 Wes Bosman. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene:
    SKScene,
    SKPhysicsContactDelegate{
    
    // Enum properties for different textures
    enum PhysicsCategory : UInt32 {
        case hero   = 1
        case heart  = 2
        case energy = 4
        case star   = 8
        case food   = 16
        case block  = 32
        case border = 64
        case fire   = 128
        case dino1  = 256
        case dino2  = 512
        case dino3  = 1024
        case rock   = 2048
    }
    
    // Textures
    let heroLeftTexture  = SKTexture(image: UIImage(named: "CaveManLeft")!)
    let heroRightTexture = SKTexture(image: UIImage(named: "CaveManRight")!)
    let dinoTwoLeftTexture    = SKTexture(image: UIImage(named: "Dino2Left")!)
    let dinoTwoRightTexture   = SKTexture(image: UIImage(named: "Dino2Right")!)
    let dinoThreeUpTexture    = SKTexture(image: UIImage(named: "Dino3Up")!)
    let dinoThreeDownTexture  = SKTexture(image: UIImage(named: "Dino3Down")!)
    let dinoThreeLeftTexture  = SKTexture(image: UIImage(named: "Dino3Left")!)
    let dinoThreeRightTexture = SKTexture(image: UIImage(named: "Dino3Right")!)
    
    // Nodes
    let food: SKSpriteNode        = SKSpriteNode(imageNamed: "Food")
    let star: SKSpriteNode        = SKSpriteNode(imageNamed: "Star")
    var background: SKSpriteNode  = SKSpriteNode(imageNamed: "Background")
    var hero: SKSpriteNode        = SKSpriteNode(imageNamed: "CaveManRight")
    var water: SKSpriteNode           = SKSpriteNode(imageNamed: "Water")
    var gameStatus: SKSpriteNode      = SKSpriteNode(imageNamed: "GameStatus")
    var heart: SKSpriteNode           = SKSpriteNode(imageNamed: "Heart")
    var battery: SKSpriteNode         = SKSpriteNode(imageNamed: "Battery")
    var dinoOne: SKSpriteNode         = SKSpriteNode(imageNamed: "Dino1")
    var dinoTwo: SKSpriteNode         = SKSpriteNode(imageNamed: "Dino2Left")
    var dinoThree: SKSpriteNode       = SKSpriteNode(imageNamed: "Dino3Left")
    var boss: SKSpriteNode            = SKSpriteNode(imageNamed: "Dino4")
    var oldDirection: String = String()
    
    var swipeLeft: UISwipeGestureRecognizer   = UISwipeGestureRecognizer()
    var swipeRight: UISwipeGestureRecognizer  = UISwipeGestureRecognizer()
    var swipeDown: UISwipeGestureRecognizer   = UISwipeGestureRecognizer()
    var swipeUp: UISwipeGestureRecognizer     = UISwipeGestureRecognizer()
    var tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    let ground            = Ground()
    let ceiling           = Ceiling()
    var facingRight: Bool = true
    let maxBlockCount     = 15
    var gameTimer         = Timer()
    var bossTimer         = Timer()
    var dinoOneTimer      = Timer()
    var rockTimer         = Timer()
    var bossFireTime      = 7
    var blocks2DArray: [[Int]]     = [[Int]]()
    var blocksTimer                = Timer()
    var points2DArray: [[CGPoint]] = [[CGPoint]]()
    var border: CGRect             = CGRect()
    var isMoving = false
    let upKey    = "upAction"
    let downKey  = "downAction"
    let rightKey = "rightAction"
    let leftKey  = "leftAction"
    var upAction    = SKAction()
    var downAction  = SKAction()
    var leftAction  = SKAction()
    var rightAction = SKAction()
    var starColumn:  Int  = 0
    var starRow:     Int  = 0
    var foodColumn:  Int  = 0
    var foodRow:     Int  = 0
    var dinoOneWait: Int = 0
    var foundStar:   Bool = false
    var foundFood:   Bool = false
    var hitByFire:   Bool = false
    var movingUp:    Bool = false
    var movingDown:  Bool = false
    var movingLeft:  Bool = false
    var movingRight: Bool = false
    var audioPlayer = AVAudioPlayer()
    var dino2FacingRight = false
    var dino3FacingRight = false
    var dino3FacingUp    = false
    
    override func didMove(to view: SKView) {
        print("Did Move")
        
        self.physicsWorld.contactDelegate = self
        setUpBackgroundImage()
        createPhysicsBorder()
        addGround()
        addCeiling()
        create2DArray()
        createRandomBlocks()
        addStar()
        addFood()
        addDinoOne()
        addDinoTwo()
        addDinoThree()
        addBoss()
        startGameTimer()
        startRockTimer()

        // Set up the hero
        hero.texture = heroRightTexture
        hero.zPosition = 1
        hero.size = CGSize(width: 64, height: 64)
        hero.position = CGPoint(x: 32, y: 100)
        hero.physicsBody = SKPhysicsBody(rectangleOf: hero.size)
        hero.physicsBody?.usesPreciseCollisionDetection = true
        hero.physicsBody?.affectedByGravity = false
        hero.physicsBody?.categoryBitMask = PhysicsCategory.hero.rawValue
        hero.physicsBody?.allowsRotation = false
        hero.physicsBody?.friction = 0
        hero.physicsBody?.restitution = 0
        
        // Hero can Contact food and star
        hero.physicsBody?.contactTestBitMask = PhysicsCategory.food.rawValue
            | PhysicsCategory.star.rawValue
            | PhysicsCategory.dino1.rawValue
            | PhysicsCategory.dino2.rawValue
            | PhysicsCategory.dino3.rawValue
            | PhysicsCategory.fire.rawValue
            | PhysicsCategory.block.rawValue
        
        hero.physicsBody?.collisionBitMask = PhysicsCategory.block.rawValue
            | PhysicsCategory.border.rawValue
        
        hero.physicsBody?.isDynamic = true
        
        self.addChild(hero)
        
        // Set swipe directions
        swipeLeft.direction = .left
        swipeRight.direction = .right
        swipeUp.direction = .up
        swipeDown.direction = .down
        
        // Add targets to swipe gestures
        swipeLeft.addTarget(self, action: #selector(swipeDir))
        swipeRight.addTarget(self, action: #selector(swipeDir))
        swipeUp.addTarget(self, action: #selector(swipeDir))
        swipeDown.addTarget(self, action: #selector(swipeDir))
        tapRecognizer.addTarget(self, action: #selector(tappedScreen))
        
        // Add gesture recognizers to the view
        self.view?.addGestureRecognizer(swipeLeft)
        self.view?.addGestureRecognizer(swipeRight)
        self.view?.addGestureRecognizer(swipeUp)
        self.view?.addGestureRecognizer(swipeDown)
        self.view?.addGestureRecognizer(tapRecognizer)
    }
    
    func setUpBackgroundImage(){
        print("Set up background image")
        background.size = (self.view?.frame.size)!
        background.position = CGPoint(x: (self.view?.frame.midX)!,
                                      y: (self.view?.frame.midY)!)
        background.zPosition = 0
        self.addChild(background)
    }
    
    // MARK - Play Sounds
    
    func playSound(soundName: String){
        if let sound = NSDataAsset(name: soundName){
            do{
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(true)
                
                audioPlayer = try AVAudioPlayer(data: sound.data, fileTypeHint: AVFileTypeMPEGLayer3)
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            } catch let error as NSError {
                print("error: \(error.localizedDescription)")
            }
        }

    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        print("Did begin contact")
        let aMask = contact.bodyA.categoryBitMask
        let bMask = contact.bodyB.categoryBitMask
        print("Contact Body A: \(aMask)")
        print("Contact Body B: \(bMask)")
        
        if (   aMask == PhysicsCategory.hero.rawValue
            && bMask == PhysicsCategory.food.rawValue)
            ||
            (  aMask == PhysicsCategory.food.rawValue
            && bMask == PhysicsCategory.hero.rawValue) {
            
            print("Hero touched the food")
            
            // Remove the food 
            food.removeFromParent()
            
            // Play Eating sound
            playSound(soundName: "EatingSound")
            
            // Update game label
            self.ceiling.gameLabelNode.text = "Mazeman found food! +50 health"
            
            
            // Found food
            foundFood = true
            
            // Update the hero's life 
            ground.increaseEnergyLabel()
            
            // Change the item in the 2d array back to zero
            self.blocks2DArray[foodRow][foodColumn] = 0
            
            // Add new food element
            self.addFood()
        }
        
        if (aMask == PhysicsCategory.hero.rawValue
            &&   bMask == PhysicsCategory.star.rawValue)
            ||
            (    aMask == PhysicsCategory.star.rawValue
            &&   bMask == PhysicsCategory.hero.rawValue){
            
            print("Hero touched the star")
            
            // Remove the star
            star.removeFromParent()
            
            // Play Success Sound
            playSound(soundName: "SuccessSound")
            
            // Update game label
            self.ceiling.gameLabelNode.text = "Mazeman found a star! +1 star"
            
            // Found star
            foundStar = true
            
            // Update the number of stars
            ground.increaseStarCount()
            
            // Change the item in the 2d array back to zero
            self.blocks2DArray[starRow][starColumn] = 0
            
            // Add new star
            self.addStar()
            
        }
        
        if (aMask == PhysicsCategory.block.rawValue
            &&   bMask == PhysicsCategory.hero.rawValue)
            ||
            (    aMask == PhysicsCategory.hero.rawValue
            &&   bMask == PhysicsCategory.block.rawValue){
            
            print("Hero touched a block")
            
            // Stop the heros current actions
            hero.removeAllActions()
            
        }
        
        if (aMask == PhysicsCategory.block.rawValue
            &&   bMask == PhysicsCategory.dino3.rawValue)
            ||
            (    aMask == PhysicsCategory.dino3.rawValue
                &&   bMask == PhysicsCategory.block.rawValue){
            
            print("Dino 3 touched a block")
            
            // Stop the heros current actions
            self.dinoThree.removeAllActions()
            
            moveDinoThree()
            
        }
        
        if (aMask == PhysicsCategory.border.rawValue
            &&   bMask == PhysicsCategory.dino3.rawValue)
            ||
            (    aMask == PhysicsCategory.dino3.rawValue
                &&   bMask == PhysicsCategory.border.rawValue){
            
            print("Dino 3 touched the border")
            
            // Stop the heros current actions
            self.dinoThree.removeAllActions()
            
            moveDinoThree()
            
        }
        
        
        if (aMask == PhysicsCategory.fire.rawValue
            &&   bMask == PhysicsCategory.hero.rawValue)
            ||
            (    aMask == PhysicsCategory.hero.rawValue
            &&   bMask == PhysicsCategory.fire.rawValue){
            
            print("Hero touched fire")
            
            // Play enemy hit sound
            playSound(soundName: "EnemyHitSound")
            
            hitByFire = true
            
            // Update game label
            self.ceiling.gameLabelNode.text = "Mazeman hit by fire! -100"
            
            ground.hitByFire()
        }
        
        // Player contacting dinosaurs
        
        if (aMask == PhysicsCategory.hero.rawValue
            && bMask == PhysicsCategory.dino1.rawValue)
            || (aMask == PhysicsCategory.dino1.rawValue
            && bMask == PhysicsCategory.hero.rawValue){
            
            print("Hero Touched Dino 1")
            
            // Subtract health
            ground.hitByDinoOne()
            
            // Play enemy hit sound
            playSound(soundName: "EnemyHitSound")
            
            // Update the game label 
            ceiling.gameLabelNode.text = "MazeMan got bit by Dino 1! -60"
            
        }
        
        if (aMask == PhysicsCategory.hero.rawValue
            && bMask == PhysicsCategory.dino2.rawValue)
            || (aMask == PhysicsCategory.dino2.rawValue
                && bMask == PhysicsCategory.hero.rawValue){
            
            print("MazeMan touched dino 2")
            
            // Subtract Health
            ground.hitByDinoTwo()
            
            // Play enemy hit sound
            playSound(soundName: "EnemyHitSound")
            
            // Update game label
            ceiling.gameLabelNode.text = "MazeMan got bit by Dino 2! -80"
        }
        
        if (aMask == PhysicsCategory.hero.rawValue
            && bMask == PhysicsCategory.dino3.rawValue)
            || (aMask == PhysicsCategory.dino3.rawValue
                && bMask == PhysicsCategory.hero.rawValue){
            
            print("MazeMan touched dino 3")
            
            // Subtract Health
            ground.hitByDinoThree()
            
            // Play enemy hit sound
            playSound(soundName: "EnemyHitSound")
            
            // Update game label
            ceiling.gameLabelNode.text = "MazeMan got bit by Dino 3! -100"
        }
        
        // Rock contacting dinosaurs
        
        if (aMask == PhysicsCategory.rock.rawValue
            && bMask == PhysicsCategory.dino1.rawValue)
            || (aMask == PhysicsCategory.dino1.rawValue
                && bMask == PhysicsCategory.rock.rawValue){
            
            print("MazeMan's rock hit dino 1")
            
            // Play rock hit enemy sound
            playSound(soundName: "RockHitEnemy")
            
            // Remove the dinosaur from the scene
            dinoOne.removeFromParent()
            
            // Update game label
            ceiling.gameLabelNode.text = "MazeMan defeated Dino 1!"
            
            // Add a new dino one
            addDinoOne()
            
        }
        
        if (aMask == PhysicsCategory.rock.rawValue
            && bMask == PhysicsCategory.dino2.rawValue)
            || (aMask == PhysicsCategory.dino2.rawValue
                && bMask == PhysicsCategory.rock.rawValue){
            
            print("MazeMan's rock hit dino 2")
            
            // Play rock hit enemy sound
            playSound(soundName: "RockHitEnemy")
            
            // Remove Dino 2
            dinoTwo.removeFromParent()
                    
            // Update game label node
            ceiling.gameLabelNode.text = "MazeMan defeated Dino 2!"
            
            addDinoTwo()
        }
        
        if (aMask == PhysicsCategory.rock.rawValue
            && bMask == PhysicsCategory.dino3.rawValue)
            || (aMask == PhysicsCategory.dino3.rawValue
                && bMask == PhysicsCategory.rock.rawValue){
            
            print("MazeMan's rock hit dino 3")
            
            // Play rock hit enemy sound
            playSound(soundName: "RockHitEnemy")
            
            // Remove Dino 3
            dinoThree.removeFromParent()
            
            // Update game label node
            ceiling.gameLabelNode.text = "MazeMan defeated Dino 3!"
            
            addDinoThree()
        }
        
        // Dinosaurs eating food
        
        if (aMask == PhysicsCategory.dino1.rawValue
            &&   bMask == PhysicsCategory.food.rawValue)
            ||
            (    aMask == PhysicsCategory.food.rawValue
                &&   bMask == PhysicsCategory.dino1.rawValue){
            
            print("Dino 1 is hungry")
            
            // Play Eating Sound
            playSound(soundName: "EatingSound")
            
            // Update game label 
            ceiling.gameLabelNode.text = "Dino 1 was hungry!"
            
            // remove food
            food.removeFromParent()
            
            // Add food
            addFood()
            
        }
        
        if (aMask == PhysicsCategory.dino2.rawValue
            &&   bMask == PhysicsCategory.food.rawValue)
            ||
            (    aMask == PhysicsCategory.food.rawValue
                &&   bMask == PhysicsCategory.dino2.rawValue){
            
            print("Dino 2 is hungry")
            
            // Play Eating Sound
            playSound(soundName: "EatingSound")
            
            // Update game label
            ceiling.gameLabelNode.text = "Dino 2 was hungry!"
            
            // remove food
            food.removeFromParent()
            
            // Add food
            addFood()
            
        }
        
        if (aMask == PhysicsCategory.dino3.rawValue
            &&   bMask == PhysicsCategory.food.rawValue)
            ||
            (    aMask == PhysicsCategory.food.rawValue
                &&   bMask == PhysicsCategory.dino3.rawValue){
            
            print("Dino 1 is hungry")
            
            // Play Eating Sound
            playSound(soundName: "EatingSound")
            
            // Update game label
            ceiling.gameLabelNode.text = "Dino 3 was hungry!"
            
            // remove food
            food.removeFromParent()
            
            // Add food
            addFood()
            
        }
        
        

        
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        print("Did end contact")
        
    }
    
    func startRockTimer(){
        // Start the rock timer
        rockTimer = Timer.scheduledTimer(withTimeInterval: 30,
                                         repeats: true,
                                         block: { Void in
            // Add 10 new rocks
            self.ground.addTenRocks()
        })
    }
    
    func startGameTimer(){
        // Start the game timer
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1,
                                         repeats: true,
                                         block: { Void in
            // start decreasing the energy label
            self.ground.decreaseEnergyLabel()
                                            
            // Check to see if the game is over
            if self.ground.gameOver == true{
                self.ceiling.gameLabelNode.text = "Game Over!"
                
                // Play Game Over Sound
                self.playSound(soundName: "GameOverSound")
                
                // Remove all actions
                self.hero.removeAllActions()
                self.dinoOne.removeAllActions()
                self.dinoTwo.removeAllActions()
                self.dinoThree.removeAllActions()
                self.boss.removeAllActions()
                
                // Invalidate timers
                self.bossTimer.invalidate()
                self.gameTimer.invalidate()
                self.blocksTimer.invalidate()
                self.dinoOneTimer.invalidate()
                
                // Go to the main screen and take the star count as a highscore
                let transition = SKTransition.reveal(with: .down, duration: 2.0)
                let mainScene  = MainScreen(size: (self.scene?.size)!)
                mainScene.currentScore = self.ground.starCount
                HighScores.highScoreArray.append(self.ground.starCount)
                mainScene.scaleMode = .aspectFill
                self.scene?.view?.presentScene(mainScene, transition: transition)
            }
                                            
            if self.foundStar == true{
                self.foundStar = false
            }
            
            if self.foundFood == true{
                self.foundFood = false
            }
            
            if self.hitByFire == true{
                self.hitByFire = false
            }
        })
    }
    
    // MARK - Gesture Recognizer methods
    
    // Throw a rock and decrease the number of rocks
    
    func tappedScreen(sender: UITapGestureRecognizer){
        print("User Tapped The Screen")
        print("Get the location and throw a rock")
        // Scene has a different coordinate system than view
        var location = sender.location(in: self.view)
        location = self.convertPoint(fromView: location)
        let size = CGSize(width: 64, height: 64)
        
        print("Location tapped x:\(location.x) , y:\(location.y)")
        
        //let vector = CGVector(dx: location.x, dy: location.y)
        //let moveVector = SKAction.move(by: vector, duration: 1)
        let moveAction = SKAction.move(to: location, duration: 1)
        
        if ground.rockCount > 0{
            print("Throwing rock")
            
            // Play rock throwing sound
            playSound(soundName: "ThrowingRock")
            
            if facingRight{
                let rock: SKSpriteNode    = SKSpriteNode(imageNamed: "Rock")
                rock.position = hero.position
                rock.size = size
                rock.zPosition = 3
                rock.physicsBody = SKPhysicsBody(rectangleOf: size)
                rock.physicsBody?.categoryBitMask = PhysicsCategory.rock.rawValue
                rock.physicsBody?.contactTestBitMask = PhysicsCategory.dino1.rawValue
                    | PhysicsCategory.dino2.rawValue
                    | PhysicsCategory.dino3.rawValue
                rock.physicsBody?.collisionBitMask = 0
                rock.physicsBody?.affectedByGravity = false
                self.addChild(rock)
                rock.run(moveAction, completion: { Void in
                    rock.removeFromParent()
                })
            }
            else{
                let rock: SKSpriteNode    = SKSpriteNode(imageNamed: "Rock")
                rock.position = hero.position
                rock.size = size
                rock.zPosition = 3
                rock.physicsBody = SKPhysicsBody(rectangleOf: size)
                rock.physicsBody?.categoryBitMask = PhysicsCategory.rock.rawValue
                rock.physicsBody?.contactTestBitMask = PhysicsCategory.dino1.rawValue
                    | PhysicsCategory.dino2.rawValue
                    | PhysicsCategory.dino3.rawValue
                rock.physicsBody?.collisionBitMask = 0
                rock.physicsBody?.affectedByGravity = false
                self.addChild(rock)
                rock.run(moveAction, completion: { Void in
                    rock.removeFromParent()
                })
            }
            
            // Decrement the rock counter label
            ground.decreaseRockLabel()
        }
        else{
            print("No More Rocks To Throw!")
        }
        
    }
    
    func setDirection(direction: String){
        switch(direction){
        case "Up":
            movingUp    = true
            movingLeft  = false
            movingRight = false
            movingDown  = false
        case "Down":
            movingUp    = false
            movingLeft  = false
            movingRight = false
            movingDown  = true
        case "Left":
            movingUp    = false
            movingLeft  = true
            movingRight = false
            movingDown  = false
        case "Right":
            movingUp    = false
            movingLeft  = false
            movingRight = true
            movingDown  = false
        default:
            break
        }
    }
    
    // Determine the direction of the swipe gesture and move the player
    
    func swipeDir(sender: UISwipeGestureRecognizer){
        if sender.direction == .up{
            print("Swiping Up")
            if facingRight{
                let upPoint = CGPoint(x: hero.position.x,
                                      y: border.maxY - 98)
                upAction = SKAction.move(to: upPoint,
                                         duration: 6)
                
                hero.run(upAction, withKey: upKey)
                
            }
            else{
                let upPoint = CGPoint(x: hero.position.x,
                                      y: border.maxY - 98)
                upAction = SKAction.move(to: upPoint,
                                         duration: 6)
                hero.run(upAction, withKey: upKey)
            }
            
            // Set the movement direction
            setDirection(direction: "Up")
        }
        else if sender.direction == .down{
            print("Swiping Down")
            if facingRight{
                let downPoint = CGPoint(x: hero.position.x,
                                        y: border.minY + 32)
                downAction = SKAction.move(to: downPoint,
                                           duration: 6)
                hero.run(downAction, withKey: downKey)
            }
            else{
                let downPoint = CGPoint(x: hero.position.x, y: border.minY + 32)
                downAction = SKAction.move(to: downPoint,
                                           duration: 6)
                hero.run(downAction, withKey: downKey)
            }
            
            // Set the movement direction
            setDirection(direction: "Down")
        }
        else if sender.direction == .left{
            print("Swiping Left")
            if facingRight{
                faceLeft()
                moveLeft()
                hero.texture = heroLeftTexture
            }
            else{
                hero.texture = heroLeftTexture
                moveLeft()
            }
        }
        else if sender.direction == .right{
            print("Swiping Right")
            if !facingRight{
                hero.texture = heroRightTexture
                faceRight()
                moveRight()
            }
            else{
                hero.texture = heroRightTexture
                moveRight()
            }
        }
    }
    
    func stopHeroMovement(facingDirection: String){
        if facingDirection == "Right"{
            if hero.physicsBody?.isResting == false{
                hero.removeAllActions()
            }
        }
        else{
            if hero.physicsBody?.isResting == false{
                hero.removeAllActions()
            }
        }
    }
    
    // Make the hero face right
    func faceRight(){
        print("Face Right")
        hero.texture = heroRightTexture
        facingRight = true
    }
    
    // Make the hero move right
    func moveRight(){
        print("Move Right")
        hero.texture = heroRightTexture
        let rightPoint = CGPoint(x: border.maxX - 32, y: hero.position.y)
        rightAction = SKAction.move(to: rightPoint,
                                    duration: 6)
        hero.run(rightAction, withKey: rightKey)
    }
    
    // Make the hero face left
    func faceLeft(){
        print("Face Left")
        hero.texture = heroLeftTexture
        facingRight  = false
    }
    
    // Make the hero move left
    func moveLeft(){
        print("Move Left")
        hero.texture = heroLeftTexture
        let leftPoint = CGPoint(x: border.minX + 32, y: hero.position.y)
        leftAction = SKAction.move(to: leftPoint,
                                   duration: 6)
        hero.run(leftAction, withKey: leftKey)
    }
    
    // Add Boss
    func addBoss(){
        let startPoint = CGPoint(x: 32,
                                 y: 645)

        boss.position  = startPoint
        boss.zPosition = 5
        boss.size = CGSize(width: 64, height: 64)
        self.addChild(boss)
        
        let endPoint = CGPoint(x: 1000,
                               y: 645)
        
        let moveLeft  = SKAction.move(to: endPoint, duration: 5)
        let moveRight = SKAction.move(to: startPoint, duration: 5)
        let action = SKAction.sequence([moveLeft, moveRight])
        
        let bossAction = SKAction.repeatForever(action)
        boss.run(bossAction)
        
        bossTimer = Timer.scheduledTimer(withTimeInterval: Double(self.bossFireTime), repeats: true, block: { Void in
            // Create a fireball and fire it
            print("Create a fireball")
            
            // Change the boss fire time
            self.bossFireTime = self.generateRandomInt(min: 5, max: 11)
            
            
            let fire = SKSpriteNode(imageNamed: "Fire")
            
            self.addChild(fire)
            let size = CGSize(width: 64, height: 64)
            fire.position  = self.boss.position
            fire.size      = size
            fire.zPosition = 4
            fire.physicsBody = SKPhysicsBody(circleOfRadius: 10)
            fire.physicsBody?.categoryBitMask = PhysicsCategory.fire.rawValue
            fire.physicsBody?.contactTestBitMask = PhysicsCategory.hero.rawValue
            fire.physicsBody?.affectedByGravity = false
            fire.physicsBody?.collisionBitMask = 0
            let endPoint = CGPoint(x: self.boss.position.x, y: -64)
            let moveFireballAction = SKAction.move(to: endPoint,
                                                   duration: 5)
            moveFireballAction.speed = 2
            
            // Run the action then remove the fireball
            fire.run(moveFireballAction,
                     completion: {action in
                        
                    // Remove the fireball
                    fire.removeFromParent()
            })
        })
    }
    
    // Add Ground and player status node
    func addGround(){
        ground.position = CGPoint(x: 0, y: 64)
        ground.size = CGSize(width: self.size.width , height: 1)
        ground.zPosition = 1
        ground.createFloor()
        self.addChild(ground)
    }
    
    // Add ceiling and game status node
    func addCeiling(){
        ceiling.position = CGPoint(x: 0, y: self.size.height - 128)
        ceiling.size = CGSize(width: self.size.width, height: 128)
        ceiling.zPosition = 1
        ceiling.createCeiling()
        self.addChild(ceiling)
    }
    
    func createPhysicsBorder(){
        border = CGRect(x: 0,
                        y: 64,
                        width:  self.frame.width,
                        height: self.frame.height - 128)
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: border)
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.categoryBitMask    = PhysicsCategory.border.rawValue
        self.physicsBody?.collisionBitMask   = PhysicsCategory.hero.rawValue
            | PhysicsCategory.dino3.rawValue
        self.physicsBody?.contactTestBitMask = PhysicsCategory.dino3.rawValue
    }
    
    // Create a 2D array for placing blocks
    func create2DArray(){
        var firstPoint  = CGPoint(x: 32, y: 96)
        var pointsArray: [[CGPoint]] = []
        for _ in 0..<10{
            var points: [CGPoint] = []
            for _ in 0..<16{
                let point = CGPoint(x: firstPoint.x,
                                    y: firstPoint.y)
                points.append(point)
                firstPoint.x += 64
            }
            pointsArray.append(points)
            print("\n")
            firstPoint.x =  32
            firstPoint.y += 64
        }
        
        // Set Points 2D array
        points2DArray = pointsArray
        
        for i in pointsArray{
            print(i)
        }
    }
    
    // Create blocks at random points
    func createRandomBlocks(){
        blocks2DArray = []
        
        for i in points2DArray{
            blocks2DArray.append(Array(repeating: 0, count: i.count - 1))
        }
        
        for j in blocks2DArray{
            print(j)
        }
        
        var count = 0
        blocksTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {Void in
            count += 1
            
            let tuple      = self.getBlockPoint()
            let blockPoint = tuple.position
            let row        = tuple.row
            let column     = tuple.column
            
            // Add the block
            self.addBlock(position: blockPoint, row: row, column: column)
            
            if count == self.maxBlockCount{
                print("Invalidate the block timer")
                self.blocksTimer.invalidate()
            }
        })
    }
    
    func addBlock(position: CGPoint, row: Int, column: Int){
        print("Adding a block")
        print("at position: \(position.x) \(position.y)")
        
        let block = SKSpriteNode(imageNamed: "BlockBottom")
        block.size      = CGSize(width: 64, height: 64)
        block.position  = position
        block.zPosition = 1
        block.physicsBody = SKPhysicsBody(rectangleOf: block.size)
        block.physicsBody?.usesPreciseCollisionDetection = true
        block.physicsBody?.categoryBitMask    = PhysicsCategory.block.rawValue
        block.physicsBody?.collisionBitMask   = PhysicsCategory.hero.rawValue | PhysicsCategory.dino3.rawValue
        block.physicsBody?.contactTestBitMask = PhysicsCategory.hero.rawValue | PhysicsCategory.dino3.rawValue
        block.physicsBody?.affectedByGravity = false
        block.physicsBody?.usesPreciseCollisionDetection = true
        block.physicsBody?.isDynamic = true
        block.physicsBody?.allowsRotation = false
        block.physicsBody?.friction = 0
        block.physicsBody?.restitution = 0
        block.physicsBody?.mass = 100
        self.addChild(block)
        
        // Update the blocks a value of 1
        self.blocks2DArray[row][column] = 1
    }
    
    func getBlockPoint() -> (position: CGPoint, row: Int, column: Int){
        // Hero is at the first block
        blocks2DArray[0][0] = 3
        var row        = self.generateRandomInt(min: 0, max: 8)
        var column     = self.generateRandomInt(min: 0, max: 14)
        var blockValue = self.blocks2DArray[row][column]
        var blockPoint = self.points2DArray[row][column]
        
        // While the block position is not empty
        while(blockValue != 0){
            row        = self.generateRandomInt(min: 0, max: 8)
            column     = self.generateRandomInt(min: 0, max: 14)
            blockValue = self.blocks2DArray[row][column]
            blockPoint = self.points2DArray[row][column]
        }
        
        return(blockPoint, row, column)
    }
    
    // When it gets contacted add another one somewhere else
    func addStar(){
        let tuple = getBlockPoint()
        let position = tuple.position
        let row      = tuple.row
        let column   = tuple.column
        
        starRow    = row
        starColumn = column
        star.size = CGSize(width: 64, height: 64)
        star.position  = position
        star.zPosition = 3
        star.physicsBody = SKPhysicsBody(rectangleOf: star.size)
        star.physicsBody?.categoryBitMask = PhysicsCategory.star.rawValue
        star.physicsBody?.contactTestBitMask = PhysicsCategory.hero.rawValue
        star.physicsBody?.collisionBitMask = 0
        star.physicsBody?.affectedByGravity = false
        self.addChild(star)
        
        // Give the stars a value of 2
        self.blocks2DArray[row][column] = 2
    }
    
    func addFood(){
        let tuple = getBlockPoint()
        let position = tuple.position
        let row      = tuple.row
        let column   = tuple.column
        
        foodRow    = row
        foodColumn = column
        food.size = CGSize(width: 64, height: 64)
        food.position  = position
        food.zPosition = 3
        food.physicsBody = SKPhysicsBody(rectangleOf: food.size)
        food.physicsBody?.categoryBitMask = PhysicsCategory.food.rawValue
        food.physicsBody?.contactTestBitMask = PhysicsCategory.hero.rawValue
        food.physicsBody?.collisionBitMask = 0
        food.physicsBody?.affectedByGravity = false
        self.addChild(food)
        
        // Give the stars a value of 3
        self.blocks2DArray[row][column] = 3
    }
    
    // Add Dino One Can contact food and the player
    
    func addDinoOne(){
        let randomPoint = generateRandomInt(min: 1, max: 2)
        
        print("Random Point: \(randomPoint)")
        var position = CGPoint()
        
        if randomPoint == 1{
            position.x = ground.waterPointOne.x + 32
            position.y = ground.waterPointOne.y + 32
        }
        else if randomPoint == 2{
            position.x = ground.waterPointTwo.x + 32
            position.y = ground.waterPointTwo.y + 32
        }
        
        dinoOne.size      = CGSize(width: 64, height: 64)
        dinoOne.position  = position
        dinoOne.zPosition = 4
        dinoOne.physicsBody = SKPhysicsBody(rectangleOf: dinoOne.size)
        dinoOne.physicsBody?.categoryBitMask = PhysicsCategory.dino1.rawValue
        dinoOne.physicsBody?.contactTestBitMask = PhysicsCategory.hero.rawValue | PhysicsCategory.food.rawValue
            | PhysicsCategory.rock.rawValue
        dinoOne.physicsBody?.affectedByGravity = false
        dinoOne.physicsBody?.collisionBitMask = 0
        self.addChild(dinoOne)
        
        // Move dinoOne 
        moveDinoOne()
        
    }
    
    func moveDinoOne(){
        // Move dino1
        dinoOneWait  = self.generateRandomInt(min: 1, max: 3)
        let topPoint = CGPoint(x: self.dinoOne.position.x, y: 600)
        let action = SKAction.move(to: topPoint, duration: 5)
        let revAction = SKAction.move(to: self.dinoOne.position, duration: 5)
        let pauseAction = SKAction.wait(forDuration: Double(generateRandomInt(min: 1, max: 3)))
        let pauseActionTwo = SKAction.wait(forDuration: Double(generateRandomInt(min: 1, max: 3)))
        
        let completeAction = SKAction.sequence([pauseAction, action, pauseActionTwo, revAction])
        
        let wholeAction = SKAction.repeatForever(completeAction)
        dinoOne.run(wholeAction)
    }
    
    // Add Dino Two
    
    func addDinoTwo(){
        // Needs to face either right or left
        let randomRow     = generateRandomInt(min: 0, max: 7)
        let position      = points2DArray[randomRow][15]
        dinoTwo.size      = CGSize(width: 64, height: 64)
        dinoTwo.position  = position
        dinoTwo.zPosition = 4
        dinoTwo.physicsBody = SKPhysicsBody(rectangleOf: dinoTwo.size)
        dinoTwo.physicsBody?.categoryBitMask = PhysicsCategory.dino2.rawValue
        dinoTwo.physicsBody?.contactTestBitMask = PhysicsCategory.hero.rawValue
            | PhysicsCategory.food.rawValue
            | PhysicsCategory.rock.rawValue
        dinoTwo.physicsBody?.collisionBitMask  = 0
        dinoTwo.physicsBody?.affectedByGravity = false
        self.addChild(dinoTwo)
        
        moveDinoTwo()
    }
    
    // Move dino 2 back and forth left and right
    func moveDinoTwo(){
        let leftPosition = CGPoint(x: 32,
                                   y: dinoTwo.position.y)
        let moveLeftAction = SKAction.move(to: leftPosition,
                                           duration: 5)
        let moveRightAction = SKAction.move(to: dinoTwo.position, duration: 5)
        let waitAction = SKAction.wait(forDuration: Double(generateRandomInt(min: 1, max: 3)))
        let completeAction = SKAction.sequence([moveLeftAction, waitAction,
            SKAction.run { Void in
                print("Run Face Right Animation for Dino 2")
                // Need to create a right facing dino
                self.dinoTwo.texture = self.dinoTwoRightTexture
            }, moveRightAction, waitAction, SKAction.run {
                print("Run Face Left Animation for dino 2")
                // Need to create left facing dino
                self.dinoTwo.texture = self.dinoTwoLeftTexture
            }])
        let wholeAction = SKAction.repeatForever(completeAction)
        dinoTwo.run(wholeAction)
    }
    
    // Add Dino Three
    
    func addDinoThree(){
        // Needs to face left right up or down
        let position      = points2DArray[8][15]
        dinoThree.size      = CGSize(width: 64, height: 64)
        dinoThree.position  = position
        dinoThree.zPosition = 4
        dinoThree.physicsBody = SKPhysicsBody(rectangleOf: dinoThree.size)
        dinoThree.physicsBody?.categoryBitMask = PhysicsCategory.dino3.rawValue
        dinoThree.physicsBody?.contactTestBitMask = PhysicsCategory.hero.rawValue
            | PhysicsCategory.food.rawValue
            | PhysicsCategory.rock.rawValue
            | PhysicsCategory.block.rawValue
            | PhysicsCategory.border.rawValue
        dinoThree.physicsBody?.collisionBitMask  = 0
        dinoThree.physicsBody?.affectedByGravity = false
        self.addChild(dinoThree)
        
        moveDinoThree()
    }
    
    // Move dino 3 left right up and down
    
    func moveDinoThree(){
        let randomDirection = getRandomDirection()
        
        
        if randomDirection == "North"{
            print("Go North")
            dinoThree.texture = dinoThreeUpTexture
            let endPoint = CGPoint(x: dinoThree.position.x,
                                   y: 600)
            let moveAction = SKAction.move(to: endPoint,
                                           duration: 5)
            dinoThree.run(moveAction)
            
        }
        else if randomDirection == "South"{
            print("Go South")
            dinoThree.texture = dinoThreeDownTexture
            let endPoint = CGPoint(x: dinoThree.position.x,
                                   y: 96)
            let moveAction = SKAction.move(to: endPoint,
                                           duration: 5)
            dinoThree.run(moveAction)
            
        }
        else if randomDirection == "East"{
            print("Go East")
            dinoThree.texture = dinoThreeLeftTexture
            let endPoint = CGPoint(x: 32,
                                   y: dinoThree.position.y)
            let moveAction = SKAction.move(to: endPoint,
                                           duration: 5)
            dinoThree.run(moveAction)
            
        }
        else if randomDirection == "West"{
            print("Go West")
            dinoThree.texture = dinoThreeRightTexture
            let endPoint = CGPoint(x: 1000,
                                   y: dinoThree.position.y)
            let moveAction = SKAction.move(to: endPoint,
                                           duration: 5)
            dinoThree.run(moveAction)
            
        }
        else{
            print("Did not get a direction for dino 3")
        }
        
    }
    
    func getRandomDirection() -> String {
        let number = generateRandomInt(min: 0, max: 3)
        
        switch(number){
        case 0:
            print("Return North")
            return "North"
        case 1:
            print("Return South")
            return "South"
        case 2:
            print("Return East")
            return "East"
        case 3:
            print("Return West")
            return "West"
        default:
            return ""
        }
    }
    
    // Generate a random integer
    func generateRandomInt(min: Int, max:Int) -> Int {
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered

    }
    
}
