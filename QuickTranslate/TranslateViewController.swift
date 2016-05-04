//
//  TranslateViewController.swift
//  QuickTranslate
//
//  Created by John Saba on 4/29/16.
//  Copyright © 2016 John Saba. All rights reserved.
//

import UIKit

class TranslateViewController: UIViewController {
    
    static let keyboardTransitionDuration: NSTimeInterval = 0.3
    static let dismissKeyboardButtonDefaultAlpha: CGFloat = 0.2

    @IBOutlet weak var entryTextView: UITextView!
    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var dismissKeyboardButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dismissKeyboardButton.hidden = true
        
        updateSelectedLanguageCode()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TranslateViewController.updateSelectedLanguageCode), name: DataManager.selectedLanguageCodeChangedNotification, object: nil)
    }
    
    @IBAction func dismissKeyboardButtonPressed(sender: UIButton) {
        hideKeyboard()
    }
    
    func showKeyboard() {
        dismissKeyboardButton.hidden = false
        UIView.animateWithDuration(TranslateViewController.keyboardTransitionDuration) {
            self.dismissKeyboardButton.alpha = TranslateViewController.dismissKeyboardButtonDefaultAlpha
        }
    }
    
    func hideKeyboard() {
        entryTextView.resignFirstResponder()
        
        UIView.animateWithDuration(TranslateViewController.keyboardTransitionDuration, animations: {
            self.dismissKeyboardButton.alpha = 0
        }) { (_) in
            self.dismissKeyboardButton.hidden = true
        }
    }
    
    func updateSelectedLanguageCode() {
        if let barButtonItem = navigationItem.rightBarButtonItem {
            if let language = Language.fetchSelectedLanguage(DataManager.sharedInstance.managedObjectContext) {
                barButtonItem.title = language.name
            } else {
                // When first opening the app and before viewing the select languages screen,
                // we haven't made a request to Google API for available languages
                barButtonItem.title = DataManager.defautlLanguageName
            }
        }
    }
}

extension TranslateViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        showKeyboard()
        return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if let query = textView.text where query.characters.count > 0 {
                
                TranslationAPIClient.sharedInstance.getTranslation(query, languageCode: DataManager.sharedInstance.selectedLanguageCode) { (errorMessage, translated) in
                    print("error: \(errorMessage)")
                    print("translated: \(translated)")
                }
            }
            hideKeyboard()
            return false
        }
        return true
    }
}
