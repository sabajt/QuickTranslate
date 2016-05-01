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
}

extension TranslateViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        showKeyboard()
        return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if let query = textView.text where query.characters.count > 0 {
                TranslationAPIClient.sharedInstance.getTranslation(query, languageCode: "es")
            }
            hideKeyboard()
            return false
        }
        return true
    }
}
