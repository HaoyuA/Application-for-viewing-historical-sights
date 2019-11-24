//
//  locationAnnotationView.swift
//  FIT5140-Assign1
//
//  Created by 张昊宇 on 5/9/19.
//  Copyright © 2019 Haoyu Zhang. All rights reserved.
//

import Foundation
import MapKit

class locationAnnotationView: MKAnnotationView{
override var annotation: MKAnnotation? {
    willSet {
        
        guard let location = newValue as? LocationAnnotation else {return}
        canShowCallout = true
        calloutOffset = CGPoint(x: -5, y: 5)
        let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero,
                                                size: CGSize(width: 30, height: 30)))
        mapsButton.setBackgroundImage(UIImage(named: "icon/icon8"), for: UIControl.State())
        rightCalloutAccessoryView = mapsButton
        
        if let imageName = location.icon{
            let e = UIImage(named: "icon/\(imageName)")
            let resizedSize = CGSize(width: 30, height: 30)
            UIGraphicsBeginImageContext(resizedSize)
            e?.draw(in: CGRect(origin: .zero, size: resizedSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            image = resizedImage
        } else {
            image = nil
        }
        
        let i = UIImageView(frame: CGRect(origin: CGPoint.zero,
                                                      size: CGSize(width: 40, height: 40)))
        if let imageName: String = location.image!{
        if (UIImage(named:"picture/"+imageName ) != nil)
        {
            i.image = UIImage(named: "picture/\(imageName)")
        }
        else
        {
            i.image = loadImageData(fileName: imageName)
            }
        }
        else{
            i.image = nil
        }
        leftCalloutAccessoryView = i
        
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
