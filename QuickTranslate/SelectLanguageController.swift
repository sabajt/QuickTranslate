//
//  SelectLanguageController.swift
//  QuickTranslate
//
//  Created by John Saba on 4/30/16.
//  Copyright © 2016 John Saba. All rights reserved.
//

import UIKit
import CoreData

class SelectLanguageController: UITableViewController {
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = Language.orderByAlphaFetchRequest()
        let moc = DataManager.sharedInstance.managedObjectContext
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TranslationAPIClient.sharedInstance.getSupportedLanguages { (errorMessage, json) in
            if let message = errorMessage {
                print(message)
            } else if let languagesJson = json {
                Language.syncLanguagesInBackground(languagesJson)
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        return sections[section].numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SelectLanguageCell", forIndexPath: indexPath) as! SelectLanguageCell
        if let language = fetchedResultsController.objectAtIndexPath(indexPath) as? Language {
            cell.configureWithLanguage(language)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let language = fetchedResultsController.objectAtIndexPath(indexPath) as? Language else {
            return
        }
        if let languageCode = language.languageCode {
            let oldLanguageCode = DataManager.sharedInstance.selectedLanguageCode
            if oldLanguageCode != languageCode {
                // Update the stored preference
                DataManager.sharedInstance.selectedLanguageCode = languageCode
                
                // Update changed cells
                guard let oldLanguage = Language.fetchLanguage(DataManager.sharedInstance.managedObjectContext, code: oldLanguageCode) else {
                    return
                }
                guard let oldIndexPath = fetchedResultsController.indexPathForObject(oldLanguage) else {
                    return
                }
                tableView.reloadRowsAtIndexPaths([oldIndexPath, indexPath], withRowAnimation: .Automatic)
            }
        }
    }
}

extension SelectLanguageController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Move:
            break
        case .Update:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            if let language = anObject as? Language {
                let cell = self.tableView.cellForRowAtIndexPath(indexPath!)! as! SelectLanguageCell
                cell.configureWithLanguage(language)
            }
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
}
