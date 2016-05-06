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
    
    // Sample Data
    
    let singleLanguageJson = ["language": "a", "name" : "language a"]
    
    let smallLanguageJson = [["language": "b", "name" : "language b"],
                             ["language": "a", "name" : "language a"],
                             ["language": "c", "name" : "language c"]]
    
    lazy var moc: NSManagedObjectContext = {
        return DataManager.createInMemoryManagedObjectContext()
    }()
    
    override func tearDown() {
        moc.reset()
        super.tearDown()
    }
    
    // Language
    
    func testCreateLanguage() {
        let language = Language.createLanguage(singleLanguageJson, moc: moc)
        XCTAssert(language?.languageCode == singleLanguageJson["language"], "Failed to create Language entity with correct \"language\" field.")
        XCTAssert(language?.name == singleLanguageJson["name"], "Failed to create Language entity with correct \"name\" field.")
    }
    
    func testFetchLanguagesAscending() {
        for json in smallLanguageJson {
            Language.createLanguage(json, moc: moc)
        }
        
        let results = Language.fetchLanguagesAscending(moc)
        XCTAssert(results.count == 3, "")
        XCTAssert(results[0].name == "language a", "Failed to fetch languages in ascending order")
        XCTAssert(results[1].name == "language b", "Failed to fetch languages in ascending order")
        XCTAssert(results[2].name == "language c", "Failed to fetch languages in ascending order")
    }
}
