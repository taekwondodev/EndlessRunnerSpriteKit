//
//  MainMenu.swift
//  EndlessRunnerSpriteKit
//
//  Created by Davide Galdiero on 13/12/23.
//

import SpriteKit

class MainMenu: SKScene{
    
    //MARK: -Properties
    var containerNode: SKSpriteNode!
    
    var dialogLbl = SKLabelNode()
    let sentences = [ "Hi welcome to the academy!","Did you forget about the final deliverable?!?!","I tell you only one thing...RUN","Tap to jump"]
    
    var isPlaying = true
    var effectEnabled = true
    
    //MARK: -Systems
    override func didMove(to view: SKView) {
        setupBG()
        createGround()
        setupBarbara()
        createDialog()
        showTextWithBackground(text: sentences)
        setupTitle()
        setupNodes()
        setupMusic()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches .first else { return }
        let node = atPoint(touch.location(in: self))
        
        if node.name == "Play"{
            let scene = GameScene(size: size)
            scene.scaleMode = scaleMode
            view!.presentScene(scene, transition: .push(with: .left, duration: 2.5))
        }
        
        else if node.name == "Highscore"{
            setupPanel()
        }
        
        else if node.name == "Setting"{
            setupSetting()
        }
        
        else if node.name == "Container"{
            containerNode.removeFromParent()
        }
        
        else if node.name == "Music"{
            let node = node as! SKSpriteNode
            isPlaying = !isPlaying
            DataStorage.sharedIstance.setKeyIsPlaying(isPlaying)
            node.texture = SKTexture(imageNamed: isPlaying ? "musicOn" : "musicOff")
        }
        
        else if node.name == "Effect"{
            let node = node as! SKSpriteNode
            effectEnabled = !effectEnabled
            DataStorage.sharedIstance.setKeyEffectEnabled(effectEnabled)
            node.texture = SKTexture(imageNamed: effectEnabled ? "effectOn" : "effectOff")
        }
    }
    
}

//MARK: -Configurations
extension MainMenu{
    
    func setupBG(){
        anchorPoint = .zero
        backgroundColor = UIColor(red: 0.96, green: 0.92, blue: 0.89, alpha: 1)
    }
    
    func createGround(){
        for i in 0...3{
            let ground = SKSpriteNode(imageNamed: "ground")
            ground.name = "Ground"
            ground.anchorPoint = .zero
            ground.zPosition = 4.0
            ground.position = CGPoint(x: CGFloat(i)*ground.size.width, y: ground.size.height / 1.5)
            addChild(ground)
        }
    }
    
    func setupBarbara(){
        let barbara = SKSpriteNode(imageNamed: "Barbara1")
        
        var barbaraTextures:[SKTexture] = []
        for i in 1...8{
            barbaraTextures.append(SKTexture(imageNamed: "Barbara\(i)"))
        }
        barbara.run(.repeatForever(.animate(with: barbaraTextures, timePerFrame: 0.1)))
        
        barbara.name = "barbara"
        barbara.setScale(3.0)
        barbara.zPosition = 3.0
        barbara.position = CGPoint(x: frame.midY/2.0 , y: frame.midY - 18.0)
        
        let desk = SKSpriteNode(imageNamed: "desk")
        desk.name = "desk"
        desk.zPosition = 3.5
        desk.setScale(0.2)
        desk.position = CGPoint(x: barbara.position.x,
                                y: barbara.position.y )
        
        
        self.addChild(barbara)
        self.addChild(desk)
    }
    
    func createDialog(){
        let dialogBackground = SKSpriteNode(color: SKColor.white, size: CGSize(width: 400, height: 150))
        dialogBackground.alpha = 0.7
        dialogBackground.position = CGPoint(x: size.width / 5.7, y: size.height / 1.55)
        
        addChild(dialogBackground)
        
        dialogLbl = SKLabelNode(fontNamed: "ARCADECLASSIC")
        dialogLbl.text = ""
        dialogLbl.fontColor = UIColor.black
        dialogLbl.fontSize = 30
        dialogLbl.zPosition = 50.0
        dialogLbl.position = CGPoint(x: dialogBackground.position.x, y: dialogBackground.position.y - 20.0)
        
        dialogLbl.numberOfLines = 0
        dialogLbl.preferredMaxLayoutWidth = dialogBackground.size.width - 20
        
        addChild(dialogLbl)
        
        dialogBackground.zPosition = dialogLbl.zPosition - 1
    }
    
    func showTextWithBackground(text: [String]){
        guard !text.isEmpty else { return }
        
        displayNextPhrase(index: 0)
    }
    
