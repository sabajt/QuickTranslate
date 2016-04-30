//
//  SelectLanguageController.swift
//  QuickTranslate
//
//  Created by John Saba on 4/30/16.
//  Copyright © 2016 John Saba. All rights reserved.
//

import UIKit

class SelectLanguageController: UITableViewController {
    
    // placeholder until data model is set up
    var languages: [AnyObject] = []
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LanguageCell", forIndexPath: indexPath)
        return cell
    }
}
