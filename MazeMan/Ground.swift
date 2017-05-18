//
//  Ground.swift
//  MazeMan
//
//  Created by Wes Bosman on 4/4/17.
//  Copyright © 2017 Wes Bosman. All rights reserved.
//
import Foundation
import SpriteKit

class Ground:SKSpriteNode{
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Environment")
    let tileSize = CGSize(width: 64, height: 64)
    var star: SKSpriteNode   = SKSpriteNode(imageNamed: "Star")
    var rock: SKSpriteNode   = SKSpriteNode(imageNamed: "Rock")
    var heart: SKSpriteNode  = SKSpriteNode(imageNamed: "Heart")
    var energy: SKSpriteNode = SKSpriteNode(imageNamed: "Battery")
    var starLabel   = SKLabelNode(text: "0")
    var rockLabel   = SKLabelNode(text: "10")
    var heartLabel  = SKLabelNode(text: "3")
    var energyLabel = SKLabelNode(text: "100")
    var rockCount   = 10
    var heartCount  = 3
    var energyCount = 100
    var starCount   = 0
    let heartMax    = 3
    var life        = 400
    let maxLife     = 400
    var gameOver    = false
    var waterPointOne = CGPoint()
    var waterPointTwo = CGPoint()
    
    // Rocks
    
    func decreaseRockLabel(){
        if rockCount >= 0{
            rockCount = rockCount - 1
            rockLabel.text = "\(rockCount)"
        }
    }
    
    func increaseRockLabel(){
        rockCount = rockCount + 1
        rockLabel.text = "\(rockCount)"
    }
    
    // Hearts
    
    func decreaseHeartLabel(){
        if heartCount >= 0{
            heartCount = heartCount - 1
            heartLabel.text = "\(heartCount)"
        }
    }
    
    func increaseHeartLabel(){
        if heartCount < heartMax{
            heartCount = heartCount + 1
            heartLabel.text = "\(heartCount)"
        }
    }
    
    // Energy
    
    func decreaseEnergyLabel(){
        let newLifeCount = (heartCount) * 100 + energyCount
        print("New Life Count \(newLifeCount)")
        
        if energyCount >= 0{
            energyCount = energyCount - 1
            energyLabel.text = "\(energyCount)"
        }
        if energyCount == 0 && heartCount > 0{
            decreaseHeartLabel()
            energyCount = 99
            energyLabel.text = "\(energyCount)"
        }
        else if energyCount <= 0 && heartCount <= 0{
            print("Game Over")
            energyLabel.text = "\(0)"
            heartLabel.text  = "\(0)"
            gameOver = true
        }
    }
    
    func increaseEnergyLabel(){
        energyCount = energyCount + 50
        if energyCount > 100{
            if heartCount < heartMax{
                energyCount = energyCount - 100
                increaseHeartLabel()
            }
            if heartCount == heartMax{
                energyCount = 99
            }
        }
        energyLabel.text = "\(energyCount)"
    }
    
    // Stars
    
    func decreaseStarCount(){
        if starCount >= 0{
            starCount = starCount - 1
            starLabel.text = "\(starCount)"
        }
    }
    
    func increaseStarCount(){
        starCount = starCount + 1
        starLabel.text = "\(starCount)"
    }
    
    func hitByFire(){
        var newLifeCount = heartCount * 100 + energyCount
        newLifeCount = newLifeCount - 100
        let hearts = newLifeCount / 100
        let energy = newLifeCount % 100
        print("Hearts: \(hearts)")
        print("Energy: \(energy)")
        heartCount  = hearts
        energyCount = energy
        
        heartLabel.text  = "\(hearts)"
        energyLabel.text = "\(energy)"
    }
    
    func hitByDinoOne(){
        var newLifeCount = heartCount * 100 + energyCount
        newLifeCount = newLifeCount - 60
        let hearts = newLifeCount / 100
        let energy = newLifeCount % 100
        heartCount  = hearts
        energyCount = energy
        print("Hearts: \(hearts)")
        print("Energy: \(energy)")
        heartLabel.text  = "\(hearts)"
        energyLabel.text = "\(energy)"
    }
    
