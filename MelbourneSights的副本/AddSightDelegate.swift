//
//  AddSightDelegate.swift
//  FIT5140-Assign1
//
//  Created by 张昊宇 on 2/9/19.
//  Copyright © 2019 Haoyu Zhang. All rights reserved.
//

import Foundation
protocol AddSightDelegate: AnyObject {
    func addSight(newSight: Sight) -> Bool
}
