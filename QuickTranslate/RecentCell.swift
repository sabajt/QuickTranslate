//
//  RecentCell.swift
//  QuickTranslate
//
//  Created by John Saba on 4/30/16.
//  Copyright © 2016 John Saba. All rights reserved.
//

import UIKit

class RecentCell: UITableViewCell {

    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var translatedLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    
    func configureWithPhrase(phrase: Phrase) {
        if let sourceText = phrase.sourceText, translatedText = phrase.translatedText, languageName = phrase.language?.name {
            sourceLabel.text = sourceText
            translatedLabel.text = translatedText
            languageLabel.text = languageName
        }
    }
    
}
