//
//  RoutesListViewControllerTests.swift
//  FloripaPublicTransportation
//
//  Created by Marcelo Gobetti on 2/24/16.
//  Copyright © 2016 Marcelo Gobetti. All rights reserved.
//

import XCTest
@testable import FloripaPublicTransportation
import OHHTTPStubs

class RoutesListViewControllerTests: XCTestCase, ExpectationProtocol {
    // MARK: - Set up & Tear down
    
    // This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        self.routesListVC = navigationController.topViewController as? RoutesListViewController
        
        UIApplication.sharedApplication().keyWindow!.rootViewController = self.routesListVC
        
        // forces the views to load:
        XCTAssertNotNil(navigationController.view)
        XCTAssertNotNil(self.routesListVC!.view)
        
        expectation = expectationWithDescription("foo")
        self.routesListVC!.delegate = self // allowing the routesListVC to execute our mock onDone() function
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
        
        self.routesListVC!.streetToSearch = "whatever"
        
        // loop until the expectation is fulfilled:
        waitForExpectationsWithTimeout(expectationTimeout) { error in
            XCTAssertNil(error, "Expectation timeout")
        }
        
        XCTAssertEqual(self.routesListVC!.tableView.numberOfSections, 1, "The table view should have exactly and only 1 section")
        XCTAssertEqual(self.routesListVC!.tableView.numberOfRowsInSection(0), 2, "The table view should have exactly and only 2 rows in its section")
    }
    
    func testTableViewHasNoCellsIfJsonHasNoRows() {
        stub(isHost("api.appglu.com") && isPath("/v1/queries/findRoutesByStopName/run")) {_ in
            let obj = ["rows":[], "rowsAffected":"0"]
            return OHHTTPStubsResponse(JSONObject: obj, statusCode:200, headers:nil)
        }
        
        self.routesListVC!.streetToSearch = "whatever"
        
        // loop until the expectation is fulfilled:
        waitForExpectationsWithTimeout(expectationTimeout) { error in
            XCTAssertNil(error, "Expectation timeout")
        }
        
        XCTAssertEqual(self.routesListVC!.tableView.numberOfSections, 1, "The table view should have exactly and only 1 section")
        XCTAssertEqual(self.routesListVC!.tableView.numberOfRowsInSection(0), 0, "The table view should not have any rows")
    }
    
    func testSegueIsPerformedWithoutErrors() {
        stub(isHost("api.appglu.com") && isPath("/v1/queries/findRoutesByStopName/run")) { _ in
            let stubData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("findRoutes", ofType: "json")!)
            return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
        }
        
        self.routesListVC!.streetToSearch = "whatever"
        
        // loop until the expectation is fulfilled:
        waitForExpectationsWithTimeout(expectationTimeout) { error in
            XCTAssertNil(error, "Expectation timeout")
        }
        
        let nsLogArrayCountBefore = SystemLogAccessor.NSLogArray().count
        let firstRowIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.routesListVC!.tableView!.selectRowAtIndexPath(firstRowIndexPath, animated: false, scrollPosition: .None)
        self.routesListVC!.performSegueWithIdentifier("goToDetail", sender: self.routesListVC!.tableView!.cellForRowAtIndexPath(firstRowIndexPath))
        
        XCTAssertEqual(SystemLogAccessor.NSLogArray().count, nsLogArrayCountBefore, "This application should not have logged anything while performing the segue")
    }
    
    // MARK: - Private properties
    
    private var routesListVC: RoutesListViewController?
    
    // MARK: - XCTestExpectation definitions
    
    private let expectationTimeout: NSTimeInterval = 5 // just a big enough timeout for the expectations
    
    private var expectation: XCTestExpectation?
    
    func onDone(){
        expectation?.fulfill()
    }
}
