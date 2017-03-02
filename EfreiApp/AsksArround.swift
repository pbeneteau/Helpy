//
//  AsksArround.swift
//  EfreiApp
//
//  Created by Paul Bénéteau on 25/02/2017.
//  Copyright © 2017 Paul Bénéteau. All rights reserved.
//

import UIKit
import CoreLocation


struct asksArround{
    
    var date: String?
    var type: String?
    var distanceBetweenUser: Double?
    
    init ( date : String, type : String, distanceBetweenUser: Double) {
        self.date = date
        self.type = type
        self.distanceBetweenUser = distanceBetweenUser
        //self.distanceBetweenUser = locationHelp().getLocationsDistance(location1: self.location!, location2: locationHelp().getLocation())
        
    }
}
