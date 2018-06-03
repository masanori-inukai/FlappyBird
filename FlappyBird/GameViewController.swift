//
//  GameViewController.swift
//  Flappy
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

//    @IBAction func close(_ sender: Any) {
//        if let view = self.view as? SKView, let scene = view.scene as? GameScene {
//            scene.close()
//        }
//        self.navigationController?.popViewController(animated: true)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if let view = self.view as? SKView, let scene = SKScene(fileNamed: "GameScene") as? GameScene {
            
            if UIDevice.current.model.range(of: "iPad") != nil {
                print("iPad")
                scene.scaleMode = .fill
            } else {
                // iPhoneX
                if UIScreen.main.nativeBounds.height == 2436.0 {
                    scene.size = CGSize(width: 750, height: 1624)
                }
                scene.scaleMode = .aspectFill
            }
            scene.gameDelegate = self
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
}

extension GameViewController: GameSceneDelegate {
    
    func close() {
        self.navigationController?.popViewController(animated: true)
    }
}
