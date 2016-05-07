//
//  CannedURLProtocol.swift
//  QuickTranslate
//
//  Created by John Saba on 5/7/16.
//  Copyright © 2016 John Saba. All rights reserved.
//

import Foundation

class CannedURLProperties {
    
    static let sharedInstance = CannedURLProperties()
    
    var responseCode: Int?
    var responseData: NSData?
    var responseHeaders: [String: String]?
}

class CannedURLProtocol: NSURLProtocol {
    
    class func setCannedResponse(status: Int, contentType: String?, json:AnyObject) {
        
        CannedURLProperties.sharedInstance.responseCode = status
        if let type = contentType {
            CannedURLProperties.sharedInstance.responseHeaders = ["content-type": type]
        }
        
        do {
            CannedURLProperties.sharedInstance.responseData = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions.init(rawValue: 0))
        } catch {
            print("CannedURLProtocol failed to serialize json")
            return
        }
    }
    
    override class func canInitWithRequest(request: NSURLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequestForRequest(request: NSURLRequest) -> NSURLRequest {
        return request
    }
    
    override class func requestIsCacheEquivalent(a: NSURLRequest, toRequest b: NSURLRequest) -> Bool {
        return super.requestIsCacheEquivalent(a, toRequest:b)
    }
    
    override func startLoading() {
        
        print("start loading")
        
        
        guard let urlClient = client else {
            print("CannedURLProtocol start loading error: missing client")
            return
        }
        guard let url = request.URL else {
            print("CannedURLProtocol start loading error: missing request url")
            return
        }

        guard let respCode = CannedURLProperties.sharedInstance.responseCode else {
            print("CannedURLProtocol start loading error: missing response code")
            return
        }
        
        guard let respData = CannedURLProperties.sharedInstance.responseData else {
            print("CannedURLProtocol start loading error: missing response data")
            return
        }
        
        let respHeaders = CannedURLProperties.sharedInstance.responseHeaders
        
        guard let response = NSHTTPURLResponse(URL: url, statusCode: respCode, HTTPVersion: "HTTP/1.1", headerFields: respHeaders) else {
            print("CannedURLProtocol start loading error: failed to create HTTP url response")
            return
        }
        
        urlClient.URLProtocol(self, didReceiveResponse: response, cacheStoragePolicy:.NotAllowed)
        urlClient.URLProtocol(self, didLoadData: respData)
        urlClient.URLProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        // no-op
    }
}
