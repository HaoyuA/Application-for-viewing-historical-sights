//
//  EditSightViewController.swift
//  FIT5140-Assign1
//
//  Created by 张昊宇 on 6/9/19.
//  Copyright © 2019 Haoyu Zhang. All rights reserved.
//

import UIKit
import MapKit

class EditSightViewController: UIViewController,CLLocationManagerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    weak var databaseController: DatabaseProtocol?
    var currentLocation: CLLocationCoordinate2D?
    var locationManager: CLLocationManager = CLLocationManager()
    var location: LocationAnnotation?
    var sightForEdit: Sight?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var iconSegmentControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        // Do any additional setup after loading the view.
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last!
        currentLocation = location.coordinate
    }
    
    func loadData(){
        nameTextField.text = location?.title
        descriptionTextField.text = location?.subtitle
        longitudeTextField.text = "\(location?.coordinate.longitude ?? 0)"
        latitudeTextField.text = "\(location?.coordinate.latitude ?? 0)"
        let imageName = location?.image
        if (UIImage(named:"picture/"+imageName! ) != nil)
        {
           imageView.image = UIImage(named: "picture/"+imageName!)
        }
        else
        {
           imageView.image = loadImageData(fileName: imageName!)
        }
        
    }
    
    func displayMessage(_ message: String,_ title: String) {
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
                                                handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        displayMessage("There was an error in getting the image", "Error")
    }
    
    
    func displayMessage(title: String, message: String) {
        // Setup an alert to show user details about the Person
        // UIAlertController manages an alert instance
        let alertController = UIAlertController(title: title, message: message, preferredStyle:
            UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler:
            nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func updateSight(_ sender: Any) {
        guard let image = imageView.image else {
            displayMessage("Cannot save until a photo has been taken!", "Error")
            return
        }
        
        let date = UInt(Date().timeIntervalSince1970)
        var data = Data()
        data = image.jpegData(compressionQuality: 0.8)!
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                       .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        
        if let pathComponent = url.appendingPathComponent("\(date)") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            fileManager.createFile(atPath: filePath, contents: data,
                                   attributes: nil)
        }
        if nameTextField.text != "" && descriptionTextField.text != "" && longitudeTextField.text != "" && latitudeTextField.text != "" {
            databaseController!.deleteSight(sight: sightForEdit!)
            let index = iconSegmentControl.selectedSegmentIndex
            let icon: String
            switch index{
            case 0:
                icon = "icon7"
            case 1:
                icon = "icon5"
            case 2:
                icon = "icon4"
            case 3:
                icon = "icon6"
            default:
                icon = "icon7"
            }
            let _ = databaseController!.addSight(name: nameTextField.text!, desc: descriptionTextField.text!, latitude: Double(latitudeTextField.text!)!, longitude: Double(longitudeTextField.text!)!, icon: icon, photo: "\(date)")
            displayMessage("Sight updated!", "")
            
            return
        }
        
        var errorMsg = "Please ensure all fields are filled:\n"
        
        if nameTextField.text == "" {
            errorMsg += "- Must provide a name\n"
        }
        if descriptionTextField.text == "" {
            errorMsg += "- Must provide description"
        }
        if longitudeTextField.text == "" {
            errorMsg += "- Must provide a longitude\n"
        }
        if latitudeTextField.text == "" {
            errorMsg += "- Must provide a latitude\n"
        }
        displayMessage(title: "Not all fields filled", message: errorMsg)
        
    }
    
    
    
    @IBAction func takePhoto(_ sender: Any) {
        let controller = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            controller.sourceType = .camera
        } else {
            controller.sourceType = .photoLibrary
        }
        
        controller.allowsEditing = false
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func useCurrentLocation(_ sender: Any) {
        if let currentLocation = currentLocation {
            latitudeTextField.text = "\(currentLocation.latitude)"
            longitudeTextField.text = "\(currentLocation.longitude)"
        }
        else {
            let alertController = UIAlertController(title: "Location Not Found", message: "The location hasnot yet been determined.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func loadImageData(fileName: String) -> UIImage? {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                       .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        var image: UIImage?
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            let fileData = fileManager.contents(atPath: filePath)
            image = UIImage(data: fileData!)
        }
        
        return image
    }
}
