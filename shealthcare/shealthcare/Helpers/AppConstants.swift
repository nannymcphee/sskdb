//
//  AppConstants.swift
//
//
//  Created by Duy Nguyen on 10/3/18.
//  Copyright © 2018 Duy Nguyen. All rights reserved.
//

import UIKit

class AppConstants {
    public static let screenWidth = UIScreen.main.bounds.width
    public static let screenHeight = UIScreen.main.bounds.height
    static let letters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
    static let digit = CharacterSet(charactersIn: "0123456789")
    static let specialText = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789[,./-=+}{[]`~'!@£$%^&*():;?0-9] ")
    static let GOOGLE_API_KEY =  "AIzaSyA7ipZDIRp9XmrFCVupdu1xzRVEj70R4NE"
    static let appFontBold = "HelveticaNeue-Bold"
    static let appFontRegular = "HelveticaNeue"
    static let appFontMedium = "HelveticaNeue-Medium"
    static let statusBarHeight = UIApplication.shared.statusBarFrame.height
    static let navigationBarHeight = (UIApplication.shared.delegate as! AppDelegate).navigationController?.navigationBar.frame.height
    static let topBarHeight = AppConstants.navigationBarHeight.or(other: 0.0) + AppConstants.statusBarHeight
}

struct ErrorVali: Error, LocalizedError {
    
    public let message: String
    public var errorDescription: String? {
        return NSLocalizedString(message, comment: "")
    }
    
    public init(message m: String) {
        message = m
    }
}

struct CustomError: Error, LocalizedError {
    public var message: String
    public var errorDescription: String? {
        return NSLocalizedString(message, comment: "")
    }
    
    public init(message m: String) {
        message = m
    }
    
}

struct NetworkError: Error, LocalizedError {
    public var message: String
    public var errorDescription: String? {
        return NSLocalizedString(message, comment: "")
    }
    
    init() {
        self.message = "No Network Connection."
    }
    
}
