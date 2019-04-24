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
    
    func customRounded(border: CGFloat, color: UIColor) {
        self.layer.borderWidth = border
        self.layer.masksToBounds = false
        self.layer.borderColor = color.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
    
    func customBorder(cornerRadius: CGFloat, borderWidth: CGFloat, color: UIColor) {
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = color.cgColor
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }
    
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    
    func roundCorners(_ corners: UIRectCorner,_ cornerMask: CACornerMask, radius: CGFloat) {
        if #available(iOS 11.0, *) {
            self.clipsToBounds = true
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = cornerMask
        } else {
            self.clipsToBounds = true
            let rectShape = CAShapeLayer()
            rectShape.bounds = self.frame
            rectShape.position = self.center
            rectShape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
            self.layer.mask = rectShape
        }
    }
    
    func layerGradientVertical(color1: UIColor, color2: UIColor) {
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func layerGradientHorizontal(color1: UIColor, color2: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = bounds
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func layerGradientHorizontal(colors: [UIColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.compactMap({$0.cgColor})
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = bounds
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // retrieves all constraints that mention the view
    func getAllConstraints() -> [NSLayoutConstraint] {
        
        // array will contain self and all superviews
        var views = [self]
        
        // get all superviews
        var view = self
        while let superview = view.superview {
            views.append(superview)
            view = superview
        }
        
        // transform views to constraints and filter only those
        // constraints that include the view itself
        return views.flatMap({ $0.constraints }).filter { constraint in
            return constraint.firstItem as? UIView == self ||
                constraint.secondItem as? UIView == self
        }
    }
    
    // Example 1: Get all width constraints involving this view
    // We could have multiple constraints involving width, e.g.:
    // - two different width constraints with the exact same value
    // - this view's width equal to another view's width
    // - another view's height equal to this view's width (this view mentioned 2nd)
    func getWidthConstraints() -> [NSLayoutConstraint] {
        return getAllConstraints().filter( {
            ($0.firstAttribute == .width && $0.firstItem as? UIView == self) ||
                ($0.secondAttribute == .width && $0.secondItem as? UIView == self)
        } )
    }
    
    // Example 2: Change width constraint(s) of this view to a specific value
    // Make sure that we are looking at an equality constraint (not inequality)
    // and that the constraint is not against another view
    func changeWidth(to value: CGFloat) {
        
        getAllConstraints().filter( {
            $0.firstAttribute == .width &&
                $0.relation == .equal &&
                $0.secondAttribute == .notAnAttribute
        } ).forEach( {$0.constant = value })
    }
    
    func changeSize(to value: CGFloat) {
        changeWidth(to: value)
        changeHeight(to: value)
    }
    
    // Example 3: Change leading constraints only where this view is
    // mentioned first. We could also filter leadingMargin, left, or leftMargin
    func changeLeading(to value: CGFloat) {
        getAllConstraints().filter( {
            $0.firstAttribute == .leading &&
                $0.firstItem as? UIView == self
        }).forEach({$0.constant = value})
    }
    
    func getHeightConstraints() -> [NSLayoutConstraint] {
        return getAllConstraints().filter( {
            ($0.firstAttribute == .height && $0.firstItem as? UIView == self) ||
                ($0.secondAttribute == .height && $0.secondItem as? UIView == self)
        } )
    }
    
    func changeHeight(to value: CGFloat) {
        getAllConstraints().filter( {
            $0.firstAttribute == .height &&
                $0.relation == .equal &&
                $0.secondAttribute == .notAnAttribute
        } ).forEach( {$0.constant = value })
    }
    
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
