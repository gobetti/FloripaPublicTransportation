//
//  DetailViewController.swift
//  FloripaPublicTransportation
//
//  Created by Marcelo Gobetti on 2/19/16.
//  Copyright © 2016 Marcelo Gobetti. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {
    var routeId: Int?
    
    private var stops: [Stop]?
    
    private var weekdayDepartures: [Departure]?
    private var saturdayDepartures: [Departure]?
    private var sundayDepartures: [Departure]?
    private var _departures: [Departure]? // stored property
    private var departures: [Departure]? {
        get {
            return _departures
        }
        set {
            _departures = newValue
            
            guard _departures != nil else {
                return
            }
            
            self.weekdayDepartures = _departures!.filter { d in
                return d.calendar == .Weekday
            }
            
            self.saturdayDepartures = _departures!.filter { d in
                return d.calendar == .Saturday
            }
            
            self.sundayDepartures = _departures!.filter { d in
                return d.calendar == .Sunday
            }
        }
    }
        
    let reuseIdentifier = "detailCell"
    
    let headerTitles: [String] = ["List of streets within the route", "Weekday timetable",
        "Saturday timetable", "Sunday timetable"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Route details"
        
        self.departures = RestApi.findDeparturesByRouteId(self.routeId!)
        self.stops = RestApi.findStopsByRouteId(self.routeId!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    // MARK: Rows
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        
        cell.textLabel!.text = "Not implemented"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section)
        {
        case 0:
            return self.stops == nil ? 0 : self.stops!.count
        case 1:
            return self.weekdayDepartures == nil ? 0 : self.weekdayDepartures!.count
        case 2:
            return self.saturdayDepartures == nil ? 0 : self.saturdayDepartures!.count
        case 3:
            return self.sundayDepartures == nil ? 0 : self.sundayDepartures!.count
        default:
            NSLog("Wrong section number: %u", section)
            return 0
        }
    }
    
    // MARK: Sections
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.headerTitles.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section < self.headerTitles.count else {
            NSLog("Wrong section number: %u", section)
            return ""
        }
        
        return self.headerTitles[section]
    }

}
