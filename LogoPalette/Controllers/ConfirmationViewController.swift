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

    var results:[VNClassificationObservation]?
    @IBOutlet weak var debugView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.debugView.text = ""
        print("THIS IS BEING PRINTED IN THE SECOND VD ********************************************************")
        print("THIS IS BEING PRINTED IN THE SECOND VD ********************************************************")
        print(results!)
        
        
        if let firstResult = results?.prefix(4) {
            var description = firstResult.map { classification in
                return "\(Int(classification.confidence*100))% \(classification.identifier)"
            }
            self.debugView.text.append(description.joined(separator: "\n"))
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
