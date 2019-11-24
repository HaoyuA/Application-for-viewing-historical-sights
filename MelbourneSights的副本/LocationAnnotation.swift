//
//  LocationAnnotation.swift
//  FIT5140-Assign1
//
//  Created by 张昊宇 on 2/9/19.
//  Copyright © 2019 Haoyu Zhang. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class LocationAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var icon: String?
    var image: String?
    
    init(title: String, subtitle: String, lat: Double, long: Double, icon: String, image: String) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.icon = icon
        self.image = image
    }
}
