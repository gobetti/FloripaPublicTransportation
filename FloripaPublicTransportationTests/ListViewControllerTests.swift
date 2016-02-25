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
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        self.listVC = navigationController.topViewController as? ListViewController
        
        UIApplication.sharedApplication().keyWindow!.rootViewController = self.listVC
        
        // forces the views to load:
        XCTAssertNotNil(navigationController.view)
        XCTAssertNotNil(self.listVC!.view)
        
        expectation = expectationWithDescription("foo")
        self.listVC!.delegate = self // allowing the mockListVC to execute our mock onDone() function
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
        
        self.listVC!.streetToSearch = "whatever"
        
        // loop until the expectation is fulfilled:
        waitForExpectationsWithTimeout(expectationTimeout) { error in
            XCTAssertNil(error, "Expectation timeout")
        }
        
        XCTAssertEqual(self.listVC!.tableView.numberOfSections, 1, "The table view should have exactly and only 1 section")
        XCTAssertEqual(self.listVC!.tableView.numberOfRowsInSection(0), 2, "The table view should have exactly and only 2 rows in its section")
    }
    
    func testTableViewHasNoCellsIfJsonHasNoRows() {
        stub(isHost("api.appglu.com") && isPath("/v1/queries/findRoutesByStopName/run")) {_ in
            let obj = ["rows":[], "rowsAffected":"0"]
            return OHHTTPStubsResponse(JSONObject: obj, statusCode:200, headers:nil)
        }
        
        self.listVC!.streetToSearch = "whatever"
        
        // loop until the expectation is fulfilled:
        waitForExpectationsWithTimeout(expectationTimeout) { error in
            XCTAssertNil(error, "Expectation timeout")
        }
        
        XCTAssertEqual(self.listVC!.tableView.numberOfSections, 1, "The table view should have exactly and only 1 section")
        XCTAssertEqual(self.listVC!.tableView.numberOfRowsInSection(0), 0, "The table view should not have any rows")
    }
    
    // MARK: - Private properties
    
    private var listVC: ListViewController?
    
    // MARK: - XCTestExpectation definitions
    
    private let expectationTimeout: NSTimeInterval = 5 // just a big enough timeout for the expectations
    
    private var expectation: XCTestExpectation?
    
    func onDone(results: String){
        expectation?.fulfill()
    }
}
