//
//  GameViewController.swift
//  Flappy
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    @IBAction func close(_ sender: Any) {
        if let view = self.view as! SKView?, let scene = view.scene as? GameScene {
            scene.close()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if let view = self.view as! SKView?, let scene = SKScene(fileNamed: "GameScene") {
            
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
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    // 画面の自動回転をさせない
    override var shouldAutorotate: Bool {
        get {
            return false
        }
    }
    
    // 画面をPortraitに指定する
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait
        }
    }

    // ステータスバーを非表示
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
