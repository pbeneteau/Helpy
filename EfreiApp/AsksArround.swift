//
//  AsksArround.swift
//  EfreiApp
//
//  Created by Paul Bénéteau on 25/02/2017.
//  Copyright © 2017 Paul Bénéteau. All rights reserved.
//

import UIKit

struct asksArround{
    
    var date: String?
    var type: String?
    var distance: Double?
    var address: String?
    var nsDate: String?
    
    init ( date : String, type : String, distance: Double, address: String, nsDate: String) {
        self.date = date
        self.type = type
        self.distance = distance
        self.address = address
        self.nsDate = nsDate
    }
}
