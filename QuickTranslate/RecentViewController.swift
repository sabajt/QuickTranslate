//
//  RecentViewController.swift
//  QuickTranslate
//
//  Created by John Saba on 4/30/16.
//  Copyright © 2016 John Saba. All rights reserved.
//

import UIKit
import CoreData

class RecentViewController: UITableViewController {
    
    private var _filteredLanguageCode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .None
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        
        updateBarButtonName()
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = Phrase.mostRecentFetchRequest()
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
    
    func updateBarButtonName() {
        if let barButtonItem = navigationItem.rightBarButtonItem {
            if let languageCode = filteredLanguageCode {
                if let l = Language.fetchLanguage(DataManager.sharedInstance.managedObjectContext, code: languageCode), name = l.name {
                    barButtonItem.title = "Filter: \(name)"
                }
            } else {
                barButtonItem.title = "Filter: All Languages"
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Delegate allows us to update for a filtered language view
        if let filterVC = segue.destinationViewController as? FilterLanguageViewController {
            filterVC.delegate = self
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        return sections[section].numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RecentCell", forIndexPath: indexPath) as! RecentCell
        if let phrase = fetchedResultsController.objectAtIndexPath(indexPath) as? Phrase {
            cell.configureWithPhrase(phrase)
        }
        return cell
    }
}

extension RecentViewController: NSFetchedResultsControllerDelegate {
    
    // Just use the "easy" way to update everything:
    // Changes only happen as fast as a user can translate a new phrase,
    // and this change happens while the user is viewing another screen
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
    }
}

extension RecentViewController: FilterLanguageViewControllerDelegate {
    
    var filteredLanguageCode: String? {
        get {
            return _filteredLanguageCode
        }
        set {
            _filteredLanguageCode = newValue
            updateBarButtonName()
            
            // Update our fetched results controller to only show phrases from the filtered language
            let fetchRequest = Phrase.mostRecentFetchRequest(newValue)
            
            // fetchRequest is a read only property, but we can use the predicate and sortDescriptors from our convenience method
            fetchedResultsController.fetchRequest.predicate = fetchRequest.predicate
            fetchedResultsController.fetchRequest.sortDescriptors = fetchRequest.sortDescriptors
            
            do {
                try fetchedResultsController.performFetch()
            } catch {
                fatalError("Failed to initialize FetchedResultsController: \(error)")
            }
            
            tableView.reloadData()
        }
    }
}