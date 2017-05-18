//
//  Ceiling.swift
//  MazeMan
//
//  Created by Wes Bosman on 4/10/17.
//  Copyright © 2017 Wes Bosman. All rights reserved.
//

import Foundation
import SpriteKit

class Ceiling:SKSpriteNode{
    var textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Environment")
    var gameStatus: SKSpriteNode  = SKSpriteNode(imageNamed: "GameStatus")
    let tileSize = CGSize(width: 64, height: 64)
    var gameLabelNode: SKLabelNode = SKLabelNode(text: "Welcome to mazeman!")
    
    func createGameStatusPanel(){
        gameLabelNode.fontName = "ChalkDuster"
        gameLabelNode.fontSize = 30
        gameLabelNode.zPosition = 5
        gameStatus.position.x = 520
        gameStatus.position.y = 60
        gameStatus.size = CGSize(width: 700, height: 128)
        gameStatus.zPosition = 4
        gameStatus.addChild(gameLabelNode)
        addChild(gameStatus)
    }
    
    func createCeiling(){
        print("Create Ceiling")
        var tileCount:CGFloat = 0
        self.anchorPoint = CGPoint(x: 0, y: 1)
        let texture = textureAtlas.textureNamed("GroundTop")
        
        print("Self.size.width: \(self.size.width)")
        print("Self.size.height: \(self.size.height)")
        
        // Create the two nodes for each top row
        while tileCount * tileSize.width < self.size.width{
            let tileNodeTwo = SKSpriteNode(texture: texture)
            tileNodeTwo.size = tileSize
            tileNodeTwo.position.x = tileCount * tileSize.width
            tileNodeTwo.position.y = self.size.height
            tileNodeTwo.anchorPoint = anchorPoint
            self.addChild(tileNodeTwo)
            
            let tileNode = SKSpriteNode(texture: texture)
            tileNode.size = tileSize
            tileNode.position.x = tileCount * tileSize.width
            tileNode.position.y = self.size.height - 64
            tileNode.anchorPoint = anchorPoint
            self.addChild(tileNode)
                
            tileCount += 1
        }
        // Create game status panel
        createGameStatusPanel()
    }
}
