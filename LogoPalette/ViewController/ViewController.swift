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
    
    @IBOutlet weak var photoDisplay: UIImageView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        
        buttonStyling()
    }
    
    //MARK:- Button Click Events
    
    @IBAction func palletTapped(_ sender: UIBarButtonItem){
        let vc = Screen2()
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func onCameraClick(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func onUploadClick(_ sender: Any){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //MARK:- Functions
    
    func detect(image:CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else{
            fatalError("loading CoreML model failed")
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("error reading the request results")
            }
            print(results)
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    // MARK:  Styling
    
    func buttonStyling()
    {
        uploadButton.layer.cornerRadius = uploadButton.bounds.height/2
        cameraButton.layer.cornerRadius = cameraButton.bounds.height/2
        
        uploadButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        cameraButton.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 25)
    }
    
}
 //MARK:- Extensions

extension ViewController: UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userEditedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            photoDisplay.image = userEditedImage
            guard let ciimage = CIImage(image: userEditedImage) else {
                fatalError("Error while converting image to ciimage")
            }
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

