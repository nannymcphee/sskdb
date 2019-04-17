//
//  IB_UIButton.swift
//  shealthcare
//
//  Created by SangWooKim on 21/03/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit
import Foundation

private var __value = [UIButton: String]()

@IBDesignable extension UIButton {
    
    @IBInspectable var value: String {
        get {
            guard let l = __value[self] else {
                return ""
            }
            return l
        }
        set {
            __value[self] = newValue
        }
    }
}
