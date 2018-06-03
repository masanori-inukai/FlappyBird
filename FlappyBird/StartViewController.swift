//
//  StartViewController.swift
//  Flappy
//

import UIKit

class StartViewController: UIViewController {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var stageSelect: UISegmentedControl!
    
    @IBAction func changeStage(_ sender: UISegmentedControl) {
        self.initScore()
    }
    
    fileprivate func initScore() {
        let difficulty = self.stageSelect.selectedSegmentIndex
        
        let userDefaults = UserDefaults.standard
        if userDefaults.object(forKey: "Score_\(difficulty)") == nil {
            userDefaults.set("0", forKey: "Score_\(difficulty)")
        }
        
        let bestScore = Int(userDefaults.object(forKey: "Score_\(difficulty)") as! String)!
        self.scoreLabel.text = "BestScore: \(bestScore)m"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initScore()
        
        UIView.animate(withDuration: 1.0, animations: {
            self.logo.frame = CGRect(x: 16, y: 143, width: 343, height: 343)
        }, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        if let gameVC = storyBoard.instantiateViewController(withIdentifier: "GameVC") as? GameViewController {
            gameVC.difficulty = self.stageSelect.selectedSegmentIndex
                self.navigationController?.pushViewController(gameVC, animated: true)
        }
    }
    
    @IBAction func resetScore(_ sender: Any) {
        let difficulty = self.stageSelect.selectedSegmentIndex
        
        let userDefaults = UserDefaults.standard
        userDefaults.set("0", forKey: "Score_\(difficulty)")
        self.scoreLabel.text = "BestScore: 0m"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.initScore()
    }
}
