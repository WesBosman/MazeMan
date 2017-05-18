//
//  MainScreen.swift
//  MazeMan
//
//  Created by Wes Bosman on 4/16/17.
//  Copyright © 2017 Wes Bosman. All rights reserved.
//

import UIKit
import SpriteKit

struct HighScores{
    static var highScoreArray: [Int] = []
}

class MainScreen: SKScene {
    var highScoresLabelNode = SKLabelNode()
    var threeHighScoresLabelNode = SKLabelNode()
    var beginNewGameLabelNode = SKLabelNode()
    var currentScore: Int = 0
    let tapRecognizer = UITapGestureRecognizer()
    
    override func didMove(to view: SKView) {
        self.scene?.backgroundColor = UIColor.white
        let highScorePosition = CGPoint(x: (self.view?.frame.midX)! - 200,
                                        y: (self.view?.frame.midY)! + 100)
        let threeScorePosition = CGPoint(x: (self.view?.frame.midX)! - 200,
                                         y: (self.view?.frame.midY)! - 100)
        let newGamePosition = CGPoint(x: (self.view?.frame.midX)! - 200,
                                      y: (self.view?
                                        .frame.midY)! - 200)
        
        var threeScoreString = String()
        
        for score in HighScores.highScoreArray{
            threeScoreString = "\(score) "
        }
        
        highScoresLabelNode.text = "Current Score : \(currentScore)"
        highScoresLabelNode.position = highScorePosition
        highScoresLabelNode.fontName = "ChalkDuster"
        highScoresLabelNode.fontSize = 30
        highScoresLabelNode.fontColor = UIColor.blue
        highScoresLabelNode.zPosition = 1
        
        threeHighScoresLabelNode.text = "High Scores: \(threeScoreString)"
        threeHighScoresLabelNode.position = threeScorePosition
        threeHighScoresLabelNode.fontName = "ChalkDuster"
        threeHighScoresLabelNode.fontSize = 30
        threeHighScoresLabelNode.fontColor = UIColor.black
        threeHighScoresLabelNode.zPosition = 1
        
        beginNewGameLabelNode.text = "Begin New Game"
        beginNewGameLabelNode.position = newGamePosition
        beginNewGameLabelNode.fontName = "ChalkDuster"
        beginNewGameLabelNode.fontSize = 30
        beginNewGameLabelNode.fontColor = UIColor.green
        beginNewGameLabelNode.zPosition = 1
        
        self.addChild(highScoresLabelNode)
        self.addChild(threeHighScoresLabelNode)
        self.addChild(beginNewGameLabelNode)
        
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.addTarget(self, action: #selector(didTapScreen))
        self.view?.addGestureRecognizer(tapRecognizer)
    }
    
    func didTapScreen(){
        // Restart the game 
        let transition = SKTransition.moveIn(with: .down, duration: 1.0)
        let gameScene = GameScene(size: (self.scene?.size)!)
        gameScene.scaleMode = .aspectFill
        self.scene?.view?.presentScene(gameScene, transition: transition)
        
    }

}
