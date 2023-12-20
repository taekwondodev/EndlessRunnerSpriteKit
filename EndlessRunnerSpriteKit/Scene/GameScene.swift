//
//  GameScene.swift
//  EndlessRunnerSpriteKit
//
//  Created by Davide Galdiero on 13/12/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    //MARK: -Properties
    
    //element
    var player: SKSpriteNode!
    var ground: SKSpriteNode!
    var obstacles = [SKSpriteNode]()
    var paperCoin: SKSpriteNode!
    
    //Stats
    var velocityX = 7.0
    var started = false
    
    //Timer
    var timer: Timer?
    var timerUpdate: TimeInterval = 1.0
    var difficultyTimer:Timer?
    var obstacleSpawnTimer: Timer?
    var paperSpawntimer: Timer?
    var macSpawnTimer: Timer?
    
    //jump element
    var isTime: CGFloat = 3.0
    var onGround = true
    var velocityY: CGFloat = 0.0
    var gravity: CGFloat = 0.6
    var playerPosY: CGFloat = 0.0
    
    //score elemnt
    var numScore = 0
    var gameOver = false
    var scoreLbl = SKLabelNode(fontNamed: "ARCADECLASSIC")
    var highScore = DataStorage.sharedIstance.getHighScore()
    
    //pause elemnt
    //var pauseNode: SKSpriteNode!
    var containerNode = SKNode()
    
    //Effect
    var effectEnabled = DataStorage.sharedIstance.getEffectEnabled()
    var soundJump = SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false)
    var soundCoin = SKAction.playSoundFileNamed("collectible.wav", waitForCompletion: false)
    var soundDeath = SKAction.playSoundFileNamed("death.wav", waitForCompletion: false)
    
    //Music
    var backgroundMusic = SKAudioNode(fileNamed: "Its_Snowtime_MP3.mp3")
    var isPlaying = DataStorage.sharedIstance.getIsPlaying()
    
    //MARK: -Systems
    
    //when the view stream the scene
    override func didMove(to view: SKView) {
        setupNodes()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches .first else { return }
        let node = atPoint(touch.location(in: self))
        
        if node.name == "Pause" && started{
            if isPaused { return }
            backgroundMusic.run(SKAction.pause())
            createPanel()
            timer?.invalidate()
            isPaused = true
        }
        
        else if node.name == "Resume"{
            backgroundMusic.run(SKAction.play())
            containerNode.removeFromParent()
            startTimer()
            isPaused = false
        }
        
        else if node.name == "Back"{
            let scene = MainMenu(size: size)
            scene.scaleMode = scaleMode
            view!.presentScene(scene, transition: .doorsCloseVertical(withDuration: 0.8))
        }
        
        //To make the jump
        else{
            if !isPaused && started{
                if onGround{
                    onGround = false
                    velocityY = -25.0
                    
                    //jump effect audio
                    if effectEnabled{
                        run(soundJump)
                    }
                }
            }
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if velocityY < -12.5{
            velocityY = -12.5
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if started {
            moveNodes()
        }
        
        //jump update
        velocityY += gravity
        player.position.y -= velocityY
        
        if player.position.y < playerPosY{
            player.position.y = playerPosY
            velocityY = 0.0
            onGround = true
        }
        
        if gameOver {
            let scene = GameOver(size: size)
            scene.scaleMode = scaleMode
            view!.presentScene(scene, transition: .doorsCloseVertical(withDuration: 0.8))
        }
        
    }
    
    //reset timer when scene has been dealloccated
    deinit {
        timer?.invalidate()
        difficultyTimer?.invalidate()
        paperSpawntimer?.invalidate()
        obstacleSpawnTimer?.invalidate()
        macSpawnTimer?.invalidate()
    }
    
}

//MARK: -Configurations
extension GameScene{
    
    //set the design
    func setupNodes(){
        createBG()
        createGround()
        createPlayer()
        makeIntro()
        setupMusic()
        setupPhysics()
        setupScore()
        setupPause()
    }
    
    //switch between 2 backgrounds
    func createBG(){
        for i in 0...2 {
            let bg = SKSpriteNode(imageNamed: "Bg\(i)")
            bg.name = "BG"
            bg.setScale(0.62)
            bg.anchorPoint = .zero
            bg.position = CGPoint(x: CGFloat(i) * bg.size.width, y: frame.midY - bg.frame.height/2.0)
            bg.zPosition = -1.0
            addChild(bg)
        }
    }
    
    
    func createGround(){
        
        for i in 0...3{
            
            ground = SKSpriteNode(imageNamed: "ground")
            ground.name = "Ground"
            ground.anchorPoint = .zero
            ground.zPosition = 4.0
            ground.position = CGPoint(x: CGFloat(i) * ground.size.width, y: ground.size.height / 1.5)
            //Physics
            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            ground.physicsBody!.isDynamic = false
            ground.physicsBody!.affectedByGravity = false
            ground.physicsBody!.categoryBitMask = PhysicsCategory.ground
            
            addChild(ground)
        }
    }
    
    
    func createPlayer(){
        
        player = SKSpriteNode(imageNamed: "00_Run")
        player.name = "Player"
        player.zPosition = 5.0
        player.setScale(1.2)
        //positioning the player on the ground
        player.position = CGPoint(x: frame.minX - player.size.width, y: frame.midY - 200.0)
        
        //Run animation
        var textures = [SKTexture]()
        for i in 0...8{
            textures.append(SKTexture(imageNamed: "0\(i)_Run"))
        }
        player.run(.repeatForever(.animate(with: textures, timePerFrame: 0.08)))
        
        //Physic
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/4.0)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.restitution = 0.0
        player.physicsBody!.categoryBitMask = PhysicsCategory.player
        player.physicsBody!.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.paperCoin
        
        //jump
        playerPosY = player.position.y
        
        addChild(player)
    }
    
    func makeIntro(){
        //Create an intro to the scene
        let introX = SKAction.moveTo(x: frame.midX/2.0, duration: 2.5)
        player.run(.repeat(introX, count: 1)){
            // Start Timer
            self.startTimer()
            self.startObstacleSpawnTimer()
            self.startPaperSpawnTimer()
            self.updateDifficulty()
            self.spawnMac()
            self.started = true
        }
        
    }
    
    //set movement
    func moveNodes(){
        
        //move Background
        enumerateChildNodes(withName: "BG") { (node, _) in
            let node = node as! SKSpriteNode
            node.position.x -= self.velocityX
            
            if node.position.x < -node.size.width {
                node.position.x += node.size.width*2.0
            }
        }
        
        //move Ground
        enumerateChildNodes(withName: "Ground") { (node, _) in
            let node = node as! SKSpriteNode
            node.position.x -= self.velocityX
            
            if node.position.x < -node.size.width {
                node.position.x += node.size.width*2.0
            }
        }
    }
    
    func setupMusic(){
        if isPlaying{
            self.addChild(backgroundMusic)
        }
    }
    
    func setupPhysics(){
        physicsWorld.contactDelegate = self
    }
    
    func setupScore(){
        
        //Label
        scoreLbl.text = "\(numScore)"
        scoreLbl.fontSize = 60.0
        scoreLbl.horizontalAlignmentMode = .center
        scoreLbl.verticalAlignmentMode = .center
        scoreLbl.zPosition = 30.0
        scoreLbl.position = CGPoint(x: frame.midX , y: frame.midY + frame.midY/2.0)
        
        addChild(scoreLbl)
        
        let scoreBackround = SKSpriteNode(color: SKColor.black, size: CGSize(width: 300, height: 100))
        scoreBackround.alpha = 0.4
        scoreBackround.zPosition = scoreLbl.zPosition - 1.0
        scoreBackround.position = scoreLbl.position
        
        addChild(scoreBackround)
    }
    
    func setupGameOver(){
        if !gameOver{
            gameOver = true
        }
        
        if !onGround{
            let move = SKAction.moveTo(y: playerPosY, duration: 0.8)
            player.run(move)
        }
        
        //Music off
        backgroundMusic.run(SKAction.pause())
        
        //death animation
        var textures = [SKTexture]()
        for i in 0...9{
            textures.append(SKTexture(imageNamed: "0\(i)_Death"))
        }
        player.run(.repeat(.animate(with: textures, timePerFrame: 0.2), count: 1))
        
        //new score vs old score
        if numScore > highScore {
            highScore = numScore
            DataStorage.sharedIstance.setHighScore(highScore)
        }
        
        //invalidate the timer to stop them
        obstacleSpawnTimer?.isValid ?? false ? obstacleSpawnTimer?.invalidate() : startObstacleSpawnTimer()
        paperSpawntimer?.isValid ?? false ? paperSpawntimer?.invalidate() : startPaperSpawnTimer()
        macSpawnTimer?.isValid ?? false ? macSpawnTimer?.invalidate() : spawnMac()
        
    }
    
    func setupPause(){
        
        let pauseNode = SKSpriteNode(imageNamed: "pause")
        pauseNode.setScale(0.25)
        pauseNode.zPosition = 50.0
        pauseNode.position = CGPoint(x: frame.maxX - 150.0, y: frame.maxY - 400.0)
        
        addChild(pauseNode)
        
        let panel = SKSpriteNode(color: SKColor.white, size: CGSize(width: 150, height: 150))
        panel.name = "Pause"
        panel.alpha = 0.01
        panel.position = CGPoint(x: pauseNode.position.x, y: pauseNode.position.y)
        panel.zPosition = 55.0
        
        addChild(panel)
    }
    
    //panel when click on pause
    func createPanel(){
        addChild(containerNode)
        
        let panel = SKSpriteNode(color: SKColor.white, size: CGSize(width: 700, height: 350))
        panel.setScale(1.5)
        panel.zPosition = 60.0
        panel.position = CGPoint(x: size.width/2.0, y: size.height/2.0)
        containerNode.addChild(panel)
        
        let resume = SKSpriteNode(imageNamed: "resume")
        resume.name = "Resume"
        resume.zPosition = 70.0
        resume.setScale(0.7)
        resume.position = CGPoint(x: -panel.frame.width/2.0 + 350.0, y: 0.0)
        panel.addChild(resume)
        
        let back = SKSpriteNode(imageNamed: "back")
        back.name = "Back"
        back.zPosition = 70.0
        back.setScale(0.61)
        back.position = CGPoint(x: panel.frame.width/2.0 - 350.0, y: 0.0)
        panel.addChild(back)
    }
    
}

