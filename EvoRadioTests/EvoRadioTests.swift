//
//  EvoRadioTests.swift
//  EvoRadioTests
//
//  Created by Jarvis on 07/08/2017.
//  Copyright © 2017 JQTech. All rights reserved.
//

import XCTest

@testable import EvoRadio

class EvoRadioTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    
    func testUser() {
        let json = ["uid":"123", "uName":"Jarvis"]
        let jsonString = "{\"uid\":\"234\", \"uName\":\"Tia\"}"
        
        let u1 = LRUser(JSON: json)
        let u2 = LRUser(JSONString: jsonString)
        
        XCTAssertEqual(u1?.uID, "123")
        XCTAssertEqual(u2?.uID, "Tia")
    }
}
