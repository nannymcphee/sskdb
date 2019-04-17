//
//  EX_Data.swift
//  shealthcare
//
//  Created by SangWooKim on 14/03/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit
import Foundation



extension Data {
    func toStringKr() -> String? {
        let encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0422))
        return String.init(data: self, encoding: encoding)
    }
}
