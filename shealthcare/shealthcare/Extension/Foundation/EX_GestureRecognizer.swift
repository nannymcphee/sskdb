//
//  EX_GestureRecognizer.swift
//  shealthcare
//
//  Created by SangWooKim on 12/04/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit
import Foundation

private var __UILongPressGestureRecognizerTag = [UILongPressGestureRecognizer: Int]()
private var __UILongPressGestureRecognizerLongPress = [UILongPressGestureRecognizer: ((UILongPressGestureRecognizer) -> Void)]()
extension UILongPressGestureRecognizer {
    var tag: Int? {
        get {
            guard let l = __UILongPressGestureRecognizerTag[self] else {
                return nil
            }
            return l
        }
        set {
            __UILongPressGestureRecognizerTag[self] = newValue
        }
    }
    
    var longPress: ((UILongPressGestureRecognizer) -> Void)? {
        get {
            guard let l = __UILongPressGestureRecognizerLongPress[self] else {
                return nil
            }
            return l
        }
        set {
            __UILongPressGestureRecognizerLongPress[self] = newValue
        }
    }
}
