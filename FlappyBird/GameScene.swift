//
//  GameScene.swift
//  Flappy
//

import SpriteKit
import GameplayKit
import AVKit

protocol GameSceneDelegate: class {
    func close() -> Void
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    weak var gameDelegate: GameSceneDelegate? = nil
    var difficulty = 0
    
    fileprivate var initiated = false
    fileprivate var pipeSpace = CGFloat(0.0)
    fileprivate var pipeDuration = TimeInterval(0.0)
    fileprivate var bgmName = ""
    fileprivate var score = Int(0)
    fileprivate var player: AVPlayer? = nil
    
    fileprivate var bird = SKSpriteNode()
    fileprivate var birdAnimation = SKAction()
    fileprivate var gameOverImage = SKSpriteNode()
    fileprivate var blockingObjects = SKNode()
    fileprivate var scoreLabel = SKLabelNode()
    fileprivate var closeButton = SKSpriteNode()
    
    fileprivate var timer = Timer()
    fileprivate var gameTimer = Timer()
    
    fileprivate let jumpSound = SKAction.playSoundFileNamed("jump.mp3", waitForCompletion: false)
    fileprivate let gameoverSound = SKAction.playSoundFileNamed("gameover.mp3", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        if !self.initiated {
            self.initObjects()
            self.initiated = true
        }
        self.restartObjects()
    }
    
    func close() {
        let userDefaults = UserDefaults.standard
        let bestScore = userDefaults.object(forKey: "Score_\(self.difficulty)") as! String
        if self.score > Int(bestScore)! {
            userDefaults.set(String(self.score), forKey: "Score_\(self.difficulty)")
        }
        self.player?.pause()
        self.removeAllChildren()
        self.removeAllActions()
        self.gameDelegate?.close()
    }
    
    fileprivate func initObjects() {
        
        switch self.difficulty {
            case 0:
                self.bgmName = "bgSound1.mp3"
                self.pipeSpace = 1.5
                self.pipeDuration = 4.0
            case 1:
                self.bgmName = "bgSound2.mp3"
                self.pipeSpace = 1.25
                self.pipeDuration = 3.5
            case 2:
                self.bgmName = "bgSound3.mp3"
                self.pipeSpace = 1.15
                self.pipeDuration = 3.2
            default:
                self.bgmName = "bgSound1.mp3"
                self.pipeSpace = 1.5
                self.pipeDuration = 4.0
            break
        }
        
        self.player = AVPlayer(url: Bundle.main.bundleURL.appendingPathComponent(self.bgmName))
        self.player?.seek(to: kCMTimeZero)
        self.player?.play()
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(repeatBGM),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: self.player?.currentItem
        )
        
        let bgView1 = SKSpriteNode(imageNamed: "Bg")
        bgView1.position = CGPoint(x: 0, y: 0)
        bgView1.size.height = self.size.height
        bgView1.size.width = self.size.width
        bgView1.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.moveTo(x: -self.size.width, duration: 4.0),
            SKAction.moveTo(x: 0, duration: 0.0)
        ])))
        self.addChild(bgView1)
        
        let bgView2 = SKSpriteNode(imageNamed: "Bg")
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

        self.initLabel()
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -8)
        
        self.gameOverImage = SKSpriteNode()
        let gameOverTexture = SKTexture(imageNamed: "Gameover")
        self.gameOverImage = SKSpriteNode(texture: gameOverTexture)
        self.gameOverImage.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.gameOverImage.zPosition = 21
        self.gameOverImage.isHidden = true
        self.addChild(self.gameOverImage)
        
        self.blockingObjects = SKSpriteNode()
        self.addChild(self.blockingObjects)
        
        self.initSpriteAnimate()
    }
    
    fileprivate func initLabel() {
        self.score = Int(0)
        self.scoreLabel = SKLabelNode()
        self.scoreLabel.text = "\(self.score)m"
        self.scoreLabel.color = .white
        self.scoreLabel.zPosition = 20
        self.scoreLabel.position = CGPoint(x: 0, y: self.size.height / 2 - 150)
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
        self.addChild(self.scoreLabel)
        
        self.closeButton = SKSpriteNode(texture: SKTexture(imageNamed: "CloseButton"))
        self.closeButton.size = CGSize(width: 60, height: 60)
        self.closeButton.position = CGPoint(x: self.size.width / 2 - 60, y: self.size.height / 2 - 120)
        self.closeButton.zPosition = 20
        self.closeButton.name = "closeButton"
        self.addChild(self.closeButton)
    }
    
    fileprivate func initSpriteAnimate() {
        let atlas = SKTextureAtlas(named: "Bird")
        var birdTexture = [SKTexture]()
        for i in 0...3 {
            birdTexture.append(atlas.textureNamed("Bird" + String(i)))
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
        
        self.createGround(self.frame.origin.y)
        self.createGround(-self.frame.origin.y)
        
        self.timer = Timer.scheduledTimer(
            timeInterval: 1.8,
            target: self,
            selector: #selector(createBlock),
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
        
        let birdTexture = SKTexture(imageNamed: "Bird0")
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
    
    @objc func createBlock() {
        let randamLength = arc4random() % UInt32(self.frame.size.height / 4)
        let offset = CGFloat(randamLength) - (self.frame.size.height / 4)
        let gap = (self.bird.size.height * 2) * self.pipeSpace
        let positionX = self.frame.midX + (self.frame.width / 2)
        
        let blockT = SKSpriteNode(texture: SKTexture(imageNamed: "BlockT"))
        blockT.position = CGPoint(
            x: positionX,
            y: self.frame.midY + (blockT.size.height / 2) + (gap / 2) + offset
        )
        blockT.physicsBody = SKPhysicsBody(rectangleOf: blockT.size)
        blockT.physicsBody?.isDynamic = false
        blockT.zPosition = 15
        blockT.physicsBody?.categoryBitMask = 2
        self.blockingObjects.addChild(blockT)
        
        let blockB = SKSpriteNode(texture: SKTexture(imageNamed: "BlockB"))
        blockB.position = CGPoint(
            x: positionX,
            y: self.frame.midY - (blockB.size.height / 2) - (gap / 2) + offset
        )
        blockB.physicsBody = SKPhysicsBody(rectangleOf: blockB.size)
        blockB.physicsBody?.isDynamic = false
        blockB.zPosition = 15
        blockB.physicsBody?.categoryBitMask = 2
        self.blockingObjects.addChild(blockB)
        
        let movePointX = -self.frame.size.width * 2 + 200
        let moveT = SKAction.moveBy(x: movePointX, y: 0, duration: self.pipeDuration)
        let moveB = SKAction.moveBy(x: movePointX, y: 0, duration: self.pipeDuration)
        blockT.run(moveT) { blockT.removeFromParent() }
        blockB.run(moveB) { blockB.removeFromParent() }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        self.run(self.gameoverSound, withKey: "gameoverSound")
        
        self.timer.invalidate()
        self.gameTimer.invalidate()
        self.blockingObjects.removeAllChildren()
        self.bird.removeFromParent()
        self.gameOverImage.isHidden = false
        
        let userDefaults = UserDefaults.standard
        let bestScore = userDefaults.object(forKey: "Score_\(self.difficulty)") as! String
        if self.score > Int(bestScore)! {
            userDefaults.set(String(self.score), forKey: "Score_\(self.difficulty)")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // 閉じるが押されたとき
        if let touch = touches.first as UITouch? {
            let location = touch.location(in: self)
            if self.atPoint(location).name == "closeButton" {
                self.close()
                return
            }
        }
        
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
        // NOP
    }
}
