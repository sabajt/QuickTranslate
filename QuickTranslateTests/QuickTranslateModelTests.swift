//
//  QuickTranslateModelTests.swift
//  QuickTranslateModelTests
//
//  Created by John Saba on 4/28/16.
//  Copyright © 2016 John Saba. All rights reserved.
//

import XCTest
import CoreData
@testable import QuickTranslate

class QuickTranslateModelTests: XCTestCase {
    
    // MARK: - Sample Data
    
    let singleLanguageJson = ["language": "a", "name" : "language a"]
    
    let smallLanguageJson = [["language": "b", "name" : "language b"],
                             ["language": "a", "name" : "language a"],
                             ["language": "c", "name" : "language c"]]
    
    let mediumLanguageJson = [["language": "a", "name" : "language a"],
                              ["language": "b", "name" : "language b"],
                              ["language": "c", "name" : "language c"],
                              ["language": "d", "name" : "language d"],]
    
    let largeLanguageJson = [["language": "a", "name" : "language a"],
                             ["language": "b", "name" : "language b"],
                             ["language": "c", "name" : "language c"],
                             ["language": "d", "name" : "language d"],
                             ["language": "e", "name" : "language e"]]
    
    let updatedLanguageJson = [["language": "f", "name" : "language f"],
                               ["language": "b", "name" : "language b"],
                               ["language": "c", "name" : "language c"],
                               ["language": "d", "name" : "language d"],
                               ["language": "e", "name" : "language e"]]
    
    // MARK: - Setup
    
    lazy var moc: NSManagedObjectContext = {
        return DataManager.createInMemoryManagedObjectContext()
    }()
    
    override func tearDown() {
        moc.reset()
        super.tearDown()
    }
    
    // MARK: - Helpers
    
    func saveInMemoryMoc() {
        do {
            try moc.save()
        } catch {
            print("Failure to save context: \(error)")
            XCTFail()
        }
    }
    
    // MARK: - Language
    
    func testCreateLanguage() {
        let language = Language.createLanguage(singleLanguageJson, moc: moc)
        XCTAssert(language?.languageCode == singleLanguageJson["language"], "Failed to create Language entity with correct \"language\" field.")
        XCTAssert(language?.name == singleLanguageJson["name"], "Failed to create Language entity with correct \"name\" field.")
    }
    
    func testFetchLanguagesAscending() {
        for json in smallLanguageJson {
            Language.createLanguage(json, moc: moc)
        }
        saveInMemoryMoc()
        
        let results = Language.fetchLanguagesAscending(moc)
        XCTAssert(results.count == 3, "Failed to fetch 3 languages")
        XCTAssert(results[0].name == "language a", "Failed to fetch languages in ascending order")
        XCTAssert(results[1].name == "language b", "Failed to fetch languages in ascending order")
        XCTAssert(results[2].name == "language c", "Failed to fetch languages in ascending order")
    }
    
    func testFetchLanguage() {
        for json in smallLanguageJson {
            Language.createLanguage(json, moc: moc)
        }
        saveInMemoryMoc()
        
        let language = Language.fetchLanguage(moc, code: "a")
        XCTAssert(language?.languageCode == "a", "Failed to fetch Language by langaugeCode")
    }
    
    func testSyncLanguages() {
        // Test syncing a small batch of languages with no existing local store
        var expectation = expectationWithDescription("Synchronize")
        Language.syncLanguagesInBackground(smallLanguageJson, parentMoc: moc) {
            self.saveInMemoryMoc()
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(10) { (error) in
            if let err = error {
                print(err)
            }
            let results = Language.fetchLanguagesAscending(self.moc)
            XCTAssert(results.count == self.smallLanguageJson.count, "Failed to fetch 3 languages after syncing new data with empty local data store")
        }
        
        // Test syncing the exact same data set
        expectation = expectationWithDescription("Synchronize")
        Language.syncLanguagesInBackground(smallLanguageJson, parentMoc: moc) {
            self.saveInMemoryMoc()
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(10) { (error) in
            if let err = error {
                print(err)
            }
            let results = Language.fetchLanguagesAscending(self.moc)
            XCTAssert(results.count == self.smallLanguageJson.count, "Failed to fetch 3 languages after syncing identical data over existing data store")
        }

        // Test syncing a larger data set with some overlapping languages
        expectation = expectationWithDescription("Synchronize")
        Language.syncLanguagesInBackground(largeLanguageJson, parentMoc: moc) {
            self.saveInMemoryMoc()
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(10) { (error) in
            if let err = error {
                print(err)
            }
            let results = Language.fetchLanguagesAscending(self.moc)
            XCTAssert(results.count == self.largeLanguageJson.count, "Failed to fetch 5 languages after syncing larger data set over existing data store")
        }
        
        // Test syncing a smaller data set than the local store
        expectation = expectationWithDescription("Synchronize")
        Language.syncLanguagesInBackground(mediumLanguageJson, parentMoc: moc) {
            self.saveInMemoryMoc()
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(10) { (error) in
            if let err = error {
                print(err)
            }
            let results = Language.fetchLanguagesAscending(self.moc)
            XCTAssert(results.count == self.mediumLanguageJson.count, "Failed to fetch 4 languages after syncing a smaller data set over existing data store")
        }
        
        // Test syncing a data set that should both add and delete languages from the local store
        expectation = expectationWithDescription("Synchronize")
        Language.syncLanguagesInBackground(updatedLanguageJson, parentMoc: moc) {
            self.saveInMemoryMoc()
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(10) { (error) in
            if let err = error {
                print(err)
            }
            let results = Language.fetchLanguagesAscending(self.moc)
            XCTAssert(results.count == self.updatedLanguageJson.count, "Failed to fetch 5 languages after syncing a smaller data set over existing data store")
        }
    }
}
