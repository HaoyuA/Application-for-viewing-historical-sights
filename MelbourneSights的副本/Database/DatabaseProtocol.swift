//
//  DatabaseProtocol.swift
//  FIT5140-Assign1
//
//  Created by 张昊宇 on 1/9/19.
//  Copyright © 2019 Haoyu Zhang. All rights reserved.
//

import Foundation
enum DatabaseChange {
    case add
    case remove
    case update
}
enum ListenerType {
    
    case sights
    
}
protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    
    func onSightListChange(change: DatabaseChange, sights: [Sight])
}
protocol DatabaseProtocol: AnyObject {
    
    var defaultSight: Sight {get}
    func addSight(name: String, desc: String,latitude: Double,longitude: Double,icon: String,photo:String) -> Sight
    func deleteSight(sight: Sight)
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    //func ifEntityExist(name: String) -> Bool
}