    // Recursive function to see text automatically one after one
    func displayNextPhrase(index: Int) {
        guard index < sentences.count else {
            return  // ends when every sentences are read
        }

        let currentSentence = sentences[index]

        typingEffect(currentSentence) {
            // add a wait time between two sentences
            let waitAction = SKAction.wait(forDuration: 1.5)

            // run the action
            self.run(waitAction, completion: {
                self.displayNextPhrase(index: index + 1)
            })
        }
        
    }
    
    // Simulate typing
    func typingEffect(_ text: String, completion: @escaping () -> Void) {
        dialogLbl.text = ""  // current label

        for (index, char) in text.enumerated() {
            
            // wait time between the chars
            let waitDuration = TimeInterval(index) * 0.09
            let waitAction = SKAction.wait(forDuration: waitDuration)

            // create an action to append the chars to the label
            let typeAction = SKAction.run {
                self.dialogLbl.text?.append(char)
            }

            // run the action for every char
            let typeSequence = SKAction.sequence([waitAction, typeAction])

            dialogLbl.run(typeSequence)
        }

        // to end the tipyng simulate
        let totalDuration = TimeInterval(text.count) * 0.1
        let completionAction = SKAction.wait(forDuration: totalDuration)
        dialogLbl.run(completionAction, completion: completion)
    }
    
    func setupTitle(){
        let titleLabel = SKLabelNode(fontNamed: "KarmaticArcade")
        titleLabel.text = "Late Deliverable"
        titleLabel.zPosition = 20.0
        titleLabel.fontSize = 80
        titleLabel.fontColor = UIColor.black
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY * 1.5)
        
        addChild(titleLabel)
    }
    
    func setupNodes(){
        let play = SKSpriteNode(imageNamed: "play")
        play.name = "Play"
        play.setScale(0.5)
        play.zPosition = 10.0
        play.position = CGPoint(x: frame.midX, y: frame.midY)
        
        addChild(play)
        
        let highscore = SKSpriteNode(imageNamed: "highscore")
        highscore.name = "Highscore"
        highscore.setScale(0.2)
        highscore.zPosition = 10.0
        highscore.position =  CGPoint(x: frame.minX + 100.0, y: frame.minY + highscore.frame.height * 1.35)
        
        addChild(highscore)
        
        let setting = SKSpriteNode(imageNamed: "setting")
        setting.name = "Setting"
        setting.setScale(0.2)
        setting.zPosition = 10.0
        setting.position = CGPoint(x: frame.maxX - 100.0, y: frame.minY + setting.frame.height * 1.35 )
        
        addChild(setting)
    }
    
    func setupPanel(){
        setupContainer()
        
        let panel = SKSpriteNode(color: SKColor.white, size: CGSize(width: 700, height: 200))
        panel.setScale(1.5)
        panel.zPosition = 20.0
        panel.position = .zero
        containerNode.addChild(panel)
        
        let highscoreLbl = SKLabelNode(fontNamed: "ARCADECLASSIC")
        highscoreLbl.text = "Highscore: \(DataStorage.sharedIstance.getHighScore())"
        highscoreLbl.horizontalAlignmentMode = .center
        highscoreLbl.verticalAlignmentMode = .center
        highscoreLbl.fontSize = 60.0
        highscoreLbl.fontColor = UIColor.black
        highscoreLbl.zPosition = 50.0
        highscoreLbl.position = CGPoint(x: panel.frame.midX, y: panel.frame.midY)
        
        panel.addChild(highscoreLbl)
    }
    
    func setupContainer(){
        containerNode = SKSpriteNode()
        containerNode.name = "Container"
        containerNode.zPosition = 15.0
        containerNode.color = .clear
        containerNode.size = size
        containerNode.position = CGPoint(x: size.width/2.0, y: size.height/2.0)
        addChild(containerNode)
    }
    
    func setupSetting(){
        setupContainer()
        
        let panel = SKSpriteNode(color: SKColor.white, size: CGSize(width: 700, height: 350))
        panel.setScale(1.5)
        panel.zPosition = 20.0
        panel.position = .zero
        containerNode.addChild(panel)
        
        //Music
        let music = SKSpriteNode(imageNamed: isPlaying ? "musicOn" : "musicOff")
        music.name = "Music"
        music.setScale(0.25)
        music.zPosition = 70.0
        music.position = CGPoint(x: -panel.frame.width/2.0 + 350.0, y: 0.0)
        panel.addChild(music)
        
        //Sound
        let effect = SKSpriteNode(imageNamed: effectEnabled ? "effectOn" : "effectOff")
        effect.name = "Effect"
        effect.setScale(0.25)
        effect.zPosition = 70.0
        effect.position = CGPoint(x: panel.frame.width/2.0 - 350.0, y: 0.0)
        panel.addChild(effect)
    }
    
    func setupMusic(){
        DataStorage.sharedIstance.setKeyIsPlaying(isPlaying)
        DataStorage.sharedIstance.setKeyEffectEnabled(effectEnabled)
    }
}

