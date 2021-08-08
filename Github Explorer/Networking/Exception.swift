//
//  Exception.swift
//  Demo
//
//  Created by Pushpsen Airekar on 23/11/18.
//  Copyright © 2021 Pushpsen Airekar. All rights reserved.
//

import UIKit


@objc public protocol CustomError{
    
    var errorDescription:String { get };
    var errorCode: String { get }
}


public class GithubException: NSObject,CustomError {
    
    public var errorDescription: String;
    public var errorCode: String;
    
    public init(errorCode:String,errorDescription:String) {
        
        self.errorDescription = errorDescription;
        self.errorCode = errorCode;
        
    }
}

internal enum NetworkErrors : String, Error {
    
    case parametersNil = "Parameters were nil."
    case encodingFailed = "Parameter encoding failed."
    case missingURL = "URL is nil."
    case noInternetConnection = "Internet Connection appears to be offline."
}

internal enum NetworkResponse:String {
    case success
    case authenticationError = "You need to be authenticated first."
    case badRequest = "Bad request"
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
}