    func hitByDinoTwo(){
        var newLifeCount = heartCount * 100 + energyCount
        newLifeCount = newLifeCount - 80
        let hearts = newLifeCount / 100
        let energy = newLifeCount % 100
        heartCount  = hearts
        energyCount = energy
        print("Hearts: \(hearts)")
        print("Energy: \(energy)")
        heartLabel.text  = "\(hearts)"
        energyLabel.text = "\(energy)"
    }
    
    func hitByDinoThree(){
        var newLifeCount = heartCount * 100 + energyCount
        newLifeCount = newLifeCount - 100
        let hearts = newLifeCount / 100
        let energy = newLifeCount % 100
        heartCount  = hearts
        energyCount = energy
        print("Hearts: \(hearts)")
        print("Energy: \(energy)")
        heartLabel.text  = "\(hearts)"
        energyLabel.text = "\(energy)"
    }
    
    func addTenRocks(){
        let newRockCount = rockCount + 10
        if newRockCount >= 20{
            rockLabel.text = "\(20)"
            rockCount = 20
        }
        else{
            rockLabel.text = "\(newRockCount)"
            rockCount = newRockCount
        }
    }
    
    // Player Status Panel
    
    func createPlayerStatusPanel(){
        let size = CGSize(width: 64, height: 64)
        starLabel.text   = "\(starCount)"
        rockLabel.text   = "\(rockCount)"
        heartLabel.text  = "\(heartCount)"
        energyLabel.text = "\(energyCount)"
        
        // Star and star label
        starLabel.zPosition = 3
        starLabel.fontSize = 30
        starLabel.fontName = "ChalkDuster"
        starLabel.position = CGPoint(x: 32,
                                     y: -45)
        star.size = size
        star.zPosition = 2
        star.position = CGPoint(x: 32,
                                y: -32)
        
        // Rock and rock label
        rockLabel.zPosition = 3
        rockLabel.fontSize = 30
        rockLabel.fontName = "ChalkDuster"
        rockLabel.position = CGPoint(x: 96,
                                     y: -45)
        rock.size = size
        rock.zPosition = 2
        rock.position = CGPoint(x: 96,
                                y: -32)
        
        // Heart and heart label
        heartLabel.zPosition = 3
        heartLabel.fontSize = 30
        heartLabel.fontName = "ChalkDuster"
        heartLabel.position = CGPoint(x: 160,
                                      y: -45)
        heart.size = size
        heart.zPosition = 2
        heart.position = CGPoint(x: 160,
                                 y: -32)
        
        // Energy and energy label
        energyLabel.zPosition = 3
        energyLabel.fontSize = 30
        energyLabel.fontName = "ChalkDuster"
        energyLabel.position = CGPoint(x: 256,
                                       y: -30)
        energy.size = CGSize(width: 128, height: 64)
        energy.zPosition = 2
        energy.position = CGPoint(x: 256,
                                   y: -40)
        
        // Add all the nodes
        self.addChild(star)
        self.addChild(starLabel)
        self.addChild(rock)
        self.addChild(rockLabel)
        self.addChild(heart)
        self.addChild(heartLabel)
        self.addChild(energy)
        self.addChild(energyLabel)
    }
    
    func createFloor(){
        print("Create Floor For Ground")
        var tileCount:CGFloat = 0
        self.anchorPoint = CGPoint(x: 0, y: 1)
        let texture = textureAtlas.textureNamed("GroundBottom")

        print("Self.size.width: \(self.size.width)")
        print("Self.size.height: \(self.size.height)")
        
        while tileCount * tileSize.width < self.size.width{
            
            // Add a water tile
            if tileCount == 6 || tileCount == 10{
                let tileNode = SKSpriteNode(imageNamed: "Water")
                tileNode.size = tileSize
                tileNode.position.x = tileCount * tileSize.width
                tileNode.anchorPoint = CGPoint(x: 0, y: 1)
                self.addChild(tileNode)
                
                // Save the position of the water tiles for dino 1
                if tileCount == 6{
                    waterPointOne = tileNode.position
                }
                else if tileCount == 10{
                    waterPointTwo = tileNode.position
                }
            }
            // Add a block tile
            else{
                let tileNode = SKSpriteNode(texture: texture)
                tileNode.size = tileSize
                tileNode.position.x = tileCount * tileSize.width
                tileNode.anchorPoint = CGPoint(x: 0, y: 1)
                self.addChild(tileNode)
            }
            
            tileCount += 1
        }
        // Add the player status panel to the bottom row
        createPlayerStatusPanel()
    }
}
