//
//  Phrase.swift
//  
//
//  Created by John Saba on 4/30/16.
//
//

import Foundation
import CoreData


class Phrase: NSManagedObject {

    class func createPhrase(language: Language, sourceText: String, translatedText: String, dateCreated: NSDate, moc: NSManagedObjectContext) -> Phrase? {
        
        guard let entity = NSEntityDescription.entityForName("Phrase", inManagedObjectContext: moc) else {
            print("Failed to create Phrase object: couldn't find entity \"Phrase\"")
            return nil
        }
        
        let phrase = NSManagedObject(entity: entity, insertIntoManagedObjectContext: moc) as! Phrase
        phrase.sourceText = sourceText
        phrase.translatedText = translatedText
        phrase.dateCreated = dateCreated
        
        // Make sure our language to assign for relation is in the same context as the newly created Phrase.
        // This is important when we passed in a language from the main context but are creating a phrase in the background.
        let safeLanguage = Language.fetchLanguage(moc, code: language.languageCode!)
        phrase.language = safeLanguage
        
        return phrase
    }
    
    // Convenience for checking and updating an identical phrase before adding a new one
    class func createOrUpdatePhraseInBackground(language: Language, sourceText: String, translatedText: String, dateCreated: NSDate, parentMoc: NSManagedObjectContext, completion: ((success: Bool) -> Void)?=nil) {
        
        let privateMoc = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        privateMoc.parentContext = parentMoc
        privateMoc.performBlock {
            
            let fetchRequest = NSFetchRequest(entityName: "Phrase")
            fetchRequest.predicate = NSPredicate(format: "language.languageCode = %@ AND sourceText LIKE[c] %@ AND translatedText LIKE[c] %@", language.languageCode!, sourceText, translatedText)
            
            var results: [Phrase] = []
            do {
                results = try privateMoc.executeFetchRequest(fetchRequest) as! [Phrase]
            } catch let error as NSError {
                print("Failed to execute fetch request: \(error.userInfo)")
                if let c = completion {
                    c(success: false)
                }
                return
            }
            
            // If we found the same phrase, just update its date. Otherwise, create one
            if let phrase = results.first {
                phrase.dateCreated = dateCreated
            } else {
                Phrase.createPhrase(language, sourceText: sourceText, translatedText: translatedText, dateCreated: dateCreated, moc: privateMoc)
            }

            do {
                try privateMoc.save()
            } catch {
                if let c = completion {
                    c(success: false)
                }
                return
            }
            
            // Success!
            if let c = completion {
                c(success: true)
            }
        }
    }
    
    class func mostRecentFetchRequest(limitToLanguageCode: NSString?=nil) -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: "Phrase")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]
        
        if let languageCode = limitToLanguageCode {
           fetchRequest.predicate = NSPredicate(format: "language.languageCode = %@", languageCode)
        }
        
        return fetchRequest
    }
    
    class func fetchPhrasesByMostRecent(moc: NSManagedObjectContext, languageCode: NSString?=nil) -> [Phrase] {
        let fetchRequest = mostRecentFetchRequest(languageCode)
        
        var results: [Phrase] = []
        do {
            results = try moc.executeFetchRequest(fetchRequest) as! [Phrase]
        } catch let error as NSError {
            print("Failed to fetch phrases: \(error.userInfo)")
        }
        return results
    }
}