//MARK: -Physics Delegate
extension GameScene: SKPhysicsContactDelegate{
    
    func didBegin(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask == PhysicsCategory.player ? contact.bodyB : contact.bodyA
        //other così diventa il bit di quello toccato dal player
        
        switch other.categoryBitMask {
            
        case PhysicsCategory.obstacle:
            //if touch obstacle you lose
            setupGameOver ()
            
            //effect audio collision
            if effectEnabled{
                run(soundDeath)
            }
            
        case PhysicsCategory.paperCoin:
            
            if let node = other.node{
                numScore += 50
                scoreLbl.text = "\(numScore)"
                node.removeFromParent()
            }
            //new score vs old score
            if numScore > highScore {
                highScore = numScore
                DataStorage.sharedIstance.setHighScore(highScore)
            }
            
            //effect
            run(soundCoin)
            
        default:
            break
        }
    }
    
    //MARK: -Timer
    
    @objc func setupObstacles(){
        
        for i in 1...3{
            let sprite = SKSpriteNode(imageNamed: "block-\(i)")
            sprite.name = "Obstacle"
            obstacles.append(sprite)
        }
        
        //randomize obstacles
        let index = Int(arc4random_uniform(UInt32(obstacles.count-1)))
        let sprite = obstacles[index].copy() as! SKSpriteNode
        sprite.zPosition = 5.0
        sprite.setScale(0.25)
        sprite.position = CGPoint(x: size.width + sprite.size.width * 1.5, y: ground.size.height + 100)
        
        //physics
        sprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: sprite.size.width/2.0, height: sprite.size.height/1.5))
        sprite.physicsBody!.affectedByGravity = false
        sprite.physicsBody!.isDynamic = true
        sprite.physicsBody!.allowsRotation = false
        sprite.physicsBody!.categoryBitMask = PhysicsCategory.obstacle
        sprite.physicsBody!.contactTestBitMask = PhysicsCategory.player
        
        //spawn and remove
        if !isPaused && !gameOver{
            //spawn only if the game is not paused
            addChild(sprite)
            
            let moveAction = SKAction.moveTo(x: -sprite.size.width, duration: 5)
            let removeAction = SKAction.removeFromParent()
            sprite.run(SKAction.sequence([moveAction, removeAction]))
        }
        
        startObstacleSpawnTimer()
    }
    
    @objc func setupMac(){
        let mac = SKSpriteNode(imageNamed: "mac")
        mac.setScale(0.5)
        mac.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        mac.position = CGPoint(x: frame.maxX, y: frame.midY)
        mac.zPosition = 5.0
        
        let rotate = SKAction.rotate(byAngle: 45, duration: 8)
        mac.run(.repeatForever(rotate))
        
        mac.physicsBody = SKPhysicsBody(rectangleOf: mac.size)
        mac.physicsBody?.affectedByGravity = false
        mac.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        mac.physicsBody?.contactTestBitMask = PhysicsCategory.player
        
        //remove them when i dont need them anymore
        mac.run(.sequence([
            .wait(forDuration: 10.0),
            .removeFromParent()
        ]))
        
        if !isPaused && !gameOver{
            //spawn only if the game is not paused
            addChild(mac)
            
            let moveAction = SKAction.moveTo(x: -mac.size.width, duration: 3)
            let removeAction = SKAction.removeFromParent()
            mac.run(SKAction.sequence([moveAction, removeAction]))
        }
    }
    
    @objc func createCoin(){
        
        paperCoin = SKSpriteNode(imageNamed: "paper0")
        paperCoin.name = "Coin"
        paperCoin.setScale(1.1)
        paperCoin.zPosition = 5.0
        paperCoin.position = CGPoint(x: frame.midX * 4.0, y: frame.midY * 1.2)
        
        //physics
        paperCoin.physicsBody = SKPhysicsBody(circleOfRadius: paperCoin.size.width / 2.0)
        paperCoin.physicsBody!.affectedByGravity = false
        paperCoin.physicsBody!.isDynamic = false
        paperCoin.physicsBody!.categoryBitMask = PhysicsCategory.paperCoin
        paperCoin.physicsBody!.contactTestBitMask = PhysicsCategory.player
        
        //paperCoin animation
        var textures = [SKTexture]()
        for i in 0...3{
            textures.append(SKTexture(imageNamed: "paper\(i)"))
        }
        paperCoin.run(.repeatForever(.animate(with: textures, timePerFrame: 0.5)))
        
        if !isPaused && !gameOver{
            //spawn only if the game is not paused
            addChild(paperCoin)
            
            let moveAction = SKAction.moveTo(x: -paperCoin.size.width, duration: 6)
            let removeAction = SKAction.removeFromParent()
            paperCoin.run(SKAction.sequence([moveAction, removeAction]))
        }
        
    }
    
    //Used by timer to increase difficulty every 200 points
    @objc func increaseVelocity(){
        if((numScore % 200) == 0) && numScore > 0 {
            if (isTime > 1.7) && (velocityX <= 13){
                isTime -= 0.4
                velocityX += 1.0
            }
        }
    }
    
    //Every second you earn 10 points
    @objc func addPoints(){
        if !gameOver {
            numScore += 10
            scoreLbl.text = "\(numScore)"
        }
    }
    
    func startObstacleSpawnTimer() {
        obstacleSpawnTimer?.invalidate()
        obstacleSpawnTimer = Timer.scheduledTimer(timeInterval: isTime, target: self,
                                                  selector: #selector(setupObstacles), userInfo: nil, repeats: true)
    }
    //Timer to make epaper Spawn
    func startPaperSpawnTimer(){
        paperSpawntimer = Timer.scheduledTimer(timeInterval: TimeInterval.random(in: 5...10), target: self,
                                               selector: #selector(createCoin), userInfo: nil, repeats: true)
    }
    //Regular Timer
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: timerUpdate, target: self,
                                     selector: #selector(addPoints), userInfo: nil, repeats: true)
    }
    //Timer to increase difficulty
    func updateDifficulty(){
        difficultyTimer = Timer.scheduledTimer(timeInterval: timerUpdate, target: self,
                                               selector: #selector(increaseVelocity), userInfo: nil, repeats: true)
    }
    func spawnMac(){
        macSpawnTimer = Timer.scheduledTimer(timeInterval: 10, target: self,
                                             selector: #selector(setupMac), userInfo: nil, repeats: true)
    }
}

