//
//  UserAsk.swift
//  EfreiApp
//
//  Created by Paul Bénéteau on 03/03/2017.
//  Copyright © 2017 Paul Bénéteau. All rights reserved.
//

import Foundation

struct userAsks {
    
    var date: String?
    var type: String?
    var address: String?
    var price: String?
    
    init ( date : String, type : String, address: String, price: String) {
        self.date = date
        self.type = type
        self.address = address
        self.price = price
    }

}
