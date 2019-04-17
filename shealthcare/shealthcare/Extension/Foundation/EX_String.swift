//
//  EX_String.swift
//  shealthcare
//
//  Created by SangWooKim on 11/03/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit
import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: self)
    }
    
    func encodeUrl() -> String {
        return self.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
    }
    
    func encodeUrlKr() -> String {
        let query = self
        let rawEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.EUC_KR.rawValue))
        let encoding = String.Encoding(rawValue: rawEncoding)
        
        let eucKRStringData = query.data(using: encoding) ?? Data()
        let outputQuery = eucKRStringData.map {byte->String in
            if byte >= UInt8(ascii: "A") && byte <= UInt8(ascii: "Z")
                || byte >= UInt8(ascii: "a") && byte <= UInt8(ascii: "z")
                || byte >= UInt8(ascii: "0") && byte <= UInt8(ascii: "9")
                || byte == UInt8(ascii: "_") || byte == UInt8(ascii: ".") || byte == UInt8(ascii: "-")
            {
                return String(Character(UnicodeScalar(UInt32(byte))!))
            } else if byte == UInt8(ascii: " ") {
                return "+"
            } else {
                return String(format: "%%%02X", byte)
            }
            }.joined()
        
        return outputQuery
    }
    
    func decodeUrl() -> String {
        return self.removingPercentEncoding!
    }
    
    func lineEnter() -> String {
        return self.replacingOccurrences(of: String("\\r"), with: "").replacingOccurrences(of: String("\\n"), with: "\n")
    }
    
    func alert(_ viewController:UIViewController,
               buttonCompletion: ((UIAlertAction) -> Void)? = nil,
               buttonCancel: ((UIAlertAction) -> Void)? = nil) {
        var title:String? = nil
        var msg:String = self
        
        let temp = self.components(separatedBy: "|||")
        if temp.count > 1 {
            title = temp[0]
            msg = temp[1]
        }
        let alertController = UIAlertController(title: title, message: msg.lineEnter(), preferredStyle: UIAlertController.Style.alert)
        if buttonCompletion != nil && buttonCancel != nil {
            let okButton = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: buttonCompletion)
            let cancelButton = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: buttonCancel)
            alertController.addAction(okButton)
            alertController.addAction(cancelButton)
            
        } else {
            let cancelButton = UIAlertAction(title: "확인", style: UIAlertAction.Style.cancel, handler: buttonCompletion)
            alertController.addAction(cancelButton)
        }
        
        viewController.present(alertController,animated: true,completion: nil)
    }
    
    func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version) build \(build)"
    }
    
    func toDate(_ format:String!) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_kr")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST") // "2018-03-21 18:07:27"
        dateFormatter.dateFormat = format
        
        let date = dateFormatter.date(from: self)
        return date ?? nil
    }
    
    func ageKr() -> Int {
        let _now:Date = Date()
        let _birthDate:Date = self.toDate("yyyyMMdd")!
        
        var _age:Int = Int(_now.toString("yyyy"))! - Int(_birthDate.toString("yyyy"))!
        if _now.toString("MMdd") >= _birthDate.toString("MMdd") {
        } else {
            _age = _age - 1
        }
        
        return _age
    }
    
    func safelyLimitedTo(length n: Int)->String {
        if (self.count <= n) {
            return self
        }
        return String( Array(self).prefix(upTo: n) )
    }
    
    // 이메일 정규식
    func validateEmail() -> Bool {
        let emailRegEx = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
        
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: self)
    }
    
    // 패스워드
    func validatePassword() -> Bool {
        
//        let passwordRegEx = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8}$"
        let passwordRegEx = "^(?=.*[a-zA-Z])(?=.*[0-9]).{8,13}$"
        
        let predicate = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return predicate.evaluate(with: self)
    }
    
    var comma: String {
        get {
            let _val = NSNumber(value: Float(self)!)
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            if let formattedNumber = numberFormatter.string(from: _val) {
                return formattedNumber
            }
            
            return String(format: "%@", _val)
        }
    }
    
    func toInt() -> Int {
        if self == "" {
            return 0
        }
        return Int(self)!
    }
    
    func toDouble() -> Double {
        if self == "" {
            return 0.0
        }
        return Double(self)!
    }
    
    func toFloat() -> Float {
        if self == "" {
            return 0.0
        }
        return Float(self)!
    }
}


import SwiftyXMLParser
extension XML.Accessor {
    func getText(_ key:Int, _ def:String = "") -> String {
        return getText(String(format: "d"), def)
    }
    func getText(_ key:String, _ def:String = "") -> String {
        return self[key].text ?? def
    }
}
