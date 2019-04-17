//
//  FindIdPwdViewController.swift
//  shealthcare
//
//  Created by SangWooKim on 12/03/2019.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import UIKit

import Alamofire
import SwiftyXMLParser
import MKProgress

import CryptoSwift

//import GoneVisible

class FindIdPwdViewController: UIViewController {
    @IBOutlet weak var constraint_bottom: NSLayoutConstraint!
    
    @IBOutlet weak var nameTextField: TextField!
    @IBOutlet weak var phoneTextField: TextField!
    @IBOutlet weak var authNumTextField: TextField!
    
    
    var authNum:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func actionBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Notification Keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        if let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
            
            debugPrint("duration = %f", duration)
            
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                    self.constraint_bottom.constant = keyboardSize.height
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
            UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.constraint_bottom.constant = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    
    // MARK: - Action
    // 인증 번호 발송
    @IBAction func actionAuthNumButton(_ sender: Any) {
        let _name = self.nameTextField.text!
        let _phone = self.phoneTextField.text!
        
        if _name.count == 0 {
            "이름을 입력해주세요.".alert(self)
            return
        }
        
        if _phone.count == 0 {
            "휴대폰번호를 입력해주세요.".alert(self)
            return
        }
        
        
        let _url = "http://app.ichc.co.kr/api/shealthcare/mem_auth_sms_number.asp"
        let _parameters: Parameters = [
            "os": "IOS",
            "kind": "find",
            "name": _name.encodeUrlKr(),
            "phone": _phone
        ]
        
        debugPrint(_parameters)
        
        MKProgress.show()
        Alamofire.request(_url,
                          method: .post,
                          parameters: _parameters,
                          encoding: URLEncoding.default,
                          headers: [:])
            .validate()
            .responseData { (response) in
                MKProgress.hide()
                if let data = response.data {
                    debugPrint(data.toStringKr())
                    let xml = XML.parse(data)
                    if let resultText = xml.OUTPUT.Result.text {
                        if resultText == "OK" {
                            if let _authNum = xml.OUTPUT.Record.AuthNum.text {
                                self.authNum = _authNum
                                self.nameTextField.isUserInteractionEnabled = false
                                self.phoneTextField.isUserInteractionEnabled = false
                            }
                        } else if resultText == "Error" {
                            xml.OUTPUT.MSG.text?.alert(self)
                        }
                    }
                } else {
                    "통신중 오류가 발생하였습니다.".alert(self)
                }
        }
        
    }
    
    // 확인 버튼
    @IBAction func actionComplateButton(_ sender: Any) {
        if self.authNum == self.authNumTextField.text! {
            let _name = self.nameTextField.text!
            let _phone = self.phoneTextField.text!
            
            let _url = "http://app.ichc.co.kr/api/shealthcare/mem_find_id_password.asp"
            let _parameters: Parameters = [
                "os": "IOS",
                "name": _name.encodeUrlKr(),
                "phone": _phone
            ]
            
            MKProgress.show()
            Alamofire.request(_url,
                              method: .post,
                              parameters: _parameters,
                              encoding: URLEncoding.default,
                              headers: [:])
                .validate()
                .responseData { (response) in
                    MKProgress.hide()
                    if let data = response.data {
                        debugPrint(data.toStringKr())
                        let xml = XML.parse(data)
                        if let resultText = xml.OUTPUT.Result.text {
                            if resultText == "OK" {
                                "휴대폰으로 아이디와 비밀번호를 발송하였습니다.".alert(self, buttonCompletion: { (alertAction) in
                                    self.navigationController?.popToRootViewController(animated: true)
                                })
                            } else if resultText == "Error" {
                                xml.OUTPUT.MSG.text?.alert(self)
                            }
                        }
                    } else {
                        "통신중 오류가 발생하였습니다.".alert(self)
                    }
            }
        } else {
            "인증 번호가 다릅니다.".alert(self)
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
