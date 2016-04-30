//
//  Language+CoreDataProperties.swift
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

extension Language {

    @NSManaged var name: String?
    @NSManaged var languageCode: String?

}
