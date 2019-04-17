//
//  EX_NSLayoutConstraint.swift
//  shealthcare
//
//  Created by SangWooKim on 05/04/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit
import Foundation

extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem as Any, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}
