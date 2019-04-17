//
//  EX_UIView.swift
//  shealthcare
//
//  Created by SangWooKim on 14/03/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit
import Foundation
import ImageIO

private var __object = [UIView: Any]()

extension UIView {
    
    var object: Any? {
        get {
            guard let l = __object[self] else {
                return nil
            }
            return l
        }
        set {
            __object[self] = newValue
        }
    }
    
    
    
    enum Visibility {
        case visible
        case invisible
        case gone
    }
    
    var visibility: Visibility {
        get {
            let constraint = (self.constraints.filter{$0.firstAttribute == .height && $0.constant == 0}.first)
            if let constraint = constraint, constraint.isActive {
                return .gone
            } else {
                return self.isHidden ? .invisible : .visible
            }
        }
        set {
            if self.visibility != newValue {
                self.setVisibility(newValue)
            }
        }
    }
    
    private func setVisibility(_ visibility: Visibility) {
        let constraintWidth = (self.constraints.filter{$0.firstAttribute == .width && $0.constant == 0}.first)
        let constraint = (self.constraints.filter{$0.firstAttribute == .height && $0.constant == 0}.first)
        
        switch visibility {
        case .visible:
            constraintWidth?.isActive = false
            constraint?.isActive = false
            self.isHidden = false
            break
        case .invisible:
            constraintWidth?.isActive = false
            constraint?.isActive = false
            self.isHidden = true
            break
        case .gone:
            if let constraintWidth = constraintWidth {
                constraintWidth.isActive = true
            } else {
                let constraintWidth = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 0)
                self.addConstraint(constraintWidth)
                constraintWidth.isActive = true
            }
            if let constraint = constraint {
                constraint.isActive = true
            } else {
                let constraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
                self.addConstraint(constraint)
                constraint.isActive = true
            }
            self.isHidden = true
        }
    }
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func addRightBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        if let layers = self.layer.sublayers {
            for layer in layers {
                if let key = layer.key, key == 999 {
                    layer.removeFromSuperlayer()
                }
            }
        }
        let border = CALayer()
        border.key = 999
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    @objc func longPress(gesture: UILongPressGestureRecognizer) {
        if let longPress = gesture.longPress {
            longPress(gesture)
        }
    }

    func addLongPress(_ duration: TimeInterval = 0.5, _ completionHandler: @escaping (UILongPressGestureRecognizer) -> Void) {
        self.isUserInteractionEnabled = true
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:)))
        longPress.minimumPressDuration = duration
        longPress.tag = 1
        longPress.longPress = completionHandler
        self.addGestureRecognizer(longPress)
    }
}

private var __CALayerObject = [CALayer: Int]()
extension CALayer {
    var key: Int? {
        get {
            guard let l = __CALayerObject[self] else {
                return nil
            }
            return l
        }
        set {
            __CALayerObject[self] = newValue
        }
    }
}

extension UIImage {
    func resize(targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height
        
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func scale(scale: CGFloat) -> UIImage? {
        let size = self.size
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        return self.resize(targetSize: scaledSize)
    }
}


extension UIColor {
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}

extension UILabel {
    func attrText(keyword:String, color:UIColor) {
        let attributedString = NSMutableAttributedString(string: self.text!, attributes: [NSAttributedString.Key.font : self.font])
        attributedString.setAttributes([
            NSAttributedString.Key.foregroundColor: color
            ], range: NSRange(self.text!.range(of: keyword)!, in: self.text!))
        self.attributedText = attributedString
    }
    func attrText(keyword:String, fontSize:Float, color:UIColor) {
        let attributedString = NSMutableAttributedString(string: self.text!, attributes: [NSAttributedString.Key.font : self.font])
        attributedString.setAttributes([
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(fontSize)),
            NSAttributedString.Key.foregroundColor: color
            ], range: NSRange(self.text!.range(of: keyword)!, in: self.text!))
        self.attributedText = attributedString
    }
}
