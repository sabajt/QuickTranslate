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
    
    class func fetchLanguage(moc: NSManagedObjectContext, code: String) -> Language? {
        let fetchRequest = NSFetchRequest(entityName: "Language")
        fetchRequest.predicate = NSPredicate(format: "languageCode = %@", code)
        
        var results: [Language] = []
        do {
            results = try moc.executeFetchRequest(fetchRequest) as! [Language]
        } catch let error as NSError {
            print("Failed to fetch languages: \(error.userInfo)")
        }
        
        if results.count > 1 {
            print("Warning: found more than one language with language code: \(code)")
        }
        
        guard let language = results.first else {
            return nil
        }
        
        return language
    }
    
    class func fetchSelectedLanguage(moc: NSManagedObjectContext) -> Language? {
        return Language.fetchLanguage(moc, code: DataManager.sharedInstance.selectedLanguageCode)
    }
    
    class func syncLanguagesInBackground(json: [[String: String]], parentMoc: NSManagedObjectContext, completion: ((success: Bool) -> Void)?=nil) {

        let privateMoc = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        privateMoc.parentContext = parentMoc
        privateMoc.performBlock {
            let existingLanguages = Language.fetchLanguagesAscending(privateMoc)
            var languageCodesFromResponse = [String]()
            
            for dictionary in json {
                // Make sure there is a language code, and keep track of it
                guard let languageCode = dictionary["language"] else {
                    print("Warning: Failed to parse language json, ignoring malformed data")
                    continue
                }
                languageCodesFromResponse.append(languageCode)
                
                // Create a new language if no match is found
                if Language.fetchLanguage(privateMoc, code: languageCode) == nil {
                    Language.createLanguage(dictionary, moc: privateMoc)
                }
            }
            
            // Delete any language in our local store which is not part of the JSON payload
            for language in existingLanguages {
                if let languageCode = language.languageCode {
                    if languageCodesFromResponse.indexOf(languageCode) == nil {
                        privateMoc.deleteObject(language)
                    }
                }
            }
            
            do {
                try privateMoc.save()
            } catch {
                print("Failure to save context: \(error)")
                if let c = completion {
                    c(success: false)
                }
                return
            }
            
            if let c = completion {
                c(success: true)
            }
        }
    }
}



