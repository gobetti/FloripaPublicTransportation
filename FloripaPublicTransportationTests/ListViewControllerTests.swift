//
//  ListViewControllerTests.swift
//  FloripaPublicTransportation
//
//  Created by Marcelo Gobetti on 2/24/16.
//  Copyright © 2016 Marcelo Gobetti. All rights reserved.
//

import XCTest
@testable import FloripaPublicTransportation
import OHHTTPStubs

class ListViewControllerTests: XCTestCase, ExpectationProtocol {
    // MARK: - Set up & Tear down
    
    // This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()
        
        // Leaving the block below for future reference in case I decide to test the view
        // controller instantiated from the storyboard:
        /*let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        self.listVC = navigationController.topViewController as? ListViewController
        
        UIApplication.sharedApplication().keyWindow!.rootViewController = self.listVC*/
        
        self.mockListVC = MockListViewController()
        
        expectation = expectationWithDescription("foo")
        self.mockListVC!.delegate = self // allowing the mockListVC to execute our mock onDone() function
    }
    
    /// This method is called after the invocation of each test method in the class.
    override func tearDown() {
        super.tearDown()
        
        OHHTTPStubs.removeAllStubs()
    }
    
    // MARK: - Tests

    func testTableViewHasCellsIfJsonHasRows() {
        stub(isHost("api.appglu.com") && isPath("/v1/queries/findRoutesByStopName/run")) { _ in
            let stubData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("findRoutes", ofType: "json")!)
            return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
        }
        
        self.mockListVC!.streetToSearch = "whatever"
        
        // loop until the expectation is fulfilled:
        waitForExpectationsWithTimeout(expectationTimeout) { error in
            XCTAssertNil(error, "Expectation timeout")
        }
        
        XCTAssertEqual(self.mockListVC!.tableView.numberOfSections, 1, "The table view should have exactly and only 1 section")
        XCTAssertEqual(self.mockListVC!.tableView.numberOfRowsInSection(0), 2, "The table view should have exactly and only 2 rows in its section")
    }
    
    func testTableViewHasNoCellsIfJsonHasNoRows() {
        stub(isHost("api.appglu.com") && isPath("/v1/queries/findRoutesByStopName/run")) {_ in
            let obj = ["rows":[], "rowsAffected":"0"]
            return OHHTTPStubsResponse(JSONObject: obj, statusCode:200, headers:nil)
        }
        
        self.mockListVC!.streetToSearch = "whatever"
        
        // loop until the expectation is fulfilled:
        waitForExpectationsWithTimeout(expectationTimeout) { error in
            XCTAssertNil(error, "Expectation timeout")
        }
        
        XCTAssertEqual(self.mockListVC!.tableView.numberOfSections, 1, "The table view should have exactly and only 1 section")
        XCTAssertEqual(self.mockListVC!.tableView.numberOfRowsInSection(0), 0, "The table view should not have any rows")
    }
    
    // @todo This test is still failing, I need to check what else iOS needs to perform the segue from the table view cell
    func testTableViewPerformsSegueOnRowSelection() {
        stub(isHost("api.appglu.com") && isPath("/v1/queries/findRoutesByStopName/run")) { _ in
            let stubData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("findRoutes", ofType: "json")!)
            return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
        }
        
        self.mockListVC!.streetToSearch = "whatever"
        
        // loop until the expectation is fulfilled:
        waitForExpectationsWithTimeout(expectationTimeout) { error in
            XCTAssertNil(error, "Expectation timeout")
        }
        
        self.mockListVC!.tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: .None)
        XCTAssertEqual(self.mockListVC!.segueIdentifier, "goToDetail", "The performed segue must have a 'goToDetail' identifier")
    }
    
    // MARK: - Private properties
    
    //private var listVC: ListViewController?
    private var mockListVC: MockListViewController?
    
    // MARK: - XCTestExpectation definitions
    
    private let expectationTimeout: NSTimeInterval = 5 // just a big enough timeout for the expectations
    
    private var expectation: XCTestExpectation?
    
    func onDone(results: String){
        expectation?.fulfill()
    }
    
    // MARK: - Class override
    class MockListViewController : ListViewController {
        var segueIdentifier: String?
        var delegate: ExpectationProtocol?
        override func performSegueWithIdentifier(identifier: String, sender: AnyObject?) {
            self.segueIdentifier = identifier
            super.performSegueWithIdentifier(identifier, sender: sender)
        }
        /// This delegate method gets automatically executed (maybe more than once) after
        /// the tableView has finished reloading its data
        override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if self.streetToSearch != nil {
                delegate?.onDone("foo")
            }
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
}
