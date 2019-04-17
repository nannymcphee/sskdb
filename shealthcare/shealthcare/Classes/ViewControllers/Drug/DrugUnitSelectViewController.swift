//
//  DrugUnitSelectViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 21/03/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit
import MBRadioCheckboxButton

class DrugUnitSelectViewController: UIViewController, RadioButtonDelegate {
    func radioButtonDidSelect(_ button: RadioButton) {
    }
    
    func radioButtonDidDeselect(_ button: RadioButton) {
    }

    // 정
    @IBOutlet weak var buttonSelect11: RadioButton!
    // 유닛
    @IBOutlet weak var buttonSelect12: RadioButton!
    // 티스푼
    @IBOutlet weak var buttonSelect13: RadioButton!
    // 포
    @IBOutlet weak var buttonSelect21: RadioButton!
    // 패치
    @IBOutlet weak var buttonSelect22: RadioButton!
    // 스프레이
    @IBOutlet weak var buttonSelect23: RadioButton!
    // mg
    @IBOutlet weak var buttonSelect31: RadioButton!
    // mL
    @IBOutlet weak var buttonSelect32: RadioButton!
    // 기타
    @IBOutlet weak var buttonNameOther: RadioButton!
    
    @IBOutlet weak var textFieldOther: TextField!
    
    public var resultCallback: ((String)->Void)? = nil
    
    public var defaultValue:String? = nil {
        didSet {
            if let _val = defaultValue {
                var isDefault = false
                for btn in groupContainer.allButtons {
                    if btn.titleLabel?.text == _val {
                        self.groupContainer.selectedButton = btn
                        isDefault = true
                    }
                }
                if isDefault == false, _val.count > 0 {
                    self.groupContainer.selectedButton = buttonNameOther
                    self.textFieldOther.text = defaultValue
                }
            }
        }
    }
    
    var groupContainer = RadioButtonContainer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        groupContainer.addButtons([buttonSelect11,
                                   buttonSelect12,
                                   buttonSelect13,
                                   buttonSelect21,
                                   buttonSelect22,
                                   buttonSelect23,
                                   buttonSelect31,
                                   buttonSelect32,
                                   buttonNameOther
            ])
        groupContainer.delegate = self
        groupContainer.selectedButton = buttonSelect11
        
        for btn in groupContainer.allButtons {
            // Set cutsom color for each button
            btn.radioButtonColor = RadioButtonColor(active: UIColor.red, inactive: UIColor.black)
            
            // Set up cirlce size here
            btn.radioCircle = RadioButtonCircleStyle.init(outerCircle: 17, innerCircle: 13, outerCircleBorder: 2, contentPadding: 10)
            
        }
    }
    
    // MARK: - IBAction
    @IBAction func actionOtherButton(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "단위를 작성하세요.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = self.textFieldOther.text
            textField.placeholder = "단위를 작성하세요."
        }
        let ok = UIAlertAction(title: "확인", style: .default) { (ok) in
            self.textFieldOther.text = alert.textFields?[0].text
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel) { (cancel) in
            
        }
        
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func actionCancelButton(_ sender: Any) {
        self.dismiss(animated: true) {
        }
    }
    
    @IBAction func actionComplateButton(_ sender: Any) {
        if groupContainer.selectedButton === buttonNameOther {
            if self.textFieldOther.text?.count == 0 {
                "단위를 입력하세요.".alert(self)
                return
            }
            if let cb = resultCallback {
                cb(self.textFieldOther.text!)
            }
        } else {
            if let cb = resultCallback {
                cb((groupContainer.selectedButton?.titleLabel?.text)!)
            }
        }
        
        self.dismiss(animated: true) {
        }
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
