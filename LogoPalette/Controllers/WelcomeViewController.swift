//
//  WelcomeViewController.swift
//  LogoPalette
//
//  Created by Abdelrahman  Tealab on 2021-04-11.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "🎨 LogoPalette"
        titleLabel.text = ""
        var charIndex = 0.0

        for letter in "🎨 LogoPalette"{

            Timer.scheduledTimer(withTimeInterval: 0.1 * charIndex, repeats: false) { (timer) in self.titleLabel.text?.append(letter)
            }
            charIndex+=1
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false

    }
}
