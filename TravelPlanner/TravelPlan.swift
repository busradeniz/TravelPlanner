//
//  TravelPlan.swift
//  TravelPlanner
//
//  Created by Busra Deniz on 02/01/16.
//  Copyright © 2016 busradeniz. All rights reserved.
//

import Foundation
import CloudKit

class TravelPlan {


    var title: String?
    var description:String?
    var address:String?
    var date: String?
    var latitude: Double?
    var longitude:Double?
    var photos = [CKAsset]()
    
    
}