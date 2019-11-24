//
//  SightDetailViewController.swift
//  FIT5140-Assign1
//
//  Created by 张昊宇 on 5/9/19.
//  Copyright © 2019 Haoyu Zhang. All rights reserved.
//

import UIKit

class SightDetailViewController: UIViewController {

    var annotation: LocationAnnotation?
    var sightForEdit: Sight?
    
    @IBOutlet weak var SightNameLabel: UILabel!
    @IBOutlet weak var SightDescriptionLabel: UILabel!
    @IBOutlet weak var SightLongitudeLabel: UILabel!
    @IBOutlet weak var SightLatitudeLabel: UILabel!
    @IBOutlet weak var SightImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showDetail()

        // Do any additional setup after loading the view.
    }
    
    func showDetail(){
        
        SightNameLabel.text = annotation!.title
        SightDescriptionLabel.text = annotation!.subtitle
        SightLongitudeLabel.text = "\(annotation!.coordinate.longitude)"
        SightLatitudeLabel.text = "\(annotation!.coordinate.latitude)"
        if let imageName = annotation?.image{
            if (UIImage(named:"picture/"+imageName ) != nil)
            {
                SightImage.image = UIImage(named: "picture/\(imageName)")
            }
            else
            {
                SightImage.image = loadImageData(fileName: imageName)
            }
        }
        else{
            SightImage.image = nil
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSightSegue" {
            let destination = segue.destination as! EditSightViewController
            destination.location = self.annotation
            destination.sightForEdit = self.sightForEdit
        }
    }
    

}
