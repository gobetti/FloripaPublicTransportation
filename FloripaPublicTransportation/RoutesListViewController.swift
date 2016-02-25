//
//  RoutesListViewController.swift
//  FloripaPublicTransportation
//
//  Created by Marcelo Gobetti on 2/19/16.
//  Copyright © 2016 Marcelo Gobetti. All rights reserved.
//

import UIKit

class RoutesListViewController: UITableViewController, UISearchBarDelegate {
    // MARK: Public properties
    
    private var _streetToSearch: String? // stored property
    var streetToSearch: String? { // public computed property
        get { return _streetToSearch }
        set {
            guard newValue != nil && newValue != _streetToSearch else {
                return
            }
            
            _streetToSearch = newValue
            
            if self.routes?.count > 0 {
                self.routes?.removeAll()
            }
            self.activityIndicator.startAnimating()
            self.view.bringSubviewToFront(self.activityIndicator)
            
            RestApi.findRoutesByStopName(_streetToSearch!) { routes in
                self.routes = routes
                dispatch_async(dispatch_get_main_queue(), {
                    self.activityIndicator.stopAnimating()
                })
            }
        }
    }
    
    // MARK: Private properties
    
    @IBOutlet private weak var searchBar: UISearchBar?
    private var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    private var _routes: [Route]? // stored property
    private var routes: [Route]? { // computed property
        get { return _routes }
        set {
            _routes = newValue
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
    }
    
    private let reuseIdentifier = "routeCell"
    
    // MARK: - View delegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: "The navigation button that returns to the RoutesListViewController"), style: .Plain, target: nil, action: nil)
        
        self.searchBar?.delegate = self
        
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

    // MARK: - Table view data source
    
    // MARK: Rows
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        
        cell.textLabel!.text = routes![indexPath.row].name?.customCapitalizedString
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.routes == nil {
            return 0
        }
        
        if self.streetToSearch != nil {
            // if got here, then the table view has finished reloading its data
            delegate?.onDone("foo")
        }
        
        return routes!.count
    }

    // MARK: Sections
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section == 0 else {
            NSLog("Wrong section number: \(section)")
            return ""
        }
        
        if self.routes == nil || self.routes!.count == 0 {
            return NSLocalizedString("No routes found", comment: "The section header title to show in RoutesListViewController when no routes were found")
        }
        
        return NSLocalizedString("Routes found", comment: "The section header title to show in RoutesListViewController above the found routes")
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.resignFirstResponder()
        self.streetToSearch = searchBar.text
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard segue.identifier == "goToDetail" else {
            if segue.identifier != nil {
                NSLog("Unknown segue identifier: \(segue.identifier)")
            }
            return
        }
        
        let destinationVC = segue.destinationViewController as! RouteDetailViewController
        destinationVC.routeId = self.routes![(self.tableView.indexPathsForSelectedRows?[0].row)!].id
    }
    
    var delegate: ExpectationProtocol? // for tests only
}
