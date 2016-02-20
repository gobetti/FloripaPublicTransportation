//
//  ListViewController.swift
//  FloripaPublicTransportation
//
//  Created by Marcelo Gobetti on 2/19/16.
//  Copyright © 2016 Marcelo Gobetti. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController, UISearchBarDelegate {
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var routes: [Route]?
    
    let reuseIdentifier = "routeCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Find routes"
        
        self.searchBar.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    // MARK: Rows
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        
        cell.textLabel!.text = routes![indexPath.row].name
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if routes == nil {
            return 0
        }
        
        return routes!.count
    }

    // MARK: Sections
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section == 0 else {
            NSLog("Wrong section number: %u", section)
            return ""
        }
        
        if routes == nil || routes!.count == 0 {
            return "No routes found"
        }
        
        return "Routes found"
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.routes = RestApi.findRoutesByStopName(self.searchBar.text!)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard segue.identifier == "goToDetail" else {
            return
        }
        
        let destinationVC = segue.destinationViewController as! DetailViewController
        destinationVC.routeId = routes![(self.tableView.indexPathsForSelectedRows?[0].row)!].id
    }

}
