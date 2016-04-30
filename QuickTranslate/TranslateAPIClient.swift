//
//  TranslateAPIClient.swift
//  QuickTranslate
//
//  Created by John Saba on 4/29/16.
//  Copyright © 2016 John Saba. All rights reserved.
//

import Alamofire

class TranslationAPIClient {
    static let sharedInstance = TranslationAPIClient()
    
    private let googleAPIKey = "AIzaSyBKKwGsyIBLE_8j5kRVhA8YZLEXroP11N0"
    private let baseURLString = "https://www.googleapis.com/language/translate/v2"
    private let sourceLanguageCode = "en"
    
    func getSupportedLanguages() {
        let urlString = baseURLString + "/languages"
        let params = ["key": googleAPIKey, "target": sourceLanguageCode]
        
        Alamofire.request(.GET, urlString, parameters: params).responseJSON { response in
            if response.result.isFailure {
                let errorMessage = self.errorMessageFromResponse(response)
                print(errorMessage)
            } else if let json = response.result.value {
                print(json)
            }
        }
    }
    
    func getTranslation(text: String, languageCode: String) {
        let params = ["key": googleAPIKey, "source": sourceLanguageCode, "target": languageCode, "q" : text]
        
        Alamofire.request(.GET, baseURLString, parameters: params).responseJSON { response in
            if response.result.isFailure {
                let errorMessage = self.errorMessageFromResponse(response)
                print(errorMessage)
            } else if let json = response.result.value {
                print(json)
            }
        }
    }
    
    func errorMessageFromResponse(response: Response<AnyObject, NSError>) -> String {
        var errorMessage = "Failure: "
        if let urlResponse = response.response {
            errorMessage += "\(urlResponse.statusCode)"
        } else {
            errorMessage += "Unknown Error"
        }
        return errorMessage
    }
}