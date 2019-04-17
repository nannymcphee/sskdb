//
//  HeadUpViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 20/03/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit
import CoreMotion

extension BinaryInteger {
    var degreesToRadians: CGFloat { return CGFloat(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

class HeadUpViewController: UIViewController {
    @IBOutlet weak var rotateImageViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewArmConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewArmLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewList1HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewList2HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewList3HeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewBg: UIView!
    @IBOutlet weak var rotateImageView: UIView!
    @IBOutlet weak var img_arm: UIImageView!
    @IBOutlet weak var imageViewDamage: UIImageView!
    
    @IBOutlet weak var labelDegreeToNeck: UILabel!
    @IBOutlet weak var labelBurden: UILabel!
    
    let manager:CMMotionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        let scale = UIScreen.main.bounds.size.width / 320.0
        
        var trans = CGAffineTransform.init(scaleX: scale, y: scale)
        
        trans = trans.translatedBy(x: 0,
                                   y: self.viewBg.frame.origin.y * scale + UIApplication.shared.statusBarFrame.size.height)
        
        self.viewBg.transform = trans
        
        self.viewList1HeightConstraint.constant = 0
        self.viewList2HeightConstraint.constant = 0
        self.viewList3HeightConstraint.constant = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.manager.deviceMotionUpdateInterval = 0.5
        
        self.manager.startDeviceMotionUpdates(to: OperationQueue.main) { (motion, error) in
            if let quat = motion?.attitude.quaternion {
                
                let myPitch = atan2((2*quat.x*quat.w)-(2*quat.y*quat.z), 1 - (2*quat.x*quat.x)-(2*quat.z*quat.z)).radiansToDegrees
                
                self.onRotateImage(degree: myPitch)
            }
            
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.manager.stopDeviceMotionUpdates()
    }
    
    // MARK: - Action
    @IBAction func actionBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionMenuButton(_ sender: Any) {
        let mypageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MypageViewController") as! MypageViewController
        self.navigationController?.pushViewController(mypageViewController, animated: true)
    }
    
    @IBAction func actionListButton(_ sender: Any) {
        if self.viewList1HeightConstraint.constant == 0 {
            self.viewList1HeightConstraint.constant = 49
            self.viewList2HeightConstraint.constant = 49
            self.viewList3HeightConstraint.constant = 49
        } else {
            self.viewList1HeightConstraint.constant = 0
            self.viewList2HeightConstraint.constant = 0
            self.viewList3HeightConstraint.constant = 0
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
        
//        UIView.animate(withDuration: 0.5, animations: {
//            self.view.layoutIfNeeded()
//        }) { (Bool) in
//
//        }
    }
    
    // 예방가이드
    @IBAction func actionPreventionGuide(_ sender: Any) {
        let webViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webViewController.kind = "prevention_guide"
        self.navigationController?.pushViewController(webViewController, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            var viewControllers = self.navigationController?.viewControllers
            if let _count = viewControllers?.count {
                viewControllers?.remove(at: _count - 2)
                self.navigationController?.viewControllers = viewControllers!
            }
        }
    }
    
    // 고개를 들어요
    @IBAction func actionHeadUpButton(_ sender: Any) {
        let headUpViewController = UIStoryboard(name: "Vertebra", bundle: nil).instantiateViewController(withIdentifier: "HeadUpViewController") as! HeadUpViewController
        self.navigationController?.pushViewController(headUpViewController, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            var viewControllers = self.navigationController?.viewControllers
            if let _count = viewControllers?.count {
                viewControllers?.remove(at: _count - 2)
                self.navigationController?.viewControllers = viewControllers!
            }
        }
    }
    
    // 거북목 측정
    @IBAction func actionTurtleNeckButton(_ sender: Any) {
        let turtleNeckViewController = UIStoryboard(name: "Vertebra", bundle: nil).instantiateViewController(withIdentifier: "TurtleNeckViewController") as! TurtleNeckViewController
        self.navigationController?.pushViewController(turtleNeckViewController, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            var viewControllers = self.navigationController?.viewControllers
            if let _count = viewControllers?.count {
                viewControllers?.remove(at: _count - 2)
                self.navigationController?.viewControllers = viewControllers!
            }
        }
    }
    
    // 측정 기록
    @IBAction func actionResultButton(_ sender: Any) {
        let turtleNeckResultViewController = UIStoryboard(name: "Vertebra", bundle: nil).instantiateViewController(withIdentifier: "TurtleNeckResultViewController") as! TurtleNeckResultViewController
        self.navigationController?.pushViewController(turtleNeckResultViewController, animated: true)
    }
    
    
    
    // MARK: - Function
    func onRotateImage(degree:Double) {
        let currRotation = atan2(self.rotateImageView.transform.b, self.rotateImageView.transform.a).radiansToDegrees
        var moveRotation = 0.0
        var hRotation = 0.0
        var moveDegree = 0.0
        if degree > 90 {
            hRotation = 0.0
        } else if degree < 0 {
            hRotation = 90.0
        } else {
            hRotation = 90.0 - degree
        }
        
        var status = 0
        if abs(hRotation) > 60 {
            status = 5
        } else if abs(hRotation) > 45 {
            status = 4
        } else if abs(hRotation) > 30 {
            status = 3
        } else if abs(hRotation) > 15 {
            status = 2
        } else {
            status = 1
        }
        
        hRotation = hRotation > 60 ? 60 : hRotation
        moveRotation = hRotation * -1.0
        moveRotation = moveRotation - Double(currRotation)
        moveDegree = moveRotation.degreesToRadians
        
        
        self.rotateImageViewConstraint.constant = CGFloat(-status*2)
        self.imageViewArmLeadingConstraint.constant = CGFloat(48 - status*2)
        
        UIView.animate(withDuration: 0.5, animations: {
            
            if status == 1 {
                self.viewBg.backgroundColor = UIColor.init(hexString: "00C1AC")
                self.imageViewDamage.isHidden = true
                self.labelBurden.text = "4.5Kg"
            } else if status == 2 {
                self.viewBg.backgroundColor = UIColor.init(hexString: "A3C23E")
                self.imageViewDamage.isHidden = true
                self.labelBurden.text = "12.2Kg"
            } else if status == 3 {
                self.viewBg.backgroundColor = UIColor.init(hexString: "F3C82D")
                self.imageViewDamage.isHidden = false
                self.imageViewDamage.image = UIImage.init(named: "img_damage_01")
                self.labelBurden.text = "18.1Kg"
            } else if status == 4 {
                self.viewBg.backgroundColor = UIColor.init(hexString: "E57344")
                self.imageViewDamage.isHidden = false
                self.imageViewDamage.image = UIImage.init(named: "img_damage_02")
                self.labelBurden.text = "22.2Kg"
            } else if status == 5 {
                self.viewBg.backgroundColor = UIColor.init(hexString: "ED5652")
                self.imageViewDamage.isHidden = false
                self.imageViewDamage.image = UIImage.init(named: "img_damage_03")
                self.labelBurden.text = "27.2kg"
            }
            
            self.labelDegreeToNeck.text = String(format: "%dº", Int(hRotation))
            
            
            let transform = self.rotateImageView.transform.rotated(by: CGFloat(moveDegree))
            self.rotateImageView.transform = transform
            
//            self.img_arm.transform = transform
            self.view.layoutIfNeeded()
        })
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
