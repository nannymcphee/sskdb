//
//  DrugNameSelectViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 21/03/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit
import MBRadioCheckboxButton

class DrugNameSelectViewController: UIViewController, RadioButtonDelegate {
    func radioButtonDidSelect(_ button: RadioButton) {
    }
    
    func radioButtonDidDeselect(_ button: RadioButton) {
    }
    
    
    @IBOutlet weak var viewGroup: UIView!
    
    // 당뇨약
    @IBOutlet weak var buttonNameDiabetic: RadioButton!
    // 혈압약
    @IBOutlet weak var buttonNameBlood: RadioButton!
    // 인슐린
    @IBOutlet weak var buttonNameInsulin: RadioButton!
    // 이상지혈증약
    @IBOutlet weak var buttonNameDyslipidemia: RadioButton!
    // GLP-1
    @IBOutlet weak var buttonNameGLP: RadioButton!
    // 기타
    @IBOutlet weak var buttonNameOther: RadioButton!
    
    
    var groupContainer = RadioButtonContainer()

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        groupContainer.addButtons([buttonNameDiabetic,
                                   buttonNameBlood,
                                   buttonNameInsulin,
                                   buttonNameDyslipidemia,
                                   buttonNameGLP,
                                   buttonNameOther
            ])
        groupContainer.delegate = self
        groupContainer.selectedButton = buttonNameDiabetic
        
        for btn in groupContainer.allButtons {
            // Set cutsom color for each button
            btn.radioButtonColor = RadioButtonColor(active: UIColor.red, inactive: UIColor.black)
            
            // Set up cirlce size here
            btn.radioCircle = RadioButtonCircleStyle.init(outerCircle: 17, innerCircle: 13, outerCircleBorder: 2, contentPadding: 10)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        }
    }
    
    // MARK: - Action
    @IBAction func actionOtherButton(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "약물명을 작성하세요.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = self.textFieldOther.text
            textField.placeholder = "약물명을 작성하세요."
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
                "약물명을 입력하세요.".alert(self)
                return
            }
            if let cb = resultCallback {
                cb(self.textFieldOther.text!)
            }
        } else {
            if let cb = resultCallback {
                cb((groupContainer.selectedButton?.titleLabel?.text!)!)
                
            }
        }
        
        self.dismiss(animated: true) {
        }
    }
    
    // MARK: - Function
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
