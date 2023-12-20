//
//  GameOver.swift
//  EndlessRunnerSpriteKit
//
//  Created by Davide Galdiero on 13/12/23.
//

import SpriteKit

class GameOver: SKScene{
    
    let containerNode = SKSpriteNode()
    
    //MARK: -Systems
    override func didMove(to view: SKView) {
        createBG()
        createGround()
        createNodes()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        let scene = MainMenu(size: size)
        scene.scaleMode = scaleMode
        view!.presentScene(scene,transition: .doorsCloseVertical(withDuration: 0.8))
        
    }
    
}
//MARK: -Configurations
extension GameOver{
    
    func createBG(){
        for i in 0...2 {
            let bg = SKSpriteNode(imageNamed: "background")
            bg.name = "BG"
            bg.anchorPoint = .zero
            bg.position = CGPoint(x: CGFloat(i)*bg.frame.width, y: 0.0)
            bg.zPosition = -1.0
            addChild(bg)
        }
    }
    
    func createGround(){
        
        for i in 0...2{
            
            let ground = SKSpriteNode(imageNamed: "ground")
            ground.name = "Ground"
            ground.anchorPoint = .zero
            ground.zPosition = 1.0
            ground.position = CGPoint(x: -CGFloat(i)*ground.frame.width, y: 150.0)
            
            //physics
            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            ground.physicsBody!.isDynamic = false
            ground.physicsBody!.affectedByGravity = false
            ground.physicsBody!.categoryBitMask = PhysicsCategory.ground
            
            addChild(ground)
        }
    }
    
    func createNodes(){
        setupContainer()
        
        let panel = SKSpriteNode()
        panel.position = .zero
        panel.zPosition = 20.0
        containerNode.addChild(panel)
        
        let gameOverLable = SKLabelNode(fontNamed:"ARCADECLASSIC")
        gameOverLable.text = "Game Over"
        gameOverLable.fontSize = 200.0
        gameOverLable.horizontalAlignmentMode = .center
        gameOverLable.verticalAlignmentMode = .center
        gameOverLable.zPosition = 50.0
        gameOverLable.position = CGPoint (x: panel.frame.midX, y: panel.frame.midY)
        
        panel.addChild(gameOverLable)
        
        let gameOverSubLable = SKLabelNode(fontNamed:"ARCADECLASSIC")
        gameOverSubLable.text = "Tap anywhere to continue"
        gameOverSubLable.fontSize = 50.0
        gameOverSubLable.horizontalAlignmentMode = .center
        gameOverSubLable.verticalAlignmentMode = .center
        gameOverSubLable.zPosition = 50.0
        gameOverSubLable.position = CGPoint(x: panel.frame.midX, y: panel.frame.midY - gameOverLable.frame.height * 1.5)
        panel.addChild(gameOverSubLable)
        
        highscoreAnimation(node: gameOverLable)
    }
    
    func setupContainer(){
        containerNode.name = "container"
        containerNode.zPosition = 15.0
        containerNode.color = .clear
        containerNode.size = size
        containerNode.position = CGPoint(x: size.width/2.0, y: size.height/2.0)
        
        addChild(containerNode)
    }
    
    func highscoreAnimation(node: SKNode){
        let scaleUp = SKAction.scale(to: 1.2, duration: 1.0)
        scaleUp.timingMode = .easeInEaseOut
        
        let scaleDown = SKAction.scale(to: 0.8, duration: 1.0)
        scaleDown.timingMode = .easeInEaseOut
        
        let fullScale = SKAction.sequence([scaleUp, scaleDown])
        node.run(.repeatForever(fullScale))
    }
    
}

