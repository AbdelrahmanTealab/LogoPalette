//
//  ViewController.swift
//  LogoPalette
//
//  Created by Abdelrahman  Tealab on 2021-03-26.
//

import UIKit
import CoreML
import Vision
import Firebase
import Firebase
import FirebaseUI
import SDWebImage
import Kingfisher

class ViewController: UIViewController,UINavigationControllerDelegate {
    
    @IBOutlet weak var albumButton: UIButton!
    @IBOutlet weak var albumButtonLandscape: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var cameraButtonLandscape: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var footerView: UIView!
    
    let storageRef = Storage.storage().reference()
    let db = Firestore.firestore()
    
    let imagePicker = UIImagePickerController()
    var palettes: Array<UserPalettes> = Array<UserPalettes>()
    
    var mlResults = Array<VNClassificationObservation>()
    var editedImage = UIImage()
    
    var refresh = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
        
        refresh.addTarget(self, action: #selector(ViewController.loadData), for: .valueChanged)
        tableView.addSubview(refresh)
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        
        addShadows(footerView)
        addShadows(albumButton)
        addShadows(albumButtonLandscape)
        addShadows(cameraButton)
        addShadows(cameraButtonLandscape)

        loadData()
    }
    
    func addShadows(_ view:UIView) {
        view.layer.shadowColor = UIColor.darkGray.cgColor
        view.layer.shadowOpacity = 0.9
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 4
        view.layer.zPosition = 1
    }
    
    //MARK:- Button Click Events

    @IBAction func cameraTapped(_ sender: Any) {
        imagePicker.sourceType = .camera
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
    
    //MARK: - swipe functions
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
            let currentPalette = palettes[indexPath.row]
            let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
                self.db.collection(Constants.FStore.userCollection).document(currentPalette.docID).delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                    }
                }
                completion(true)
            }
            action.image = UIImage(systemName: "trash.slash")
            action.backgroundColor = .red
            return action
        }
    
    //MARK:- Functions
    
    //function to detect image logo
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
    
    //prepare for segue with AI results and image chosen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if(segue.identifier == Constants.segueIdentifier) {
                guard let segueData = sender as? TransferData
                    else { return }
                    if let secondVC = segue.destination as? ConfirmationViewController {
                        secondVC.results = segueData.results
                        secondVC.imageForDisplay = segueData.image
                    }
            }
        }
    
    
    //function to logout
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        do {
          try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
    }
    
    //function to load the data from firebase
    @objc func loadData() {
        db.collection(Constants.FStore.userCollection).whereField("owner", isEqualTo: (Auth.auth().currentUser?.email)!).addSnapshotListener { (querySnapshot, error) in
            if let e = error{
                print(e)
                let alert = UIAlertController(title: "ERROR", message: e.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
            }
            else{
                if let snapshotDocs =  querySnapshot?.documents {
                    self.palettes.removeAll()
                    for doc in snapshotDocs{
                        let data = doc.data()
                        if let darkVibrantColor = data["darkVibrantColor"] as? String,
                           let lightVibrantColor = data["lightVibrantColor"] as? String,
                           let vibrantColor = data["vibrantColor"] as? String,
                           let lightMutedColor = data["lightMutedColor"] as? String,
                           let darkMutedColor = data["darkMutedColor"] as? String,
                           let imageURL = data["imageURL"] as? String,
                           let docID = data["docID"] as? String,
                           let logo = data["logo"] as? Data
                           {
                            if let url = URL(string: imageURL), let mylogo = UIImage(data: logo){
                                let newUserPalette = UserPalettes(docID:docID,imageURL: url, logo: mylogo, darkVibrantColor: darkVibrantColor, lightVibrantColor: lightVibrantColor, vibrantColor: vibrantColor, lightMutedColor: lightMutedColor, darkMutedColor: darkMutedColor)
                                self.palettes.append(newUserPalette)

                            }

                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                            self.refresh.endRefreshing()
                        }
                    }
                }
            }
        }
        
    }
    
    //function to parse a hex string to a color
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
 //MARK:- Extensions

extension ViewController: UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userEditedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.editedImage = userEditedImage
            guard let ciimage = CIImage(image: userEditedImage) else {
                fatalError("Error while converting image to ciimage")
            }
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true) {
            let transferData = TransferData(results: self.mlResults, image: self.editedImage)
            self.performSegue(withIdentifier: Constants.segueIdentifier, sender: transferData)
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return palettes.count
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! paletteCell
        
        let currentPalette = palettes[indexPath.row]
        cell.cellLogo.image = currentPalette.logo
            
        cell.cellColor1.backgroundColor = hexStringToUIColor(hex: currentPalette.vibrantColor)
        cell.cellColor1.text = cell.cellColor1.backgroundColor?.htmlRGBColor.uppercased()
        
        cell.cellColor2.backgroundColor = hexStringToUIColor(hex: currentPalette.darkVibrantColor)
        cell.cellColor2.text = cell.cellColor2.backgroundColor?.htmlRGBColor.uppercased()

        cell.cellColor3.backgroundColor = hexStringToUIColor(hex: currentPalette.lightVibrantColor)
        cell.cellColor3.text = cell.cellColor3.backgroundColor?.htmlRGBColor.uppercased()

        cell.cellColor4.backgroundColor = hexStringToUIColor(hex: currentPalette.lightMutedColor)
        cell.cellColor4.text = cell.cellColor4.backgroundColor?.htmlRGBColor.uppercased()

        cell.cellColor5.backgroundColor = hexStringToUIColor(hex: currentPalette.darkMutedColor)
        cell.cellColor5.text = cell.cellColor5.backgroundColor?.htmlRGBColor.uppercased()

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

struct TransferData {
    var results:[VNClassificationObservation]
    var image:UIImage
}
