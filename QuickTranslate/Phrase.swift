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

    class func createPhrase(languageCode: String, sourceText: String, translatedText: String, dateCreated: NSDate, moc: NSManagedObjectContext) -> Phrase? {
        
        guard let entity = NSEntityDescription.entityForName("Phrase", inManagedObjectContext: moc) else {
            print("Failed to create Phrase object: couldn't find entity 'Phrase'")
            return nil
        }
        
        let phrase = NSManagedObject(entity: entity, insertIntoManagedObjectContext: moc) as! Phrase
        phrase.languageCode = languageCode
        phrase.sourceText = sourceText
        phrase.translatedText = translatedText
        phrase.dateCreated = dateCreated
        
        return phrase
    }
    
    // Convenience for checking and updating an identical phrase before adding a new one
    class func createOrUpdatePhraseInBackground(languageCode: String, sourceText: String, translatedText: String, dateCreated: NSDate) {
        
        let privateMoc = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        privateMoc.parentContext = DataManager.sharedInstance.managedObjectContext
        privateMoc.performBlock {
            
            let fetchRequest = NSFetchRequest(entityName: "Phrase")
            fetchRequest.predicate = NSPredicate(format: "languageCode = %@ AND sourceText LIKE[c] %@ AND translatedText LIKE[c] %@", languageCode, sourceText, translatedText)
            
            var results: [Phrase] = []
            do {
                results = try privateMoc.executeFetchRequest(fetchRequest) as! [Phrase]
            } catch let error as NSError {
                print("Failed to fetch phrases: \(error.userInfo)")
                return
            }
            
            // If we found the same phrase, just update its date. Otherwise, create one
            if let phrase = results.first {
                phrase.dateCreated = dateCreated
            } else {
                Phrase.createPhrase(languageCode, sourceText: sourceText, translatedText: translatedText, dateCreated: dateCreated, moc: privateMoc)
            }

            do {
                try privateMoc.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
}
