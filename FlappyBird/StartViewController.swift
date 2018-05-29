//
//  StartViewController.swift
//  Flappy
//

import UIKit

class StartViewController: UIViewController {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userDefaults = UserDefaults.standard
        if userDefaults.object(forKey: "saveData") == nil {
            userDefaults.set("0", forKey: "saveData")
        }
        
        let bestScore = Int(userDefaults.object(forKey: "saveData") as! String)!
        self.scoreLabel.text = "BestScore: \(bestScore)m"
        UIView.animate(withDuration: 1.0, animations: {
            self.logo.frame = CGRect(x: 16, y: 143, width: 343, height: 343)
        }, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        if let gameVC = storyBoard.instantiateViewController(withIdentifier: "GameVC") as? GameViewController {
                self.navigationController?.pushViewController(gameVC, animated: true)
        }
    }
    
    @IBAction func resetScore(_ sender: Any) {
        let userDefaults = UserDefaults.standard
        userDefaults.set("0", forKey: "saveData")
        self.scoreLabel.text = "BestScore: 0m"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let userDefaults = UserDefaults.standard
        if let score = userDefaults.object(forKey: "saveData") {
            self.scoreLabel.text = "BestScore: \(score)m"
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
}
