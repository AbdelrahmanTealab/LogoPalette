//
//  ViewController.swift
//  LogoPalette
//
//  Created by Abdelrahman  Tealab on 2021-03-26.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController,UINavigationControllerDelegate {
    
    @IBOutlet weak var albumButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let imagePicker = UIImagePickerController()
    let palettes = [["logo":"logo","title":"default1","color1":0x123456,"color2":0x123456,"color3":0x123456,"color4":0x123456,"color5":0x123456],["logo":"logo","title":"default2","color1":0xabcdef,"color2":0x14ba29,"color3":0xabcdef,"color4":0x9afef1,"color5":0xabcdef],["logo":"logo","title":"defaul3","color1":0x123456,"color2":0xabcdef,"color3":0x123456,"color4":0xabcdef,"color5":0x123456]]
    
    var mlResults = Array<VNClassificationObservation>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        

    }
    
    //MARK:- Button Click Events

    @IBAction func cameraTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func albumTapped(_ sender: Any){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //MARK:- Functions
    
    func detect(image:CIImage) {
        
        guard let model = try? VNCoreMLModel(for: LogoIdentifier_1().model) else{
            fatalError("loading CoreML model failed")
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("error reading the request results")
            }
            self.mlResults = results
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if(segue.identifier == Constants.segueIdentifier) {
                let destinationVC = (segue.destination as! ConfirmationViewController)
                destinationVC.results = (sender as! [VNClassificationObservation])
            }
        }
    
}
 //MARK:- Extensions

extension ViewController: UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userEditedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            guard let ciimage = CIImage(image: userEditedImage) else {
                fatalError("Error while converting image to ciimage")
            }
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true) {
            self.performSegue(withIdentifier: Constants.segueIdentifier, sender: self.mlResults)
        }
    }
}

extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return palettes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let palette = palettes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! paletteCell
        cell.cellLogo.image = UIImage(named: palette["logo"]! as! String)
        
        cell.cellColor1.backgroundColor = UIColor(hex: palette["color1"]! as! Int)
        cell.cellColor1.text = "#"+String(format:"%02X",palette["color1"]! as! Int)
        
        cell.cellColor2.backgroundColor = UIColor(hex: palette["color2"]! as! Int)
        cell.cellColor2.text = "#"+String(format:"%02X",palette["color2"]! as! Int)

        cell.cellColor3.backgroundColor = UIColor(hex: palette["color3"]! as! Int)
        cell.cellColor3.text = "#"+String(format:"%02X",palette["color3"]! as! Int)

        cell.cellColor4.backgroundColor = UIColor(hex: palette["color4"]! as! Int)
        cell.cellColor4.text = "#"+String(format:"%02X",palette["color4"]! as! Int)

        cell.cellColor5.backgroundColor = UIColor(hex: palette["color5"]! as! Int)
        cell.cellColor5.text = "#"+String(format:"%02X",palette["color5"]! as! Int)


//        if message.sender == Auth.auth().currentUser?.email{
//            cell.leftImageView.isHidden = true
//            cell.rightImage.isHidden = false
//            cell.messageBubble.backgroundColor = UIColor(named: Constants.BrandColors.lightPurple)
//            cell.label.textColor = UIColor(named: Constants.BrandColors.purple)
//        }
//        else{
//            cell.leftImageView.isHidden = false
//            cell.rightImage.isHidden = true
//            cell.messageBubble.backgroundColor = UIColor(named: Constants.BrandColors.purple)
//            cell.label.textColor = UIColor(named: Constants.BrandColors.lightPurple)        }
        return cell
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

   convenience init(hex: Int) {
       self.init(
           red: (hex >> 16) & 0xFF,
           green: (hex >> 8) & 0xFF,
           blue: hex & 0xFF
       )
   }
}

