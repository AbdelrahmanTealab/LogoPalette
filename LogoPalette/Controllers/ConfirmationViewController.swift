//
//  ConfirmationViewController.swift
//  LogoPalette
//
//  Created by Abdelrahman  Tealab on 2021-03-27.
//

import UIKit
import CoreML
import Vision

class ConfirmationViewController: UIViewController {

    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    
    var results:[VNClassificationObservation]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        if let allResults = results {
            var description = allResults.map { classification in
                return "\(Int(classification.confidence*100))% \(classification.identifier)"
            }
            let allButtons = [button1,button2,button3,button4]
            for button in allButtons {
                button?.setTitle(description[button!.tag], for: .normal)
            }
           // self.debugView.text.append(description.joined(separator: "\n"))
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
