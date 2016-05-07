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
    private var sessionManager = Manager()

    // Only needed for custom session configuration, for example when mocking network calls for testing
    func setSessionConfiguration(configuration: NSURLSessionConfiguration?) {
        if let config = configuration {
            sessionManager = Manager(configuration: config)
        } else {
            sessionManager = Manager()
        }
    }
    
    func getSupportedLanguages(completion: (errorMessage: String?, json: [[String: String]]?) -> Void) {
        let urlString = baseURLString + "/languages"
        let params = ["key": googleAPIKey, "target": sourceLanguageCode]
        
        sessionManager.request(.GET, urlString, parameters: params).validate().responseJSON { response in
            if response.result.isFailure {
                let message = self.errorMessageFromResponse(response)
                completion(errorMessage: message, json: nil)
                return
            }
            guard let value = response.result.value else {
                completion(errorMessage: "Failure: No response value", json: nil)
                return
            }
            guard let data = value["data"] as? [String: AnyObject] else {
                completion(errorMessage: "Failure: No 'data' field", json: nil)
                return
            }
            guard let languages = data["languages"] as? [[String: String]] else {
                completion(errorMessage: "Failure: No 'languages' field", json: nil)
                return
            }
            completion(errorMessage: nil, json: languages)
        }
    }
    
    func getTranslation(text: String, languageCode: String, completion: (errorMessage: String?, translatedText: String?) -> Void) {
        let params = ["key": googleAPIKey, "source": sourceLanguageCode, "target": languageCode, "q" : text]
        
        sessionManager.request(.GET, baseURLString, parameters: params).validate().responseJSON { response in
            if response.result.isFailure {
                let message = self.errorMessageFromResponse(response)
                completion(errorMessage: message, translatedText: nil)
                return
            }
            guard let value = response.result.value else {
                completion(errorMessage: "Failure: No response value", translatedText: nil)
                return
            }
            guard let data = value["data"] as? [String: AnyObject] else {
                completion(errorMessage: "Failure: No data field", translatedText: nil)
                return
            }
            guard let translations = data["translations"] as? [[String: String]] else {
                completion(errorMessage: "Failure: No translations field", translatedText: nil)
                return
            }
            guard let firstTranslation = translations.first else {
                completion(errorMessage: "Failure: No translation results", translatedText: nil)
                return
            }
            guard let translatedText = firstTranslation["translatedText"] as String! else {
                completion(errorMessage: "Failure: No translatedText field", translatedText: nil)
                return
            }
            completion(errorMessage: nil, translatedText: translatedText)
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