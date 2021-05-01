//
//  LoginViewController.swift
//  LogoPalette
//
//  Created by Abdelrahman  Tealab on 2021-04-11.
//

import UIKit
import Firebase


class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    

    @IBAction func loginPressed(_ sender: UIButton) {
        if let email = emailTextfield.text, let password = passwordTextfield.text{
            Auth.auth().signIn(withEmail: email, password: password) {authResult, error in
                if let e = error{
                    print(e)
                    let alert = UIAlertController(title: "ERROR", message: e.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                else{
                    self.performSegue(withIdentifier: Constants.loginSegue, sender: self)
                }
            }
        }
    }
    
}

