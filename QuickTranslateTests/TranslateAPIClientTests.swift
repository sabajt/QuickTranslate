//
//  TranslateAPIClientTests.swift
//  QuickTranslate
//
//  Created by John Saba on 5/6/16.
//  Copyright © 2016 John Saba. All rights reserved.
//

import XCTest
import Alamofire
@testable import QuickTranslate

class TranslateAPIClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Mock network calls
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.protocolClasses = [CannedURLProtocol.self]
        TranslationAPIClient.sharedInstance.setSessionConfiguration(config)
    }
    
    override func tearDown() {
        TranslationAPIClient.sharedInstance.setSessionConfiguration(nil)
        
        super.tearDown()
    }
    
    func testGetSupportedLanguagesSuccess() {
        
        let responseJson = [
            "data": [
                "languages":[
                    ["language": "en"],
                    ["language": "fr"],
                    ["language": "sp"]
                ]
            ]
        ]
        
        CannedURLProtocol.setCannedResponse(200, contentType: "application/json", json: responseJson)
        
        let expectation = expectationWithDescription("Get supported completion block")
        TranslationAPIClient.sharedInstance.getSupportedLanguages { (errorMessage, json) in
            XCTAssert(errorMessage == nil, "Get supported languages failure: expected no error")
            
            guard let languages = json as [[String: String]]! else {
                XCTFail("Get supported languages failure: expected json response in form of [[String: String]]")
                expectation.fulfill()
                return
            }
            
            XCTAssert(languages.count == 3, "Get supported languages failure: expected 3 items in json response")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10) { (error) in
            if let err = error {
                print("error: \(err)")
            }
        }
    }
}

