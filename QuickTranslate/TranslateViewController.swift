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
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet weak var entryPlaceholderLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var needsUpdatedTranslation = false
    var resultsViewIsClear = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dismissKeyboardButton.hidden = true
        
        updateBarButtonName()
        clearResultTextView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TranslateViewController.handleLanguageCodeChanged), name: DataManager.selectedLanguageCodeChangedNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // If we changed the target language and have a current translation, update it
        if needsUpdatedTranslation {
            needsUpdatedTranslation = false
            if entryTextView.text.characters.count > 0 && !resultsViewIsClear {
                translateText(entryTextView.text)
            }
        }
    }
    
    @IBAction func dismissKeyboardButtonPressed(sender: UIButton) {
        focusEntryView(false)
    }
    
    @IBAction func xButtonPressed(sender: UIButton) {
        if entryTextView.text.characters.count > 0 {
            // Pressing the X button with text clears text
            entryTextView.text = ""
        } else {
            // Pressing the X button after text is already clears dismisses the keyboard
            focusEntryView(false)
        }
        clearResultTextView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Make sure entry text doesn't overlap with the X button
        let margin: CGFloat = 20
        entryTextView.textContainerInset.right = CGRectGetWidth(xButton.frame) * 0.8
        entryTextView.textContainerInset.left = margin
        resultTextView.textContainerInset.right = margin
        resultTextView.textContainerInset.left = margin
    }
    
    func focusEntryView(focus: Bool) {
        if focus {
            dismissKeyboardButton.hidden = false
            xButton.hidden = false
            
            UIView.animateWithDuration(TranslateViewController.keyboardTransitionDuration) {
                self.dismissKeyboardButton.alpha = TranslateViewController.dismissKeyboardButtonDefaultAlpha
                self.xButton.alpha = 1
            }
        } else {
            entryTextView.resignFirstResponder()
            
            UIView.animateWithDuration(TranslateViewController.keyboardTransitionDuration, animations: {
                self.xButton.alpha = 0
                self.dismissKeyboardButton.alpha = 0
            }) { (_) in
                self.xButton.hidden = true
                self.dismissKeyboardButton.hidden = true
            }
        }
    }
    
    func handleLanguageCodeChanged() {
        updateBarButtonName()
        
        // Set flag to check if we need an updated translation when the view reappears.
        needsUpdatedTranslation = true
    }
    
    func updateBarButtonName() {
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
    
    func updateResultTextView(result: String) {
        resultsViewIsClear = false
        resultTextView.textColor = UIColor.darkGrayColor()
        resultTextView.text = result
    }
    
    func clearResultTextView() {
        resultsViewIsClear = true
        resultTextView.textColor = UIColor.lightGrayColor()
        resultTextView.text = "Translation"
    }
    
    func translateText(query: String) {
        let languageCode = DataManager.sharedInstance.selectedLanguageCode
        
        resultTextView.text = ""
        activityIndicator.startAnimating()
        
        TranslationAPIClient.sharedInstance.getTranslation(query, languageCode: languageCode) { (errorMessage, translatedText) in
            self.activityIndicator.stopAnimating()
            if errorMessage != nil {
                print("error: \(errorMessage)")
            } else if let result = translatedText{
                self.updateResultTextView(result)
                Phrase.createOrUpdatePhraseInBackground(languageCode, sourceText: query, translatedText: result, dateCreated: NSDate(), parentMoc: DataManager.sharedInstance.managedObjectContext)
            }
        }
    }
}

extension TranslateViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        focusEntryView(true)
        return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if let query = textView.text where query.characters.count > 0 {
                translateText(query)
            }
            focusEntryView(false)
            return false
        } else {
            clearResultTextView()
        }
        return true
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        entryPlaceholderLabel.hidden = textView.text.characters.count > 0
    }
}
