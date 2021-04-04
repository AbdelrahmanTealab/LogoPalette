//
//  ConfirmationViewController.swift
//  LogoPalette
//
//  Created by Abdelrahman  Tealab on 2021-03-27.
//

import UIKit
import CoreML
import Vision
import Palette
import Firebase
import FirebaseUI
import SDWebImage

class ConfirmationViewController: UIViewController {

    @IBOutlet weak var imageViewDisplay: UIImageView!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!

    @IBOutlet weak var customLogo: UIImageView!
    @IBOutlet weak var customVibrantColor: UILabel!
    @IBOutlet weak var customDarkVibrantColor: UILabel!
    @IBOutlet weak var customLightVibrantColor: UILabel!
    @IBOutlet weak var customLightMutedColor: UILabel!
    @IBOutlet weak var customDarkMutedColor: UILabel!
    
    @IBOutlet weak var originalLogo: UIImageView!
    @IBOutlet weak var originalVibrantColor: UILabel!
    @IBOutlet weak var originalDarkVibrantColor: UILabel!
    @IBOutlet weak var originalLightVibrantColor: UILabel!
    @IBOutlet weak var originalLightMutedColor: UILabel!
    @IBOutlet weak var originalDarkMutedColor: UILabel!
    
    @IBOutlet weak var paletteSegment: UISegmentedControl!

    @IBOutlet weak var footerView: UIView!
    
    var results:[VNClassificationObservation]?
    var imageForDisplay:UIImage?
    var customPalleteSwatch = [String:String]()
    
