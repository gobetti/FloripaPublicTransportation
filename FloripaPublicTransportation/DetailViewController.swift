//
//  DetailViewController.swift
//  FloripaPublicTransportation
//
//  Created by Marcelo Gobetti on 2/19/16.
//  Copyright © 2016 Marcelo Gobetti. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {
    // MARK: Public properties
    
    private var _routeId: Int? // stored property
    var routeId: Int? { // public computed property
        get { return _routeId }
        set {
            guard newValue != nil && newValue != _routeId else {
                return
            }
            
            _routeId = newValue
            
            self.activityIndicator.startAnimating()
            self.view.bringSubviewToFront(self.activityIndicator)
            
            RestApi.findDeparturesByRouteId(_routeId!) { departures in
                self.departures = departures
                self.finishedLoadingDepartures = true
            }
            RestApi.findStopsByRouteId(_routeId!) { stops in
                self.stops = stops
                self.finishedLoadingStops = true
            }
        }
    }
    
    // MARK: Private properties
    
    private var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    private var stops: [Stop]?
    private var weekdayDepartures: [Departure]?
    private var saturdayDepartures: [Departure]?
    private var sundayDepartures: [Departure]?
    private var _departures: [Departure]? // stored property
    private var departures: [Departure]? { // computed property
        get { return _departures }
        set {
            guard newValue != nil else {
                return
            }
            
            _departures = newValue
            
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
    
    // MARK: tableView.reloadData() logic
    
    private var _finishedLoadingStops = false
    private var _finishedLoadingDepartures = false
    private var finishedLoadingStops: Bool {
        get { return _finishedLoadingStops }
        set {
            _finishedLoadingStops = newValue
            if finishedLoadingStops && finishedLoadingDepartures {
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                })
            }
        }
    }
    private var finishedLoadingDepartures: Bool {
        get { return _finishedLoadingDepartures }
        set {
            _finishedLoadingDepartures = newValue
            if finishedLoadingStops && finishedLoadingDepartures {
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                })
            }
        }
    }
    
    // MARK: Private constants definitions
    
    private let reuseIdentifier = "detailCell"
    private let headerTitles: [String] = ["List of streets within the route", "Weekday timetable",
        "Saturday timetable", "Sunday timetable"]

    // MARK: - View delegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Route details"
        
        self.activityIndicator.hidesWhenStopped = true
        self.view.addSubview(self.activityIndicator)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // at the moment viewDidLayoutSubviews() is called, the screen has already finished
        // loading all its elements positions, so this is the perfect moment to (re)calculate
        // the position of the activityIndicator (the center of the view):
        
        let activityIndicatorSize = self.activityIndicator.frame.width
        self.activityIndicator.frame = CGRectMake(
            (self.view.frame.width - activityIndicatorSize) / 2,
            (self.view.frame.height - activityIndicatorSize) / 2,
            activityIndicatorSize, activityIndicatorSize)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    // MARK: Rows
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        
        switch indexPath.section {
        case 0:
            cell.textLabel!.text = self.stops![indexPath.row].name?.customCapitalizedString
        case 1:
            cell.textLabel!.text = self.weekdayDepartures![indexPath.row].time
        case 2:
            cell.textLabel!.text = self.saturdayDepartures![indexPath.row].time
        case 3:
            cell.textLabel!.text = self.sundayDepartures![indexPath.row].time
        default:
            NSLog("Wrong section number: \(indexPath.section)")
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section
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
            NSLog("Wrong section number: \(section)")
            return 0
        }
    }
    
    // MARK: Sections
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.headerTitles.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section < self.headerTitles.count else {
            NSLog("Wrong section number: \(section)")
            return ""
        }
        
        return self.headerTitles[section]
    }

}
