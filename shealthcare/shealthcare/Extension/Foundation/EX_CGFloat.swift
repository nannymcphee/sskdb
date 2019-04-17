//
//  EX_CGFloat.swift
//  shealthcare
//
//  Created by SangWooKim on 12/03/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit
import Foundation

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension Int {
    func toString() -> String {
        return String(format: "%d", self)
    }
    func toTimeString() -> String {
        let seconds = Float(self)
        let hour = Int(seconds / 3600.0)
        let min = Int(seconds.truncatingRemainder(dividingBy: 3600.0) / 60.0)
        let sec = Int(seconds.truncatingRemainder(dividingBy: 3600.0).truncatingRemainder(dividingBy: 60.0))
        return String(format: "%02d:%02d:%02d", hour, min, sec)
    }
    func upDown() -> String {
        var updown:String = ""
        if self > 0 {
            updown = " ▲"
        } else if self < 0 {
            updown = " ▼"
        }
        return updown
    }
}

extension Float {
    func toString(digits:Int? = nil) -> String {
        if let digits = digits {
            return String(format: "%."+digits.toString()+"f", self)
        }
        return String(format: "%f", self)
    }
    func upDown() -> String {
        var updown:String = ""
        if self > 0 {
            updown = " ▲"
        } else if self < 0 {
            updown = " ▼"
        }
        return updown
    }
}
