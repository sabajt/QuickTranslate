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
        Language.syncLanguagesInBackground(smallLanguageJson, parentMoc: moc) { (success) in
            XCTAssert(success, "Expected sync languages operation success")
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
        Language.syncLanguagesInBackground(smallLanguageJson, parentMoc: moc) { (success) in
            XCTAssert(success, "Expected sync languages operation success")
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
        Language.syncLanguagesInBackground(largeLanguageJson, parentMoc: moc) { (success) in
            XCTAssert(success, "Expected sync languages operation success")
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
        Language.syncLanguagesInBackground(mediumLanguageJson, parentMoc: moc) { (success) in
            XCTAssert(success, "Expected sync languages operation success")
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
        Language.syncLanguagesInBackground(updatedLanguageJson, parentMoc: moc) { (success) in
            XCTAssert(success, "Expected sync languages operation success")
            self.saveInMemoryMoc()
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(10) { (error) in
            if let err = error {
                print(err)
            }
            let results = Language.fetchLanguagesAscending(self.moc)
            XCTAssert(results.count == self.updatedLanguageJson.count, "Failed to fetch 5 languages after syncing a data set that should both add and delete languages from the local store")
        }
    }
    
    // MARK: - Phrase
    
    func testCreatePhrase() {
        let now = NSDate()
        let phrase = Phrase.createPhrase("ct", sourceText: "Meow", translatedText: "Gimme dinner or I'll kill you in your sleep", dateCreated: now, moc: moc)
        XCTAssert(phrase?.languageCode == "ct", "Failed to create Phrase entity with correct \"languageCode\" field")
        XCTAssert(phrase?.sourceText == "Meow", "Failed to create Phrase entity with correct \"sourceText\" field")
        XCTAssert(phrase?.translatedText == "Gimme dinner or I'll kill you in your sleep", "Failed to create Phrase entity with correct \"translatedText\" field")
        XCTAssert((phrase?.dateCreated?.isEqualToDate(now))!, "Failed to create Phrase entity with correct \"dateCreated\" field")
    }

    func testCreateOrUpdatePhraseInBackground() {
        // Test syncing a new phrase with no existing phrases in local store
        let then = NSDate()
        var expectation = expectationWithDescription("Sync phrase completion block")
        Phrase.createOrUpdatePhraseInBackground("es", sourceText: "Hello", translatedText: "Hola", dateCreated: then, parentMoc: moc) { (success) in
            XCTAssert(success, "Expected phrase syncing success")
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(10) { (error) in
            if let err = error {
                print(err)
            }
        }
        saveInMemoryMoc()
        var results = Phrase.fetchPhrasesByMostRecent(moc)
        XCTAssert(results.count == 1, "Expected to fetch 1 phrase")

        // Test syncing the a phrase that matches an existing phrase in local store
        let now = NSDate()
        expectation = expectationWithDescription("Sync phrase completion block")
        Phrase.createOrUpdatePhraseInBackground("es", sourceText: "Hello", translatedText: "Hola", dateCreated: now, parentMoc: moc) { (success) in
            XCTAssert(success, "Expected phrase syncing success")
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(10) { (error) in
            if let err = error {
                print(err)
            }
        }
        saveInMemoryMoc()
        results = Phrase.fetchPhrasesByMostRecent(moc)
        XCTAssert(results.count == 1, "Expected to fetch 1 phrase")
        XCTAssert(results.first!.dateCreated == now, "Expected phrase to have old date overwritten with new date")
    }
    
    func testFetchPhrasesByMostRecent() {
        // Create some phrases with an ascending range of dates
        for i in 1...5 {
            let date = NSDate().dateByAddingTimeInterval(Double(i))
            
            // Make the source text just be an ascending number so we have a way to check the date fetch worked
            Phrase.createPhrase("arbitrary", sourceText: String(i), translatedText: "arbitrary:", dateCreated: date, moc: moc)
        }
        saveInMemoryMoc()
        
        // Verify that phrases fetched in the order by checking the source text
        let results = Phrase.fetchPhrasesByMostRecent(moc)
        var i = 1
        for phrase in results {
            XCTAssert(phrase.sourceText == String(i), "Unexpected phrase order")
            i += 1
        }
    }
}
