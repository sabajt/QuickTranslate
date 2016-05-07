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
    
    func testGetSupportedLanguagesStatusFailure() {
        
        CannedURLProtocol.setCannedResponse(400, contentType: "application/json", json: ["":""])
        
        let expectation = expectationWithDescription("Get supported completion block")
        TranslationAPIClient.sharedInstance.getSupportedLanguages { (errorMessage, json) in
            XCTAssert(errorMessage == "Failure: 400", "Get supported languages failure: expected message to report 400 error")
            XCTAssert(json == nil, "Get supported languages failure: expected json to be nil")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10) { (error) in
            if let err = error {
                print("error: \(err)")
            }
        }
    }
    
    func testGetSupportedLanguagesMalformedResponse() {
        
        let responseJson = [
            "data": [
                "some_unexpected_field_where_languages_should_be":[
                    ["language": "en"],
                    ["language": "fr"],
                    ["language": "sp"]
                ]
            ]
        ]
        
        CannedURLProtocol.setCannedResponse(200, contentType: "application/json", json: responseJson)
        
        let expectation = expectationWithDescription("Get supported completion block")
        TranslationAPIClient.sharedInstance.getSupportedLanguages { (errorMessage, json) in
            XCTAssert(errorMessage == "Failure: No languages field", "Get supported languages failure: expected message to report a malformed response")
            XCTAssert(json == nil, "Get supported languages failure: expected json to be nil")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10) { (error) in
            if let err = error {
                print("error: \(err)")
            }
        }
    }
    
    func testGetTranslationSuccess() {
        
        let responseJson = [
            "data": [
                "translations":[
                    ["translatedText": "Hallo Welt"]
                ]
            ]
        ]
        
        CannedURLProtocol.setCannedResponse(200, contentType: "application/json", json: responseJson)
        
        let expectation = expectationWithDescription("Get translation completion block")
        TranslationAPIClient.sharedInstance.getTranslation("", languageCode: "") { (errorMessage, translatedText) in
            XCTAssert(errorMessage == nil, "Get translation failure: expected no error")
            
            guard let text = translatedText as String! else {
                XCTFail("Get translation failure: expected completion to provide a string from succesfull response")
                expectation.fulfill()
                return
            }
            
            XCTAssert(text == "Hallo Welt", "Get translation failure: incorrect string provided from response")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10) { (error) in
            if let err = error {
                print("error: \(err)")
            }
        }
    }
    
    func testGetTranslationFailure() {
        
        CannedURLProtocol.setCannedResponse(400, contentType: "application/json", json: ["":""])
        
        let expectation = expectationWithDescription("Get translation completion block")
        TranslationAPIClient.sharedInstance.getTranslation("", languageCode: "") { (errorMessage, translatedText) in
            XCTAssert(errorMessage == "Failure: 400", "Get translation failure: expected message to report 400 error")
            XCTAssert(translatedText == nil, "Get translation failure: expected text to be nil")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10) { (error) in
            if let err = error {
                print("error: \(err)")
            }
        }
    }
    
    func testGetTranslationMalformedResponse() {
        
        let responseJson = [
            "data": [
                "translations":[
                    ["what_if_google_changed_their_API_without_informing_anyone?": "Hallo Welt"]
                ]
            ]
        ]
        
        CannedURLProtocol.setCannedResponse(200, contentType: "application/json", json: responseJson)
        
        let expectation = expectationWithDescription("Get translation completion block")
        TranslationAPIClient.sharedInstance.getTranslation("", languageCode: "") { (errorMessage, translatedText) in
            XCTAssert(errorMessage == "Failure: No translatedText field", "Get translation failure: expected message to report a malformed response")
            XCTAssert(translatedText == nil, "Get supported languages failure: expected text to be nil")
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10) { (error) in
            if let err = error {
                print("error: \(err)")
            }
        }
    }
}

