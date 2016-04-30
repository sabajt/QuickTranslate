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
    
    func getSupportedLanguages(completion: (errorMessage: String?, json: [[String: String]]?) -> Void) {
        let urlString = baseURLString + "/languages"
        let params = ["key": googleAPIKey, "target": sourceLanguageCode]
        
        Alamofire.request(.GET, urlString, parameters: params).validate().responseJSON { response in
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