    let storageRef = Storage.storage().reference()
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUi()
        generateCustomPalette()
        setupUiButtons()
        generateOriginalPalette(name: button1.currentTitle ?? "logo")
    }
    func setupUi(){
        imageViewDisplay.image = imageForDisplay
        footerView.layer.shadowColor = UIColor.darkGray.cgColor
        footerView.layer.shadowOpacity = 0.9
        footerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        footerView.layer.shadowRadius = 4
        footerView.layer.zPosition = 1
    }
    
    func generateCustomPalette() {
        customLogo.image = imageForDisplay!
        Palette.from(image: imageForDisplay!).generate { [self] in
            customVibrantColor.backgroundColor = $0.vibrantColor
            customVibrantColor.text =  customVibrantColor.backgroundColor?.htmlRGBColor.uppercased()
            customPalleteSwatch["vibrantColor"]=customVibrantColor.backgroundColor?.htmlRGBColor.uppercased()
        }
        Palette.from(image: imageForDisplay!).generate { [self] in
            customDarkVibrantColor.backgroundColor = $0.darkVibrantColor
            customDarkVibrantColor.text =  customDarkVibrantColor.backgroundColor?.htmlRGBColor.uppercased()
            customPalleteSwatch["darkVibrantColor"]=customDarkVibrantColor.backgroundColor?.htmlRGBColor.uppercased()
        }
        Palette.from(image: imageForDisplay!).generate { [self] in
            customLightVibrantColor.backgroundColor = $0.lightVibrantColor
            customLightVibrantColor.text =  customLightVibrantColor.backgroundColor?.htmlRGBColor.uppercased()
            customPalleteSwatch["lightVibrantColor"]=customLightVibrantColor.backgroundColor?.htmlRGBColor.uppercased()
        }
        Palette.from(image: imageForDisplay!).generate { [self] in
            customLightMutedColor.backgroundColor = $0.lightMutedColor
            customLightMutedColor.text =  customLightMutedColor.backgroundColor?.htmlRGBColor.uppercased()
            customPalleteSwatch["lightMutedColor"]=customLightMutedColor.backgroundColor?.htmlRGBColor.uppercased()
        }
        Palette.from(image: imageForDisplay!).generate { [self] in
            customDarkMutedColor.backgroundColor = $0.darkMutedColor
            customDarkMutedColor.text =  customDarkMutedColor.backgroundColor?.htmlRGBColor.uppercased()
            customPalleteSwatch["darkMutedColor"]=customDarkMutedColor.backgroundColor?.htmlRGBColor.uppercased()
        }
    }
    

    func setupUiButtons() {
        let allButtons = [button1,button2,button3,button4]
        if let allResults = results {
            let description = allResults.map { classification in
                return "\(classification.identifier)"
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
        generateOriginalPalette(name: sender.currentTitle ?? "logo")
    }
    
    func generateOriginalPalette(name:String) {
        
        db.collection("original palettes").whereField("name", isEqualTo: name)
            .getDocuments() { [self] (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        if let name = data["name"] as? String,let vibrant = data["vibrantColor"] as? String,let darkVibrant = data["darkVibrantColor"] as? String,let lightVibrant = data["lightVibrantColor"] as? String, let lightMuted = data["lightMutedColor"] as? String, let darkMuted = data["darkMutedColor"] as? String{
                            
                            DispatchQueue.main.async {
                                originalVibrantColor.backgroundColor = hexStringToUIColor(hex: vibrant)
                                originalVibrantColor.text = originalVibrantColor.backgroundColor?.htmlRGBColor.uppercased()
                                
                                originalLightVibrantColor.backgroundColor = hexStringToUIColor(hex: darkVibrant)
                                originalLightVibrantColor.text = originalLightVibrantColor.backgroundColor?.htmlRGBColor.uppercased()

                                originalDarkVibrantColor.backgroundColor = hexStringToUIColor(hex: lightVibrant)
                                originalDarkVibrantColor.text = originalDarkVibrantColor.backgroundColor?.htmlRGBColor.uppercased()

                                originalLightMutedColor.backgroundColor = hexStringToUIColor(hex: lightMuted)
                                originalLightMutedColor.text = originalLightMutedColor.backgroundColor?.htmlRGBColor.uppercased()

                                originalDarkMutedColor.backgroundColor = hexStringToUIColor(hex: darkMuted)
                                originalDarkMutedColor.text = originalDarkMutedColor.backgroundColor?.htmlRGBColor.uppercased()
                            }
                        }
                    }
                }
        }
        var logoURL = ""
        storageRef.child("original_logos/").child("\(name).png").downloadURL { (url, err) in
            if err != nil{
                print(err?.localizedDescription)
            }
            logoURL = "\(url!)"
            print(logoURL)
            self.originalLogo.sd_setImage(with: URL(string:logoURL), placeholderImage: UIImage(named: "logo.png"))
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
        button.backgroundColor = UIColor(red: 171/255, green: 178/255, blue: 186/255, alpha: 1.0)
        // Shadow Color and Radius
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowOffset = CGSize(width: 2.0, height: 3.0)
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 20
        button.layer.masksToBounds = false
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.shouldRasterize = true
        button.layer.rasterizationScale = UIScreen.main.scale
        button.setBackgroundColor(color: #colorLiteral(red: 0.8837431073, green: 1, blue: 1, alpha: 1), forState: .selected)

    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if (cString.hasPrefix("0X")) {
            cString = cString.removeTheFirst(length: 2)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }
        

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}

extension String {
  func removeTheFirst(length:Int) -> String {
            if length <= 0 {
                return self
            } else if let to = self.index(self.startIndex, offsetBy: length, limitedBy: self.endIndex) {
                return self.substring(from: to)

            } else {
                return ""
            }
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

extension UIColor {
    
    var rgbComponents:(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return (r,g,b,a)
        }
        return (0,0,0,0)
    }
    // hue, saturation, brightness and alpha components from UIColor**
    var hsbComponents:(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var hue:CGFloat = 0
        var saturation:CGFloat = 0
        var brightness:CGFloat = 0
        var alpha:CGFloat = 0
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha){
            return (hue,saturation,brightness,alpha)
        }
        return (0,0,0,0)
    }
    var htmlRGBColor:String {
        return String(format: "#%02x%02x%02x", Int(rgbComponents.red * 255), Int(rgbComponents.green * 255),Int(rgbComponents.blue * 255))
    }
    var htmlRGBaColor:String {
        return String(format: "#%02x%02x%02x%02x", Int(rgbComponents.red * 255), Int(rgbComponents.green * 255),Int(rgbComponents.blue * 255),Int(rgbComponents.alpha * 255) )
    }
}
