//
//  RestApi.swift
//  FloripaPublicTransportation
//
//  Created by Marcelo Gobetti on 2/19/16.
//  Copyright © 2016 Marcelo Gobetti. All rights reserved.
//

import Foundation

class RestApi {
    static func findRoutesByStopName(stopName: String) -> [Route]
    {
        print("Not implemented. stopName = \(stopName)")
        return [Route]()
    }
    
    static func findStopsByRouteId(routeId: Int) -> [Stop]
    {
        print("Not implemented. routeId = \(routeId)")
        return [Stop]()
    }
    
    static func findDeparturesByRouteId(routeId: Int) -> [Departure]
    {
        print("Not implemented. routeId = \(routeId)")
        return [Departure]()
    }
}