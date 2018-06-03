//
//  GameViewController.swift
//  Flappy
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    var difficulty = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard
            let view = self.view as? SKView,
            let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
                return
        }
    
        if UIDevice.current.model.range(of: "iPad") != nil {
            scene.scaleMode = .fill
        } else {
            // iPhoneX
            if UIScreen.main.nativeBounds.height == 2436.0 {
                scene.size = CGSize(width: 750, height: 1624)
            }
            scene.scaleMode = .aspectFill
        }
        scene.gameDelegate = self
        scene.difficulty = self.difficulty
        view.presentScene(scene)
        view.ignoresSiblingOrder = true
        view.showsFPS = true
        view.showsNodeCount = true
    }
}

extension GameViewController: GameSceneDelegate {
    
    func close() {
        self.navigationController?.popViewController(animated: true)
    }
}
