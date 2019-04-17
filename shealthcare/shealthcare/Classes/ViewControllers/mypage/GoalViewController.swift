//
//  GoalViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 15/03/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit

class GoalViewController: UIViewController {

    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var bmiLabel: UILabel!
    @IBOutlet weak var bmiUnitLabel: UILabel!
    @IBOutlet weak var waistLabel: UILabel!
    
    @IBOutlet weak var mybmiLabel: UILabel!
    
    
    @IBOutlet weak var mybmiConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if true {
            let font:UIFont = UIFont.systemFont(ofSize: 17.0)
            let superscript:UIFont = UIFont.systemFont(ofSize: 11.0)
            let attributedString = NSMutableAttributedString(string: "kg/m2", attributes: [NSAttributedString.Key.font : font])
            attributedString.setAttributes([NSAttributedString.Key.font: superscript,
                                            NSAttributedString.Key.baselineOffset: 5], range: NSRange(location: 4, length: 1))
            self.bmiUnitLabel.attributedText = attributedString
        }
        
        let _height:Double = Double(Global.UserInfo!["height"]!)!
        
        let _sWeight = (_height/100.0) * (_height/100.0) * 18.5
        let _eWeight = (_height/100.0) * (_height/100.0) * 22.9
        self.weightLabel.text = String(format: "%.1f - %.1f", arguments: [_sWeight, _eWeight])
        
        
        let _sBmi:Double = _sWeight / ((_height/100.0) * (_height/100.0))
        let _eBmi:Double = _eWeight / ((_height/100.0) * (_height/100.0))
        self.bmiLabel.text = String(format: "BMI %.1f - %.1f", arguments: [_sBmi, _eBmi])
        
        let _gender:String = Global.UserInfo!["gender"]!
        if _gender == "1" {
            self.waistLabel.text = "80 미만"
        } else {
            self.waistLabel.text = "75 미만"
        }
        
        
        
        
        if true {
            // 21
            let _screenWidth = UIScreen.main.bounds.width - 10
            
            // 1. BMI 값 = 체중(kg) ÷ 키(m) 제곱
            // 예) 168cm / 60kg 의 경우,  60÷(1.68x1.68) = 20.8
            let _weight:Double = Double(Global.UserInfo!["weightEnd"]!)!
            let _height:Double = Double(Global.UserInfo!["height"]!)!
            
            let _bmi:CGFloat = CGFloat(_weight / ((_height/100.0) * (_height/100.0)))
            
            self.mybmiLabel.text = String(format: "내 위치\n%.1f", arguments: [_bmi])
            // 최소 17, 최대 38
            
            var _xPosition = (_bmi - 17.0) * (_screenWidth / 42.0)
            _xPosition = (_xPosition * 2) - 21
            if _xPosition - 21 <= 0 {
                self.mybmiConstraint.constant = 0
            } else if _xPosition >= _screenWidth - 42 {
                self.mybmiConstraint.constant = _screenWidth - 42
            } else {
                self.mybmiConstraint.constant = _xPosition
            }
        }
        
        
    }
    
    // MARK: - Action
    @IBAction func actionBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
