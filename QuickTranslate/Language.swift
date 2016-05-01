//
//  Language.swift
//  
//
//  Created by John Saba on 4/30/16.
//
//

import Foundation
import CoreData

class Language: NSManagedObject {
    
    class func createLanguage(json: Dictionary<String, String>) -> Language? {
        let moc = DataManager.sharedInstance.managedObjectContext
        
        guard let entity = NSEntityDescription.entityForName("Language", inManagedObjectContext: moc) else {
            print("Failed to create Language object: couldn't find entity 'Language'")
            return nil
        }
        
        guard let languageCode = json["language"], let name = json["name"] else {
            print("Failed to create Language object: json was missing values")
            return nil
        }
        
        let language = NSManagedObject(entity: entity, insertIntoManagedObjectContext: moc) as! Language
        language.languageCode = languageCode
        language.name = name
        
        print("succesfully created language: \(language)")
        
        return language
    }
    
    class func orderByAlphaFetchRequest() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Language")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return fetchRequest
    }

    class func fetchLanguagesAscending() -> [Language] {
        var results: [Language] = []
        
        let moc = DataManager.sharedInstance.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Language")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            results = try moc.executeFetchRequest(fetchRequest) as! [Language]
        } catch let error as NSError {
            print("Failed to fetch languages: \(error.userInfo)")
        }
        
        return results
    }
}



