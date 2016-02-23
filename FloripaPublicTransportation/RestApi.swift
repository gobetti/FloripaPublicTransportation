//
//  RestApi.swift
//  FloripaPublicTransportation
//
//  Created by Marcelo Gobetti on 2/19/16.
//  Copyright © 2016 Marcelo Gobetti. All rights reserved.
//

import Foundation

class RestApi {
    static func findRoutesByStopName(stopName: String, completion: (routes: [Route]) -> Void)
    {
        var stopNameEscaped = stopName
        if !stopNameEscaped.hasPrefix("%") {
            stopNameEscaped = "%" + stopNameEscaped
        }
        if !stopNameEscaped.hasSuffix("%") {
            stopNameEscaped += "%"
        }
        
        var routes = [Route]()
        parseRequest(NSURL(string: "https://api.appglu.com/v1/queries/findRoutesByStopName/run")!, params: ["stopName":"\(stopNameEscaped)"], taskCompletion: { jsonRows in
            for row in jsonRows {
                routes.append(Route(id: row["id"] as! Int, name: row["longName"] as! String))
            }
            completion(routes: routes)
        })
    }
    
    static func findStopsByRouteId(routeId: Int, completion: (stops: [Stop]) -> Void)
    {
        var stops = [Stop]()
        parseRequest(NSURL(string: "https://api.appglu.com/v1/queries/findStopsByRouteId/run")!, params: ["routeId":"\(routeId)"], taskCompletion: { jsonRows in
            for row in jsonRows {
                stops.append(Stop(sequence: row["sequence"] as! Int, name: row["name"] as! String))
            }
            stops.sortInPlace({ s1, s2 in
                (s1.sequence! < s2.sequence!)
            })
            completion(stops: stops)
        })
    }
    
    static func findDeparturesByRouteId(routeId: Int, completion: (departures: [Departure]) -> Void)
    {
        var departures = [Departure]()
        parseRequest(NSURL(string: "https://api.appglu.com/v1/queries/findDeparturesByRouteId/run")!, params: ["routeId":"\(routeId)"], taskCompletion: { jsonRows in
            for row in jsonRows {
                departures.append(Departure(calendar: row["calendar"] as! String, time: row["time"] as! String))
            }
            departures.sortInPlace({ d1, d2 in
                (d1.time! < d2.time!)
            })
            completion(departures: departures)
        })
    }
    
    /// Generic function to be called by any of the API POST methods.
    /// The request is built upon the "url" and "params" arguments;
    /// The "rows" returned from the JSON response can be parsed via the "taskCompletion" function argument.
    private static func parseRequest(url: NSURL, params: NSDictionary, taskCompletion: (jsonRows: [NSDictionary]) -> Void)
    {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("staging", forHTTPHeaderField: "X-AppGlu-Environment")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let username = "WKD4N7YMA1uiM8V"
        let password = "DtdTtzMLQlA0hk2C1Yi5pLyVIlAQ68"
        let credentialsData = "\(username):\(password)".dataUsingEncoding(NSUTF8StringEncoding)
        let credentialsBase64String = credentialsData?.base64EncodedStringWithOptions([])
        request.setValue("Basic \(credentialsBase64String!)", forHTTPHeaderField: "Authorization")
        
        var parameters: [String: AnyObject] = [:]
        parameters["params"] = params
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(parameters, options: [])
        }
        catch let error as NSError {
            NSLog("NSJSONSerialization.dataWithJSONObject threw an error: \(error.description)")
            NSLog("Dictionary contents: \(params)")
        }
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request,
            completionHandler: { (data, response, error) in
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
                    if let rows = json!["rows"] as? [NSDictionary] {
                        taskCompletion(jsonRows: rows)
                    }
                    else {
                        NSLog("Could not interpret \"rows\" as an array of NSDictionary")
                        NSLog("JSON contents: \(NSString(data: data!, encoding: NSUTF8StringEncoding)!)")
                    }
                }
                catch let error as NSError {
                    NSLog("NSJSONSerialization.JSONObjectWithData threw an error: \(error.description)")
                    NSLog("JSON contents: \(NSString(data: data!, encoding: NSUTF8StringEncoding)!)")
                }
        })
        
        task.resume()
    }
}