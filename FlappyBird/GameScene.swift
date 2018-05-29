//
//  GameScene.swift
//  Flappy
//

import SpriteKit
import GameplayKit
import AVKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var initiated: Bool = false
    var space: CGFloat = 3.0
    var score = Int(0)
    var player: AVPlayer? = nil
    
    var bird = SKSpriteNode()
    var birdAnimation = SKAction()
    var gameOverImage = SKSpriteNode()
    var blockingObjects = SKNode()
    var scoreLabel = SKLabelNode()
    
    var timer = Timer()
    var gameTimer = Timer()
    
    let jumpSound = SKAction.playSoundFileNamed("jump.mp3", waitForCompletion: false)
    let gameoverSound = SKAction.playSoundFileNamed("gameover.mp3", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        if !self.initiated {
            self.initObjects()
            self.initiated = true
        }
        self.restartObjects()
    }
    
    func close() {
        let userDefaults = UserDefaults.standard
        let bestScore = userDefaults.object(forKey: "saveData") as! String
        if self.score > Int(bestScore)! {
            userDefaults.set(String(self.score), forKey: "saveData")
        }
        self.player?.pause()
        self.removeAllChildren()
    }
    
    fileprivate func initObjects() {
        
        let userDefaults = UserDefaults.standard
        let bestScore = userDefaults.object(forKey: "saveData") as! String
        
        let bgmName: String
        if Int(bestScore)! >= 14 {
            bgmName = "bgSound3.mp3"
            self.space = 2.0
        } else if Int(bestScore)! >= 7 {
            bgmName = "bgSound2.mp3"
            self.space = 2.5
        } else {
            bgmName = "bgSound1.mp3"
            self.space = 3.0
        }
        
        self.player = AVPlayer(url: Bundle.main.bundleURL.appendingPathComponent(bgmName))
        self.player?.seek(to: kCMTimeZero)
        self.player?.play()
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(repeatBGM),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: self.player?.currentItem
        )
        
        let bgView1 = SKSpriteNode(imageNamed: "bg")
        bgView1.position = CGPoint(x: 0, y: 0)
        bgView1.size.height = self.size.height
        bgView1.size.width = self.size.width
        bgView1.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.moveTo(x: -self.size.width, duration: 4.0),
            SKAction.moveTo(x: 0, duration: 0.0)
        ])))
        self.addChild(bgView1)
        
        let bgView2 = SKSpriteNode(imageNamed: "bg")
        bgView2.size.height = self.size.height
        bgView2.size.width = self.size.width
        bgView2.position = CGPoint(x: self.frame.width, y: 0)
        bgView2.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.moveTo(x: 0, duration: 4.0),
            SKAction.moveTo(x: self.frame.width, duration: 0.0)
        ])))
        self.addChild(bgView2)
        
        self.timer = Timer()
        self.gameTimer = Timer()

        self.score = Int(0)
        self.scoreLabel = SKLabelNode()
        self.scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        self.scoreLabel.text = "\(self.score)m"
        self.scoreLabel.color = .white
        self.scoreLabel.zPosition = 20
        self.scoreLabel.fontSize = 48
        self.scoreLabel.fontName = "HelveticaNeue-Bold"
        
        let scoreBg = SKShapeNode()
        scoreBg.position = CGPoint(x: -25, y: 0)
        let roundRect = CGRect(
            x: CGFloat(-50),
            y: CGFloat(-30),
            width: CGFloat(150),
            height: CGFloat(100)
        )
        scoreBg.path = CGPath(roundedRect: roundRect, cornerWidth: 50, cornerHeight: 50, transform: nil)
        let scoreBgColor: UIColor = .white
        scoreBg.alpha = 0.5
        scoreBg.strokeColor = .clear
        scoreBg.fillColor = scoreBgColor
        scoreBg.zPosition = 19
        self.scoreLabel.addChild(scoreBg)
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -8)
        
        self.gameOverImage = SKSpriteNode()
        let gameOverTexture = SKTexture(imageNamed: "GameOverImage")
        self.gameOverImage = SKSpriteNode(texture: gameOverTexture)
        self.gameOverImage.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.gameOverImage.zPosition = 21
        self.gameOverImage.isHidden = true
        self.addChild(self.gameOverImage)
        
        self.blockingObjects = SKSpriteNode()
        self.addChild(self.blockingObjects)
        
        self.initSpriteAnimate()
    }
    
    fileprivate func initSpriteAnimate() {
        let atlas = SKTextureAtlas(named: "Bird")
        var birdTexture = [SKTexture]()
        for i in 0...3 {
            birdTexture.append(atlas.textureNamed("bird" + String(i)))
        }
        self.birdAnimation = SKAction.animate(with: birdTexture, timePerFrame: 0.25)
    }
    
    @objc func repeatBGM(_ notification: Notification) {
        self.player?.seek(to: kCMTimeZero)
        self.player?.play()
    }
    
    fileprivate func restartObjects() {
        self.score = Int(0)
        self.scoreLabel.text = "\(score)m"
        self.gameOverImage.isHidden = true
        
        // iPhoneX
        self.createGround(self.frame.origin.y)
        self.createGround(-self.frame.origin.y)
        
        self.timer = Timer.scheduledTimer(
            timeInterval: 1.8,
            target: self,
            selector: #selector(createPipe),
            userInfo: nil,
            repeats: true
        )
        
        self.gameTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(updateScore),
            userInfo: nil,
            repeats: true
        )
        
        let birdTexture = SKTexture(imageNamed: "bird0")
        self.bird = SKSpriteNode(texture: birdTexture)
        self.bird.size = CGSize(width: 100, height: 100)
        self.bird.position = CGPoint(
            x: 0 - (self.frame.width / 2) + (self.bird.frame.width / 1.5),
            y: self.frame.midY + 300
        )
        self.bird.physicsBody = SKPhysicsBody(circleOfRadius: self.bird.size.height / 2)
        self.bird.physicsBody?.isDynamic = true
        self.bird.physicsBody?.allowsRotation = false
        self.bird.physicsBody?.categoryBitMask = 1
        self.bird.physicsBody?.collisionBitMask = 2
        self.bird.physicsBody?.contactTestBitMask = 2
        self.bird.zPosition = 15
        self.addChild(self.bird)
    }
    
    fileprivate func createGround(_ y: CGFloat) {
        let ground = SKNode()
        ground.position = CGPoint(x: 0, y: y)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: 1))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = 2
        ground.zPosition = 1
        self.blockingObjects.addChild(ground)
    }
    
    @objc func updateScore() {
        self.score = self.score + 1
        self.scoreLabel.text = "\(score)m"
    }
    
    @objc func createPipe() {
        let randamLength = arc4random() % UInt32(self.frame.size.height / 2)
        let offset = CGFloat(randamLength) - (self.frame.size.height / 4)
        let gap = self.bird.size.height * self.space
        let pipeTopTexture = SKTexture(imageNamed: "pipeTop")
        let pipeTop = SKSpriteNode(texture: pipeTopTexture)
        pipeTop.position = CGPoint(
            x: self.frame.midX + (self.frame.width / 2),
            y: self.frame.midY + (pipeTop.size.height / 2) + (gap / 2) + offset
        )
        pipeTop.physicsBody = SKPhysicsBody(rectangleOf: pipeTop.size)
        pipeTop.physicsBody?.isDynamic = false
        pipeTop.zPosition = 15
        pipeTop.physicsBody?.categoryBitMask = 2
        self.blockingObjects.addChild(pipeTop)
        
        let pipeBottomTexture = SKTexture(imageNamed: "pipeBottom")
        let pipeBottom = SKSpriteNode(texture: pipeBottomTexture)
        pipeBottom.position = CGPoint(
            x: self.frame.midX + (self.frame.width / 2),
            y: self.frame.midY - (pipeBottom.size.height / 2) - (gap / 2) + offset
        )
        pipeBottom.physicsBody = SKPhysicsBody(rectangleOf: pipeBottom.size)
        pipeBottom.physicsBody?.isDynamic = false
        pipeBottom.zPosition = 15
        pipeBottom.physicsBody?.categoryBitMask = 2
        self.blockingObjects.addChild(pipeBottom)
        
        let pipeMove = SKAction.moveBy(x: -self.frame.size.width - 100, y: 0, duration: 3)
        pipeTop.run(pipeMove, completion: {
            pipeTop.removeFromParent()
        })
        pipeBottom.run(pipeMove, completion: {
            pipeBottom.removeFromParent()
        })
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        self.run(self.gameoverSound, withKey: "gameoverSound")
        
        self.timer.invalidate()
        self.gameTimer.invalidate()
        self.blockingObjects.removeAllChildren()
        self.bird.removeFromParent()
        self.gameOverImage.isHidden = false
        
        let userDefaults = UserDefaults.standard
        let bestScore = userDefaults.object(forKey: "saveData") as! String
        if self.score > Int(bestScore)! {
            userDefaults.set(String(self.score), forKey: "saveData")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.gameOverImage.isHidden == false {
            self.gameOverImage.isHidden = true
            self.restartObjects()
        } else {
            self.bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            // サイズに応じて重力は変えてね
            self.bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 200))
            self.run(self.jumpSound, withKey: "jumpSound")
            self.bird.run(self.birdAnimation)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
