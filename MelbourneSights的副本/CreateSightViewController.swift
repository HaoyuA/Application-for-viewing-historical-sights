//
//  CreateSightViewController.swift
//  FIT5140-Assign1
//
//  Created by 张昊宇 on 2/9/19.
//  Copyright © 2019 Haoyu Zhang. All rights reserved.
//

import UIKit
import MapKit


class CreateSightViewController: UIViewController,CLLocationManagerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    weak var databaseController: DatabaseProtocol?
    var currentLocation: CLLocationCoordinate2D?
    var locationManager: CLLocationManager = CLLocationManager()
    var mapViewController: MapViewController?
    var coordinate:CLLocationCoordinate2D?
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var iconSegmentControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get the database controller once from the App Delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController

        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        // Do any additional setup after loading the view.
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last!
        currentLocation = location.coordinate
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
   
    @IBAction func createSight(_ sender: Any) {
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
//            if (databaseController?.ifEntityExist(name: nameTextField.text!))!{
//                print("exist")
//            }
            
            let sight = databaseController!.addSight(name: nameTextField.text!, desc: descriptionTextField.text!, latitude: Double(latitudeTextField.text!)!, longitude: Double(longitudeTextField.text!)!, icon: icon, photo: "\(date)")
            mapViewController?.allSights.append(sight)
            navigationController?.popViewController(animated: true)
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
            let alertController = UIAlertController(title: "Location Not Found", message: "The location has not yet been determined.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                present(alertController, animated: true, completion: nil)
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
