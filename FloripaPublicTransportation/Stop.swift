//
//  Stop.swift
//  FloripaPublicTransportation
//
//  Created by Marcelo Gobetti on 2/19/16.
//  Copyright © 2016 Marcelo Gobetti. All rights reserved.
//

import Foundation

class Stop {
    var sequence: Int?
    var name: String?
    
    init(sequence: Int, name: String) {
        self.sequence = sequence
        self.name = name
    }
}