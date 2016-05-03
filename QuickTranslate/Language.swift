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
    
    class func createLanguage(json: [String: String], moc: NSManagedObjectContext) -> Language? {
        
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

    class func fetchLanguagesAscending(moc: NSManagedObjectContext) -> [Language] {
        var results: [Language] = []
        do {
            results = try moc.executeFetchRequest(Language.orderByAlphaFetchRequest()) as! [Language]
        } catch let error as NSError {
            print("Failed to fetch languages: \(error.userInfo)")
        }
        return results
    }
    
    // TODO: Handle deleting stale languages
    class func syncLanguagesInBackground(json: [[String: String]]) {
        let privateMoc = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        privateMoc.parentContext = DataManager.sharedInstance.managedObjectContext
        privateMoc.performBlock {
            for dictionary in json {
                guard let languageCode = dictionary["language"] else {
                    print("Failed to parse language json")
                    continue
                }
                
                // Fetch all languages from the local store matching language codes from the json payload
                let fetchRequest = NSFetchRequest(entityName: "Language")
                fetchRequest.predicate = NSPredicate(format: "languageCode = %@", languageCode)
                
                var results: [Language] = []
                do {
                    results = try privateMoc.executeFetchRequest(fetchRequest) as! [Language]
                } catch let error as NSError {
                    print("Failed to fetch languages: \(error.userInfo)")
                    continue
                }
                
                // Create a new language if no match is found
                if results.count == 0 {
                    Language.createLanguage(dictionary, moc: privateMoc)
                }
            }
            
            do {
                try privateMoc.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
}



