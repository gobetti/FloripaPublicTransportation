//
//  RouteDetailViewControllerTests.swift
//  FloripaPublicTransportation
//
//  Created by Marcelo Gobetti on 2/25/16.
//  Copyright © 2016 Marcelo Gobetti. All rights reserved.
//

import XCTest
@testable import FloripaPublicTransportation
import OHHTTPStubs

class RouteDetailViewControllerTests: XCTestCase, ExpectationProtocol {
    // MARK: - Set up & Tear down
    
    // This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()
        
        self.mockRouteDetailVC = MockRouteDetailViewController()
        // forces the view to load:
        XCTAssertNotNil(self.mockRouteDetailVC!.view)
        
        expectation = expectationWithDescription("foo")
        self.mockRouteDetailVC!.delegate = self // allowing the mock VC to execute our mock onDone() function
    }
    
    /// This method is called after the invocation of each test method in the class.
    override func tearDown() {
        super.tearDown()
        
        OHHTTPStubs.removeAllStubs()
    }
    
    // MARK: - Tests
    
    func testTableViewHasCellsIfJsonsHaveRows() {
        stub(isHost("api.appglu.com") && isPath("/v1/queries/findStopsByRouteId/run")) { _ in
            let stubData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("findStops", ofType: "json")!)
            return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
        }
        
        stub(isHost("api.appglu.com") && isPath("/v1/queries/findDeparturesByRouteId/run")) { _ in
            let stubData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("findDepartures", ofType: "json")!)
            return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
        }
        
        self.mockRouteDetailVC!.routeId = 43236524
        
        // loop until the expectation is fulfilled:
        waitForExpectationsWithTimeout(expectationTimeout) { error in
            XCTAssertNil(error, "Expectation timeout")
        }
        
        XCTAssertEqual(self.mockRouteDetailVC!.tableView.numberOfSections, 4, "The table view should have exactly and only 4 sections")
        XCTAssertGreaterThan(self.mockRouteDetailVC!.tableView.numberOfRowsInSection(0), 0, "The table view should have some rows in section 0")
        XCTAssertGreaterThan(self.mockRouteDetailVC!.tableView.numberOfRowsInSection(1), 0, "The table view should have some rows in section 1")
        XCTAssertGreaterThan(self.mockRouteDetailVC!.tableView.numberOfRowsInSection(2), 0, "The table view should have some rows in section 2")
        XCTAssertGreaterThan(self.mockRouteDetailVC!.tableView.numberOfRowsInSection(3), 0, "The table view should have some rows in section 3")
    }
    
    func testTableViewHasStopsCellsIfJsonHasRows() {
        stub(isHost("api.appglu.com") && isPath("/v1/queries/findStopsByRouteId/run")) { _ in
            let stubData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("findStops", ofType: "json")!)
            return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
        }
        
        stub(isHost("api.appglu.com") && isPath("/v1/queries/findDeparturesByRouteId/run")) { _ in
            let obj = ["rows":[], "rowsAffected":"0"]
            return OHHTTPStubsResponse(JSONObject: obj, statusCode:200, headers:nil)
        }
        
        self.mockRouteDetailVC!.routeId = 43236524
        
        // loop until the expectation is fulfilled:
        waitForExpectationsWithTimeout(expectationTimeout) { error in
            XCTAssertNil(error, "Expectation timeout")
        }
        
        XCTAssertEqual(self.mockRouteDetailVC!.tableView.numberOfSections, 4, "The table view should have exactly and only 4 sections")
        XCTAssertGreaterThan(self.mockRouteDetailVC!.tableView.numberOfRowsInSection(0), 0, "The table view should have some rows in section 0")
        XCTAssertEqual(self.mockRouteDetailVC!.tableView.numberOfRowsInSection(1), 0, "The table view should not have any rows in section 1")
        XCTAssertEqual(self.mockRouteDetailVC!.tableView.numberOfRowsInSection(2), 0, "The table view should not have any rows in section 2")
        XCTAssertEqual(self.mockRouteDetailVC!.tableView.numberOfRowsInSection(3), 0, "The table view should not have any rows in section 3")
    }
    
    func testTableViewHasDeparturesCellsIfJsonHasRows() {
        stub(isHost("api.appglu.com") && isPath("/v1/queries/findStopsByRouteId/run")) { _ in
            let obj = ["rows":[], "rowsAffected":"0"]
            return OHHTTPStubsResponse(JSONObject: obj, statusCode:200, headers:nil)
        }
        
        stub(isHost("api.appglu.com") && isPath("/v1/queries/findDeparturesByRouteId/run")) { _ in
            let stubData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("findDepartures", ofType: "json")!)
            return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
        }
        
        self.mockRouteDetailVC!.routeId = 43236524
        
        // loop until the expectation is fulfilled:
        waitForExpectationsWithTimeout(expectationTimeout) { error in
            XCTAssertNil(error, "Expectation timeout")
        }
        
        XCTAssertEqual(self.mockRouteDetailVC!.tableView.numberOfSections, 4, "The table view should have exactly and only 4 sections")
        XCTAssertEqual(self.mockRouteDetailVC!.tableView.numberOfRowsInSection(0), 0, "The table view should not have any rows in section 0")
        XCTAssertGreaterThan(self.mockRouteDetailVC!.tableView.numberOfRowsInSection(1), 0, "The table view should have some rows in section 1")
        XCTAssertGreaterThan(self.mockRouteDetailVC!.tableView.numberOfRowsInSection(2), 0, "The table view should have some rows in section 2")
        XCTAssertGreaterThan(self.mockRouteDetailVC!.tableView.numberOfRowsInSection(3), 0, "The table view should have some rows in section 3")
    }
    
    // MARK: - Mock class
    class MockRouteDetailViewController: RouteDetailViewController {
        override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if self.finishedLoadingStops && self.finishedLoadingDepartures && section == 0 {
                // if got here, then the table view has finished reloading its data
                delegate?.onDone()
            }
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
        
        var delegate: ExpectationProtocol?
    }
    
    // MARK: - Private properties
    
    private var mockRouteDetailVC: MockRouteDetailViewController?
    
    // MARK: - XCTestExpectation definitions
    
    private let expectationTimeout: NSTimeInterval = 5 // just a big enough timeout for the expectations
    
    private var expectation: XCTestExpectation?
    
    func onDone(){
        expectation?.fulfill()
    }
}
