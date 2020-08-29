//
//  DemoTests.swift
//  DemoTests
//
//  Created by Ricol Wang on 29/8/20.
//  Copyright © 2020 DeepSpace. All rights reserved.
//

import XCTest
@testable import Demo

class DemoTests: XCTestCase
{
    override func setUpWithError() throws
    {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAPICall() throws
    {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        APIService.github { (json) in
            XCTAssertTrue(json.count > 0)
        }
    }
}
