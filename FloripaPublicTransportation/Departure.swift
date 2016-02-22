//
//  Departure.swift
//  FloripaPublicTransportation
//
//  Created by Marcelo Gobetti on 2/19/16.
//  Copyright © 2016 Marcelo Gobetti. All rights reserved.
//

import Foundation

class Departure {
    enum Calendar: String {
        case Weekday = "WEEKDAY"
        case Saturday = "SATURDAY"
        case Sunday = "SUNDAY"
    }
    
    var calendar: Calendar?
    var time: String?
    
    init(calendar: String, time: String) {
        self.calendar = Calendar(rawValue: calendar)
        self.time = time
    }
}