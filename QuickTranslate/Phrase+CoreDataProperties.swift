//
//  Phrase+CoreDataProperties.swift
//  
//
//  Created by John Saba on 5/8/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Phrase {

    @NSManaged var dateCreated: NSDate?
    @NSManaged var sourceText: String?
    @NSManaged var translatedText: String?
    @NSManaged var language: Language?

}
