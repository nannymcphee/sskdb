//
//  EX_NSNumber.swift
//  shealthcare
//
//  Created by SangWooKim on 05/04/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit
import Foundation

extension NSNumber {
    var comma: String {
        get {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            if let formattedNumber = numberFormatter.string(from: self) {
                return formattedNumber
            }
            
            return String(format: "%@", self)
        }
    }
}
