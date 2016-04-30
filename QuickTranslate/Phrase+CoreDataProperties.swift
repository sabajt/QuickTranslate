//
//  Phrase+CoreDataProperties.swift
//  
//
//  Created by John Saba on 4/30/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Phrase {

    @NSManaged var languageCode: String?
    @NSManaged var sourceText: String?
    @NSManaged var translatedText: String?
    @NSManaged var dateCreated: NSDate?

}
