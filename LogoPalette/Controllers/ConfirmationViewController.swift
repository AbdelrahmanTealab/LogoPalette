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

    @IBOutlet weak var imageViewDisplay: UIImageView!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!

    @IBOutlet weak var paletteSegment: UISegmentedControl!
    
    @IBOutlet weak var footerView: UIView!
    var results:[VNClassificationObservation]?
    var imageForDisplay:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        imageViewDisplay.image = imageForDisplay
        footerView.layer.shadowColor = UIColor.black.cgColor
        footerView.layer.shadowOpacity = 1
        footerView.layer.shadowOffset = CGSize(width: 0, height: -5.0)
        footerView.layer.shadowRadius = 2
        footerView.layer.zPosition = 1
        
        
        let allButtons = [button1,button2,button3,button4]
        if let allResults = results {
            let description = allResults.map { classification in
                return "\(Int(classification.confidence*100))% \(classification.identifier)"
            }
            for button in allButtons {
                button?.setTitle(description[button!.tag], for: .normal)
                beautifyButton(button!)
            }
        }
    }
    
    @IBAction func logoButtonSelected(_ sender: UIButton) {
        let allButtons = [button1,button2,button3,button4]
        sender.isSelected = true
        for button in allButtons{
            if button != sender {
                button?.isSelected = false
            }
        }
    }
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        let allButtons = [button1,button2,button3,button4]
        for button in allButtons {
            if ((button?.isSelected) != nil) {
                self.dismiss(animated: true, completion: nil)
            }
            else{
                let alert = UIAlertController(title: "Alert", message: "You have to choose one of the predicted logos", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }

    }
    
    //MARK: - Button Functions
    
    func beautifyButton(_ button: UIButton){
        button.setBackgroundColor(color: #colorLiteral(red: 0.8837431073, green: 1, blue: 1, alpha: 1), forState: .selected)
        button.backgroundColor = UIColor(red: 171/255, green: 178/255, blue: 186/255, alpha: 1.0)
        // Shadow Color and Radius
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowOffset = CGSize(width: 2.0, height: 3.0)
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 0.0
        button.layer.masksToBounds = false
        button.layer.cornerRadius = 4.0
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.shouldRasterize = true
        button.layer.rasterizationScale = UIScreen.main.scale
    }

}

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        self.clipsToBounds = true  // add this to maintain corner radius
        self.layer.masksToBounds = true

        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: forState)
        }
    }
}

