//
//  FilterLanguageViewController.swift
//  QuickTranslate
//
//  Created by John Saba on 5/8/16.
//  Copyright © 2016 John Saba. All rights reserved.
//

import UIKit
import CoreData

protocol FilterLanguageViewControllerDelegate {
    
    var filteredLanguageCode: String? { get set }
}

class FilterLanguageViewController: UITableViewController {
    
    var delegate: FilterLanguageViewControllerDelegate?

    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = Language.orderByAlphaFetchRequest(true, limitToLanguagesContainingSavedPhrases: true)
        
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
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        return sections[section].numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SelectLanguageCell", forIndexPath: indexPath) as! SelectLanguageCell
        if let language = fetchedResultsController.objectAtIndexPath(indexPath) as? Language {
            let filtered = (language.languageCode == delegate?.filteredLanguageCode)
            cell.configureWithLanguage(language, checkVisible: filtered)
        }
        return cell
    }
    
    // MARK: - UITableViewDataDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let
            language = fetchedResultsController.objectAtIndexPath(indexPath) as? Language,
            languageCode = language.languageCode,
            var filteredDelegate = delegate else {
                return
        }
        
        var updatedIndexPaths = [indexPath]
        if let lastLanguageCode = filteredDelegate.filteredLanguageCode {
            
            // If it's the same language, clear the filter
            if lastLanguageCode == languageCode {
                filteredDelegate.filteredLanguageCode = nil
                tableView.reloadRowsAtIndexPaths(updatedIndexPaths, withRowAnimation: .Automatic)
                return
            }
            
            // Otherwise if the language exists but it's not the same, collect the old index path to update
            if let lastLanguage = Language.fetchLanguage(DataManager.sharedInstance.managedObjectContext, code: lastLanguageCode) {
                if let lastIndexPath = fetchedResultsController.indexPathForObject(lastLanguage) {
                    updatedIndexPaths.append(lastIndexPath)
                }
            }
        }
        
        // update the filter
        filteredDelegate.filteredLanguageCode = languageCode
        tableView.reloadRowsAtIndexPaths(updatedIndexPaths, withRowAnimation: .Automatic)
    }
}

extension FilterLanguageViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
}



