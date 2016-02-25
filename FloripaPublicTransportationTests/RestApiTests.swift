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
    // MARK: - Set up & Tear down
    
    // This method is called before the invocation of each test method in the class.
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
    
    // MARK: - findRoutesByStopName
    
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
            let obj = ["rows":[["id":22,"shortName":"131","longName":"AGRONÔMICA VIA GAMA D'EÇA","lastModifiedDate":"2009-10-26T02:00:00+0000","agencyId":9]], "rowsAffected":"0"]
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
    
    // MARK: Generic functions
    
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
        let nsLogArrayCountBefore = SystemLogAccessor.NSLogArray().count
        testFindRoutesByStopName(stubResponse) { routes in
            XCTAssertNotNil(routes, "The returned array must not be nil")
            XCTAssertEqual(routes!.count, 0, "The returned array must be empty")
            XCTAssertGreaterThan(SystemLogAccessor.NSLogArray().count, nsLogArrayCountBefore, "This application should have increased its number of logs due to the detected errors")
            // @todo Consider verifying the messages instead of just the count
        }
    }
    
    /// Generic function to be used by any test of `findRoutesByStopName`
    /// - Parameter stubResponse: the block that returns an `OHHTTPStubsResponse` with stubbed NSData/NSDictionary
    /// - Parameter restApiCompletion: the `findRoutesByStopName` completion block
    private func testFindRoutesByStopName(stubResponse: OHHTTPStubsResponseBlock, restApiCompletion: (routes: [Route]?) -> Void)
    {
        stub(isHost("api.appglu.com") && isPath("/v1/queries/findRoutesByStopName/run"), response: stubResponse)
        
        var didExecuteCompletion = false
        RestApi.findRoutesByStopName("whatever", completion: { routes in
            restApiCompletion(routes: routes)
            didExecuteCompletion = true
        })
        
        // loop until the expectation is fulfilled:
        waitForExpectationsWithTimeout(expectationTimeout) { error in
            XCTAssertNil(error, "Expectation timeout")
        }
        
        XCTAssertTrue(didExecuteCompletion, "The completion block must be executed")
    }
    
    // MARK: - findStopsByRouteId
    
    func testEmptyDataFindStopsByRouteId() {
        testInvalidFindStopsByRouteId() {_ in
            let stubData = "Just a dummy string".dataUsingEncoding(NSUTF8StringEncoding)
            return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
        }
    }
    
    func testNotAJsonFindStopsByRouteId() {
        testInvalidFindStopsByRouteId() {_ in
            let stubData = "Just a dummy string".dataUsingEncoding(NSUTF8StringEncoding)
            return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
        }
    }
    
    func testEmptyRowsFindStopsByRouteId() {
        testValidFindStopsByRouteId( {_ in
            let obj = ["rows":[], "rowsAffected":"0"]
            return OHHTTPStubsResponse(JSONObject: obj, statusCode:200, headers:nil)
            },
            completionTests: { stops in
                XCTAssertEqual(stops.count, 0, "The returned array must be empty")
        })
    }
    
    func testDictionaryFindStopsByRouteId() {
        testValidFindStopsByRouteId({ _ in
            let obj = ["rows":[["id": 13,"name": "TICEN","sequence": 1,"route_id": 17]], "rowsAffected":"0"]
            return OHHTTPStubsResponse(JSONObject: obj, statusCode:200, headers:nil)
            },
            completionTests: { stops in
                XCTAssertEqual(stops.count, 1, "The returned array must have 1 stop")
                XCTAssertEqual(stops[0].sequence, 1, "The returned stop must have sequence=1")
        })
    }
    
    func testRealJsonFindStopsByRouteId() {
        testValidFindStopsByRouteId({ _ in
            let stubData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("findStops", ofType: "json")!)
            return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
            },
            completionTests: { stops in
                XCTAssertEqual(stops.count, 28, "The returned array must have 28 stops")
                XCTAssertFalse(stops.contains({ $0.sequence < 1 }) || stops.contains({ $0.sequence > 28 }), "The returned array must not contain sequences out of range [1,28]")
                XCTAssertEqual(Set<Int>(stops.map({ return $0.sequence! })).count, stops.count, "All elements in the stops array must have an unique 'sequence'")
        })
    }
    
    // MARK: Generic functions
    
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
        let nsLogArrayCountBefore = SystemLogAccessor.NSLogArray().count
        testFindStopsByRouteId(stubResponse) { stops in
            XCTAssertNotNil(stops, "The returned array must not be nil")
            XCTAssertEqual(stops!.count, 0, "The returned array must be empty")
            XCTAssertGreaterThan(SystemLogAccessor.NSLogArray().count, nsLogArrayCountBefore, "This application should have increased its number of logs due to the detected errors")
            // @todo Consider verifying the messages instead of just the count
        }
    }
    
    /// Generic function to be used by any test of `findStopsByRouteId`
    /// - Parameter stubResponse: the block that returns an `OHHTTPStubsResponse` with stubbed NSData/NSDictionary
    /// - Parameter restApiCompletion: the `findStopsByRouteId` completion block
    private func testFindStopsByRouteId(stubResponse: OHHTTPStubsResponseBlock, restApiCompletion: (stops: [Stop]?) -> Void)
    {
        stub(isHost("api.appglu.com") && isPath("/v1/queries/findStopsByRouteId/run"), response: stubResponse)
        
        var didExecuteCompletion = false
        RestApi.findStopsByRouteId(7664576, completion: { stops in
            restApiCompletion(stops: stops)
            didExecuteCompletion = true
        })
        
        // loop until the expectation is fulfilled:
        waitForExpectationsWithTimeout(expectationTimeout) { error in
            XCTAssertNil(error, "Expectation timeout")
        }
        
        XCTAssertTrue(didExecuteCompletion, "The completion block must be executed")
    }
    
    // MARK: - findDeparturesByRouteId
    
    func testEmptyDataFindDeparturesByRouteId() {
        testInvalidFindDeparturesByRouteId() {_ in
            let stubData = "Just a dummy string".dataUsingEncoding(NSUTF8StringEncoding)
            return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
        }
    }
    
    func testNotAJsonFindDeparturesByRouteId() {
        testInvalidFindDeparturesByRouteId() {_ in
            let stubData = "Just a dummy string".dataUsingEncoding(NSUTF8StringEncoding)
            return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
        }
    }
    
    func testEmptyRowsFindDeparturesByRouteId() {
        testValidFindDeparturesByRouteId( {_ in
            let obj = ["rows":[], "rowsAffected":"0"]
            return OHHTTPStubsResponse(JSONObject: obj, statusCode:200, headers:nil)
            },
            completionTests: { departures in
                XCTAssertEqual(departures.count, 0, "The returned array must be empty")
        })
    }
    
    func testDictionaryFindDeparturesByRouteId() {
        testValidFindDeparturesByRouteId({ _ in
            let obj = ["rows":[["id": 472,"calendar": "WEEKDAY","time": "06:00"]], "rowsAffected":"0"]
            return OHHTTPStubsResponse(JSONObject: obj, statusCode:200, headers:nil)
            },
            completionTests: { departures in
                XCTAssertEqual(departures.count, 1, "The returned array must have 1 departure")
                XCTAssertEqual(departures[0].calendar, Departure.Calendar.Weekday, "The returned departure must have calendar=Weekday")
        })
    }
    
    func testRealJsonFindDeparturesByRouteId() {
        testValidFindDeparturesByRouteId({ _ in
            let stubData = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("findDepartures", ofType: "json")!)
            return OHHTTPStubsResponse(data: stubData!, statusCode:200, headers:nil)
            },
            completionTests: { departures in
                XCTAssertEqual(departures.count, 76, "The returned array must have 76 departures")
                XCTAssertFalse(departures.contains({ $0.time < "00:00" }) || departures.contains({ $0.time > "23:59" }), "The returned array must not contain sequences out of range [\"00:00\",\"23:59\"]")
                
                let weekdayDepartures = departures.filter({ (d:Departure) -> Bool in
                    return d.calendar == Departure.Calendar.Weekday})
                let saturdayDepartures = departures.filter({ (d:Departure) -> Bool in
                    return d.calendar == Departure.Calendar.Saturday})
                let sundayDepartures = departures.filter({ (d:Departure) -> Bool in
                    return d.calendar == Departure.Calendar.Sunday})
                
                XCTAssertGreaterThan(weekdayDepartures.count, 0, "The returned array must have timetables for weekdays")
                XCTAssertGreaterThan(saturdayDepartures.count, 0, "The returned array must have timetables for Saturdays")
                XCTAssertGreaterThan(sundayDepartures.count, 0, "The returned array must have timetables for Sundays")
                XCTAssertEqual(Set<String>(weekdayDepartures.map({ return $0.time! })).count, weekdayDepartures.count, "All elements in the weekday departures array must have an unique 'time'")
                XCTAssertEqual(Set<String>(saturdayDepartures.map({ return $0.time! })).count, saturdayDepartures.count, "All elements in the Saturday departures array must have an unique 'time'")
                XCTAssertEqual(Set<String>(sundayDepartures.map({ return $0.time! })).count, sundayDepartures.count, "All elements in the Sunday departures array must have an unique 'time'")
        })
    }
    
    // MARK: Generic functions
    
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
        let nsLogArrayCountBefore = SystemLogAccessor.NSLogArray().count
        testFindDeparturesByRouteId(stubResponse) { departures in
            XCTAssertNotNil(departures, "The returned array must not be nil")
            XCTAssertEqual(departures!.count, 0, "The returned array must be empty")
            XCTAssertGreaterThan(SystemLogAccessor.NSLogArray().count, nsLogArrayCountBefore, "This application should have increased its number of logs due to the detected errors")
            // @todo Consider verifying the messages instead of just the count
        }
    }
    
    /// Generic function to be used by any test of `findDeparturesByRouteId`
    /// - Parameter stubResponse: the block that returns an `OHHTTPStubsResponse` with stubbed NSData/NSDictionary
    /// - Parameter restApiCompletion: the `findDeparturesByRouteId` completion block
    private func testFindDeparturesByRouteId(stubResponse: OHHTTPStubsResponseBlock, restApiCompletion: (departures: [Departure]?) -> Void)
    {
        stub(isHost("api.appglu.com") && isPath("/v1/queries/findDeparturesByRouteId/run"), response: stubResponse)
        
        var didExecuteCompletion = false
        RestApi.findDeparturesByRouteId(7664576, completion: { departures in
            restApiCompletion(departures: departures)
            didExecuteCompletion = true
        })
        
        // loop until the expectation is fulfilled:
        waitForExpectationsWithTimeout(expectationTimeout) { error in
            XCTAssertNil(error, "Expectation timeout")
        }
        
        XCTAssertTrue(didExecuteCompletion, "The completion block must be executed")
    }
    
    // MARK: - XCTestExpectation definitions
    
    private let expectationTimeout: NSTimeInterval = 5 // just a big enough timeout for the expectations
    
    private var expectation: XCTestExpectation?
    
    func onDone(results: String){
        expectation?.fulfill()
    }
}
