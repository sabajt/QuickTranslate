//
//  SelectLanguageCell.swift
//  QuickTranslate
//
//  Created by John Saba on 5/3/16.
//  Copyright © 2016 John Saba. All rights reserved.
//

import UIKit

class SelectLanguageCell: UITableViewCell {

    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var checkIcon: UIImageView!
    
    func configureWithLanguage(language: Language, checkVisible: Bool) {
        if let name = language.name {
            languageLabel.text = name
            checkIcon.hidden = !checkVisible
        }
    }
}
