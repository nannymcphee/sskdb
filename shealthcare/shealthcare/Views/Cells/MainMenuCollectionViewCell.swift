//
//  MainMenuCollectionViewCell.swift
//  shealthcare
//
//  Created by Nguyên Duy on 4/17/19.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit

class MainMenuCollectionViewCell: UICollectionViewCell {
    //MARK: - ELEMENTS
    @IBOutlet weak var lbMenuName: UILabel!
    @IBOutlet weak var ivThumbnail: UIImageView!
    
    //MARK: - VARIOUSES
    var isAnimating: Bool = true

    
    //MARK: - OVERRIDES
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //MARK: - FUNCTIONS
    func populateData(item: MenuItem) {
        lbMenuName.text = item.name
        ivThumbnail.image = UIImage(named: item.imageName.orEmpty())
    }

    func startShakeAnimation() {
        CATransaction.begin()
        CATransaction.setDisableActions(false)
        self.layer.add(rotationAnimation(), forKey: "rotation")
        CATransaction.commit()
        
        isAnimating = true
    }
    
    func stopShakeAnimation() {
        layer.removeAllAnimations()
        isAnimating = false
    }
    
    private func rotationAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        let angle = CGFloat(0.02)
        let duration = TimeInterval(0.15)
        let variance = Double(0.025)
        animation.values = [angle, -angle]
        animation.autoreverses = true
        animation.duration = self.randomizeInterval(interval: duration, withVariance: variance)
        animation.repeatCount = Float.infinity
        return animation
    }
    
    private func randomizeInterval(interval: TimeInterval, withVariance variance: Double) -> TimeInterval {
        let random = (Double(arc4random_uniform(1000)) - 500.0) / 500.0
        return interval + variance * random;
    }
}
