//
//  RestApiTests.swift
//  FloripaPublicTransportation
//
//  Created by Marcelo Gobetti on 2/23/16.
//  Copyright © 2016 Marcelo Gobetti. All rights reserved.
//

import XCTest
@testable import FloripaPublicTransportation
import OHHTTPStubs

class RestApiTests: XCTestCase, ExpectationProtocol {
    
    // PThis method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()
        
        expectation = expectationWithDescription("foo")
        RestApi.delegate = self // allowing the RestApi to execute our mock onDone() function
    }
    
    /// This method is called after the invocation of each test method in the class.
    override func tearDown() {
        super.tearDown()
        
        OHHTTPStubs.removeAllStubs()
    }
    
    func testEmptyDataFindRoutesByStopName() {
        testInvalidFindRoutesByStopName() {_ in
            let stubData = "Just a dummy string".dataUsingEncoding(NSUTF8StringEncoding)
            return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
        }
    }
    
    func testNotAJsonFindRoutesByStopName() {
        testInvalidFindRoutesByStopName() {_ in
            let stubData = "Just a dummy string".dataUsingEncoding(NSUTF8StringEncoding)
            return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
        }
    }
    
    func testEmptyRowsFindRoutesByStopName() {
        testValidFindRoutesByStopName( {_ in
            let obj = ["rows":[], "rowsAffected":"0"]
            return OHHTTPStubsResponse(JSONObject: obj, statusCode:200, headers:nil)
        },
            completionTests: { routes in
                XCTAssertEqual(routes.count, 0, "The returned array must be empty")
        })
    }
    
    func testDictionaryFindRoutesByStopName() {
        testValidFindRoutesByStopName({ _ in
            let obj = ["rows":["id":22,"shortName":"131","longName":"AGRONÔMICA VIA GAMA D'EÇA","lastModifiedDate":"2009-10-26T02:00:00+0000","agencyId":9], "rowsAffected":"0"]
            return OHHTTPStubsResponse(JSONObject: obj, statusCode:200, headers:nil)
            },
            completionTests: { routes in
                XCTAssertEqual(routes.count, 1, "The returned array must have 1 route")
                XCTAssertEqual(routes[0].id, 22, "The returned route must have id=22")
        })
    }
    
    func testRealJsonFindRoutesByStopName() {
        testValidFindRoutesByStopName({ _ in
            let stubData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("findRoutes", ofType: "json")!)
            return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
            },
            completionTests: { routes in
                XCTAssertEqual(routes.count, 2, "The returned array must have 2 routes")
                XCTAssertTrue(routes.contains({ $0.id == 22 }) && routes.contains({ $0.id == 32 }), "The returned array must contain routes with ids = 22 and 32")
        })
    }
    
    /// Generic function to be used by tests of `findRoutesByStopName` that use a valid JSON
    /// - Parameter stubResponse: the block that returns an `OHHTTPStubsResponse` with stubbed NSData/NSDictionary
    /// - Parameter completionTests: the block of tests to be executed against the returned array
    private func testValidFindRoutesByStopName(stubResponse: OHHTTPStubsResponseBlock, completionTests: (routes: [Route]) -> Void)
    {
        testFindRoutesByStopName(stubResponse) { routes in
                XCTAssertNotNil(routes, "The returned array must not be nil")
                completionTests(routes: routes!)
        }
    }
    
    /// Generic function to be used by tests of `findRoutesByStopName` that use an invalid JSON
    /// (or none at all)
    /// - Parameter stubResponse: the block that returns an `OHHTTPStubsResponse` with stubbed NSData/NSDictionary
    private func testInvalidFindRoutesByStopName(stubResponse: OHHTTPStubsResponseBlock)
    {
        testFindRoutesByStopName(stubResponse) { routes in
                XCTAssertNotNil(routes, "The returned array must not be nil")
                XCTAssertEqual(routes!.count, 0, "The returned array must be empty")
        }
    }
    
    /// Generic function to be used by any test of `findRoutesByStopName`
    /// - Parameter stubResponse: the block that returns an `OHHTTPStubsResponse` with stubbed NSData/NSDictionary
    /// - Parameter restApiCompletion: the `findRoutesByStopName` completion block
    private func testFindRoutesByStopName(stubResponse: OHHTTPStubsResponseBlock, restApiCompletion: (routes: [Route]?) -> Void)
    {
        stub(isHost("api.appglu.com") && isPath("/v1/queries/findRoutesByStopName/run"), response: stubResponse)
        
        RestApi.findRoutesByStopName("whatever", completion: restApiCompletion)
        
        // loop until the expectation is fulfilled:
        waitForExpectationsWithTimeout(expectationTimeout) { error in
            XCTAssertNil(error, "Expectation timeout")
        }
    }
    
    /// Generic function to be used by tests of `findStopsByRouteId` that use a valid JSON
    /// - Parameter stubResponse: the block that returns an `OHHTTPStubsResponse` with stubbed NSData/NSDictionary
    /// - Parameter completionTests: the block of tests to be executed against the returned array
    private func testValidFindStopsByRouteId(stubResponse: OHHTTPStubsResponseBlock, completionTests: (stops: [Stop]) -> Void)
    {
        testFindStopsByRouteId(stubResponse) { stops in
            XCTAssertNotNil(stops, "The returned array must not be nil")
            completionTests(stops: stops!)
        }
    }
    
    /// Generic function to be used by tests of `findStopsByRouteId` that use an invalid JSON
    /// (or none at all)
    /// - Parameter stubResponse: the block that returns an `OHHTTPStubsResponse` with stubbed NSData/NSDictionary
    private func testInvalidFindStopsByRouteId(stubResponse: OHHTTPStubsResponseBlock)
    {
        testFindStopsByRouteId(stubResponse) { stops in
            XCTAssertNotNil(stops, "The returned array must not be nil")
            XCTAssertEqual(stops!.count, 0, "The returned array must be empty")
        }
    }
    
    /// Generic function to be used by any test of `findStopsByRouteId`
    /// - Parameter stubResponse: the block that returns an `OHHTTPStubsResponse` with stubbed NSData/NSDictionary
    /// - Parameter restApiCompletion: the `findStopsByRouteId` completion block
    private func testFindStopsByRouteId(stubResponse: OHHTTPStubsResponseBlock, restApiCompletion: (stops: [Stop]?) -> Void)
    {
        stub(isHost("api.appglu.com") && isPath("/v1/queries/findStopsByRouteId/run"), response: stubResponse)
        
        RestApi.findStopsByRouteId(7664576, completion: restApiCompletion)
        
        // loop until the expectation is fulfilled:
        waitForExpectationsWithTimeout(expectationTimeout) { error in
            XCTAssertNil(error, "Expectation timeout")
        }
    }
    
    /// Generic function to be used by tests of `findDeparturesByRouteId` that use a valid JSON
    /// - Parameter stubResponse: the block that returns an `OHHTTPStubsResponse` with stubbed NSData/NSDictionary
    /// - Parameter completionTests: the block of tests to be executed against the returned array
    private func testValidFindDeparturesByRouteId(stubResponse: OHHTTPStubsResponseBlock, completionTests: (departures: [Departure]) -> Void)
    {
        testFindDeparturesByRouteId(stubResponse) { departures in
            XCTAssertNotNil(departures, "The returned array must not be nil")
            completionTests(departures: departures!)
        }
    }
    
    /// Generic function to be used by tests of `findDeparturesByRouteId` that use an invalid JSON
    /// (or none at all)
    /// - Parameter stubResponse: the block that returns an `OHHTTPStubsResponse` with stubbed NSData/NSDictionary
    private func testInvalidFindDeparturesByRouteId(stubResponse: OHHTTPStubsResponseBlock)
    {
        testFindDeparturesByRouteId(stubResponse) { departures in
            XCTAssertNotNil(departures, "The returned array must not be nil")
            XCTAssertEqual(departures!.count, 0, "The returned array must be empty")
        }
    }
    
    /// Generic function to be used by any test of `findDeparturesByRouteId`
    /// - Parameter stubResponse: the block that returns an `OHHTTPStubsResponse` with stubbed NSData/NSDictionary
    /// - Parameter restApiCompletion: the `findDeparturesByRouteId` completion block
    private func testFindDeparturesByRouteId(stubResponse: OHHTTPStubsResponseBlock, restApiCompletion: (departures: [Departure]?) -> Void)
    {
        stub(isHost("api.appglu.com") && isPath("/v1/queries/findDeparturesByRouteId/run"), response: stubResponse)
        
        RestApi.findDeparturesByRouteId(7664576, completion: restApiCompletion)
        
        // loop until the expectation is fulfilled:
        waitForExpectationsWithTimeout(expectationTimeout) { error in
            XCTAssertNil(error, "Expectation timeout")
        }
    }
    
    let expectationTimeout: NSTimeInterval = 500 // just a big enough timeout for the expectations
    
    var expectation: XCTestExpectation?
    
    func onDone(results: String){
        expectation?.fulfill()
    }
}
